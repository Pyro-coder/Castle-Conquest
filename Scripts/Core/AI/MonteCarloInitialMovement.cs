using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BattleSheepCore.Game;
using Godot;

namespace BattleSheepCore.AI
{
	[GlobalClass]
	public partial class MonteCarloInitialMovement : Node
	{
		[Signal]
		public delegate void BestInitialPlacementReadyEventHandler(Godot.Collections.Dictionary<string, int> result);

		[Signal]
		public delegate void BestMovementReadyEventHandler(Godot.Collections.Dictionary<string, int> result);

		private int simulationsPerMove;
		public int aiPlayerId;
		private Random rand;

		public MonteCarloInitialMovement()
		{
		}

		public void Initialize(int simulationsPerMove, int aiPlayerId)
		{
			this.simulationsPerMove = simulationsPerMove;
			this.aiPlayerId = aiPlayerId;
			rand = new Random();
		}

        public Godot.Collections.Dictionary<string, int> GetBestInitialPlacement(GameEngine gameEngine)
        {
            return Task.Run(() =>
            {
                var validPlacements = gameEngine.GetValidInitialPiecePlacements();
                int totalFree = validPlacements.Count; // Total tiles available for initial placement.

                // Tunable parameter: a high weight so that an ideal split will trump simulation differences.
                const double splitBonusWeight = 1000.0;

                // Create a cancellation token that cancels after 4 seconds.
                var cts = new CancellationTokenSource(TimeSpan.FromSeconds(4));
                CancellationToken token = cts.Token;

                int bestQ = 0;
                int bestR = 0;

                var candidateResults = validPlacements.AsParallel().Select(placement =>
                {
                    // Run standard Monte Carlo simulations.
                    double totalScore = 0;
                    int simulationsRun = 0;
                    for (int i = 0; i < simulationsPerMove; i++)
                    {
                        if (token.IsCancellationRequested)
                            break;
                        var simState = gameEngine.Clone();
                        try
                        {
                            simState.PlaceInitialPieces(aiPlayerId, placement.q, placement.r);
                        }
                        catch (Exception)
                        {
                            continue;
                        }
                        totalScore += SimulateRandomPlayout(simState, aiPlayerId);
                        simState.QueueFree();
                        simulationsRun++;
                    }
                    double avgScore = simulationsRun > 0 ? totalScore / simulationsRun : double.MinValue;

                    // --- Compute the Split Bonus ---
                    // Build a set of free tile coordinates (from valid placements).
                    var freeTiles = new HashSet<(int, int)>(validPlacements.Select(vp => (vp.q, vp.r)));
                    // Remove the candidate tile because the AI would take it.
                    freeTiles.Remove((placement.q, placement.r));

                    // Compute connected components in the free region.
                    var componentSizes = ComputeComponentsSizes(freeTiles);
                    double splitBonus = 0;
                    // We only award a bonus if the candidate splits the region into exactly 2 components.
                    if (componentSizes.Count == 2)
                    {
                        int comp1 = componentSizes[0];
                        int comp2 = componentSizes[1];
                        int diff = Math.Abs(comp1 - comp2);
                        // When totalFree is even, removing one tile leaves an odd number.
                        // The ideal split for an odd number (e.g. 31) is 16 and 15; ideal difference is 1.
                        const int idealDiff = 1;
                        // Maximum possible difference is when one component gets all the tiles.
                        int maxDiff = (totalFree - 1) - idealDiff;
                        double normalized = maxDiff > 0 ? (1.0 - ((double)Math.Abs(diff - idealDiff) / maxDiff)) : 1.0;
                        splitBonus = splitBonusWeight * normalized;

                        if (diff is idealDiff or idealDiff + 1)
                        {
                            splitBonus = splitBonusWeight; // Maximum bonus
                        }
                        else
                        {
                            splitBonus = 0; // Otherwise, no bonus.
                        }
                    }
                    // --- End Split Bonus Computation ---

                    double finalScore = avgScore + splitBonus;
                    return (placement, finalScore);
                }).ToList();

                var bestCandidate = candidateResults.OrderByDescending(r => r.finalScore).FirstOrDefault();
                bestQ = bestCandidate.placement.q;
                bestR = bestCandidate.placement.r;

                var result = new Godot.Collections.Dictionary<string, int>
        {
            { "q", bestQ },
            { "r", bestR }
        };

                return result;
            }).GetAwaiter().GetResult();
        }

        // Helper: Compute the sizes of connected components (regions) in the free tile set.
        private List<int> ComputeComponentsSizes(HashSet<(int, int)> freeTiles)
        {
            var sizes = new List<int>();
            var visited = new HashSet<(int, int)>();

            foreach (var tile in freeTiles)
            {
                if (!visited.Contains(tile))
                {
                    int size = BFSComponent(tile, freeTiles, visited);
                    sizes.Add(size);
                }
            }
            return sizes;
        }

        // BFS to compute the size of one connected component in a hex grid.
        private int BFSComponent((int q, int r) start, HashSet<(int, int)> freeTiles, HashSet<(int, int)> visited)
        {
            int count = 0;
            var queue = new Queue<(int, int)>();
            queue.Enqueue(start);
            visited.Add(start);

            // Directions for axial hex grids.
            (int dq, int dr)[] directions = new (int, int)[]
            {
        (1, 0), (1, -1), (0, -1),
        (-1, 0), (-1, 1), (0, 1)
            };

            while (queue.Count > 0)
            {
                var current = queue.Dequeue();
                count++;
                foreach (var (dq, dr) in directions)
                {
                    var neighbor = (current.Item1 + dq, current.Item2 + dr);
                    if (freeTiles.Contains(neighbor) && !visited.Contains(neighbor))
                    {
                        visited.Add(neighbor);
                        queue.Enqueue(neighbor);
                    }
                }
            }
            return count;
        }



        // Helper: Compute hex grid distance between two axial coordinates.
        private int HexDistance(int q1, int r1, int q2, int r2)
        {
            int dq = Math.Abs(q1 - q2);
            int dr = Math.Abs(r1 - r2);
            int ds = Math.Abs((-q1 - r1) - (-q2 - r2)); // since s = -q - r for axial coordinates.
            return Math.Max(Math.Max(dq, dr), ds);
        }


        public Godot.Collections.Dictionary<string, int> GetBestMovement(GameEngine gameEngine)
		{
			return Task.Run(() =>
			{
				var validMoves = gameEngine.GetValidMoves(aiPlayerId);
				validMoves = validMoves.OrderByDescending(move => GetEmptySquares(gameEngine, move.startRow, move.startCol, move.directionIndex)).ToList();

				// Create a cancellation token that cancels after 4 seconds.
				var cts = new CancellationTokenSource(TimeSpan.FromSeconds(4));
				CancellationToken token = cts.Token;

				(int startRow, int startCol, int count, int directionIndex) bestMove = (0, 0, 0, 0);

				var candidateResults = validMoves.AsParallel().Select(move =>
				{
					double totalScore = 0;
					int simulationsRun = 0;
					for (int i = 0; i < simulationsPerMove; i++)
					{
						if (token.IsCancellationRequested)
							break;
						var simState = gameEngine.Clone();
						try
						{
							simState.MovePieces(aiPlayerId, move.startRow, move.startCol, move.count, move.directionIndex);
						}
						catch (Exception)
						{
							continue;
						}
						totalScore += SimulateRandomPlayout(simState, aiPlayerId);
                        simState.QueueFree();
						simulationsRun++;
					}
					double avgScore = simulationsRun > 0 ? totalScore / simulationsRun : double.MinValue;
					return (move, avgScore);
				}).ToList();

				var bestCandidate = candidateResults.OrderByDescending(r => r.avgScore).FirstOrDefault();
				bestMove = bestCandidate.move;

				var result = new Godot.Collections.Dictionary<string, int>
				{
					{ "startRow", bestMove.startRow },
					{ "startCol", bestMove.startCol },
					{ "count", bestMove.count },
					{ "directionIndex", bestMove.directionIndex }
				};

				return result;
			}).GetAwaiter().GetResult();
		}

		public void StartBestInitialPlacement(GameEngine gameEngine)
		{
			Task.Run(() =>
			{
				var result = GetBestInitialPlacement(gameEngine);
				CallDeferred(nameof(OnBestInitialPlacementComputed), result);
			});
		}

		private void OnBestInitialPlacementComputed(Godot.Collections.Dictionary<string, int> result)
		{
			EmitSignal("BestInitialPlacementReady", result);
		}

		public void StartBestMovement(GameEngine gameEngine)
		{
			Task.Run(() =>
			{
				var result = GetBestMovement(gameEngine);
				CallDeferred(nameof(OnBestMovementComputed), result);
			});
		}

		private void OnBestMovementComputed(Godot.Collections.Dictionary<string, int> result)
		{
			EmitSignal("BestMovementReady", result);
		}

		private int SimulateRandomPlayout(IGameEngine state, int currentPlayerId)
		{
			int simulationDepth = 10;
			for (int d = 0; d < simulationDepth && !state.CheckForWin(); d++)
			{
				var moves = state.GetValidMoves(currentPlayerId);
				if (moves.Count == 0)
					break;
				var move = moves[rand.Next(moves.Count)];
				try
				{
					state.MovePieces(currentPlayerId, move.startRow, move.startCol, move.count, move.directionIndex);
				}
				catch (Exception)
				{
					break;
				}
				currentPlayerId = (currentPlayerId == aiPlayerId) ? GetOpponentId() : aiPlayerId;
			}
			return Evaluate(state);
		}

		private int GetEmptySquares(IGameEngine state, int startRow, int startCol, int directionIndex)
		{
			(int dq, int dr)[] directions = new (int, int)[]
			{
				(1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)
			};
			var (dq, dr) = directions[directionIndex];
			int count = 0;
			int currentQ = startRow;
			int currentR = startCol;
			int boardRadius = state.BoardSize;

			while (true)
			{
				currentQ += dq;
				currentR += dr;
				if (Math.Abs(currentQ) > boardRadius || Math.Abs(currentR) > boardRadius || Math.Abs(currentQ + currentR) > boardRadius)
					break;
				bool found = false;
				foreach (var cell in state.AIGetCurrentBoardState())
				{
					if (cell.q == currentQ && cell.r == currentR)
					{
						found = true;
						if (cell.pieceCount == 0)
						{
							count++;
							break;
						}
						else
						{
							return count;
						}
					}
				}
				if (!found)
					break;
			}
			return count;
		}

		private int Evaluate(IGameEngine state)
		{
			int baseScore = state.GetLargestConnectedSectionSize(aiPlayerId) - state.GetLargestConnectedSectionSize(GetOpponentId());
			int aiMobility = state.GetValidMoves(aiPlayerId).Count;
			int opponentMobility = state.GetValidMoves(GetOpponentId()).Count;
			int mobilityScore = (aiMobility - opponentMobility) * 10;
			return baseScore + mobilityScore;
		}

		private int GetOpponentId()
		{
			return (aiPlayerId == 1) ? 2 : 1;
		}
	}
}
