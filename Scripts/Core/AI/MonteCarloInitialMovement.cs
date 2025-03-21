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
		private int aiPlayerId;
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
				// Create a cancellation token that cancels after 4 seconds.
				var cts = new CancellationTokenSource(TimeSpan.FromSeconds(4));
				CancellationToken token = cts.Token;

				int bestQ = 0;
				int bestR = 0;

				var candidateResults = validPlacements.AsParallel().Select(placement =>
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
							simState.PlaceInitialPieces(aiPlayerId, placement.q, placement.r);
						}
						catch (Exception)
						{
							continue;
						}
						totalScore += SimulateRandomPlayout(simState, aiPlayerId);
						simulationsRun++;
					}
					double avgScore = simulationsRun > 0 ? totalScore / simulationsRun : double.MinValue;
					return (placement, avgScore);
				}).ToList();

				var bestCandidate = candidateResults.OrderByDescending(r => r.avgScore).FirstOrDefault();
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
