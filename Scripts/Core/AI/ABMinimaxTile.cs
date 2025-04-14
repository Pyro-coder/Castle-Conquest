using System;
using System.Collections.Generic;
using BattleSheepCore.Board;
using BattleSheepCore.Game;
using Godot;
using Godot.Collections;

namespace BattleSheepCore.AI
{
    [GlobalClass]
    public partial class ABMinimaxTile : Node
    {
        private int maxDepth;
        private int aiPlayerId;

        // NEW: track whether the AI goes first
        private bool aiGoesFirstCalculated = false;
        private bool aiGoesFirst = false;

        public ABMinimaxTile() { }

        public void Initialize(int maxDepth, int aiPlayerId)
        {
            this.maxDepth = maxDepth;
            this.aiPlayerId = aiPlayerId;
        }

        public Godot.Collections.Dictionary GetBestTilePlacement(GameEngine gameEngine)
        {
            var bestPlacement = _GetBestTilePlacement(gameEngine);
            Dictionary result = new Dictionary();
            result["q"] = bestPlacement.q;
            result["r"] = bestPlacement.r;
            result["orientation"] = bestPlacement.orientation;
            return result;
        }

        // Returns the best tile placement for the AI as (q, r, orientation)
        public (int q, int r, int orientation) _GetBestTilePlacement(GameEngine gameEngine)
        {
            // NEW: Calculate if AI goes first once
            if (!aiGoesFirstCalculated)
            {
                var boardState = gameEngine.AIGetCurrentBoardState();
                int hexCount = boardState.Count;
                int placedTiles = hexCount / 4;
                aiGoesFirst = placedTiles % 2 == 0; // even = AI went first
                aiGoesFirstCalculated = true;
            }

            int bestScore = int.MinValue;
            (int q, int r, int orientation) bestMove = (0, 0, 0);
            var tile = new Tile();
            var validPlacements = gameEngine.GetValidTilePlacements(tile);
            foreach (var placement in validPlacements)
            {
                var simulatedGame = gameEngine.Clone();
                try
                {
                    simulatedGame.PlaceTile(aiPlayerId, placement.q, placement.r, placement.orientation);
                }
                catch (Exception)
                {
                    continue;
                }
                int score = Minimax(simulatedGame, maxDepth - 1, int.MinValue, int.MaxValue, false);
                // Now that we've used newState, free it
                simulatedGame.QueueFree();
                if (score > bestScore)
                {
                    bestScore = score;
                    bestMove = (placement.q, placement.r, placement.orientation);
                }
            }
            return bestMove;
        }

        private int Minimax(GameEngine state, int depth, int alpha, int beta, bool maximizingPlayer)
        {
            if (depth == 0 || state.CheckForWin())
                return Evaluate(state);

            if (maximizingPlayer)
            {
                int maxEval = int.MinValue;
                var tile = new Tile();
                var moves = state.GetValidTilePlacements(tile);
                foreach (var move in moves)
                {
                    var newState = state.Clone();
                    try
                    {
                        newState.PlaceTile(aiPlayerId, move.q, move.r, move.orientation);
                    }
                    catch (Exception)
                    {
                        continue;
                    }
                    int eval = Minimax(newState, depth - 1, alpha, beta, false);
                    // Now that we've used newState, free it
                    newState.QueueFree();
                    maxEval = Math.Max(maxEval, eval);
                    alpha = Math.Max(alpha, eval);
                    if (beta <= alpha)
                        break;
                }
                return maxEval;
            }
            else
            {
                int minEval = int.MaxValue;
                int opponentId = (aiPlayerId == 1) ? 2 : 1;
                var tile = new Tile();
                var moves = state.GetValidTilePlacements(tile);
                foreach (var move in moves)
                {
                    var newState = state.Clone();
                    try
                    {
                        newState.PlaceTile(opponentId, move.q, move.r, move.orientation);
                    }
                    catch (Exception)
                    {
                        continue;
                    }
                    int eval = Minimax(newState, depth - 1, alpha, beta, true);
                    minEval = Math.Min(minEval, eval);
                    beta = Math.Min(beta, eval);
                    if (beta <= alpha)
                        break;
                }
                return minEval;
            }
        }

        private int Evaluate(GameEngine state)
        {
            var boardState = state.AIGetCurrentBoardState();
            if (boardState.Count == 0)
                return 0;

            double totalDistance = 0;
            double contactScore = 0;

            // Hexagonal neighbor directions (axial)
            (int dq, int dr)[] directions = new (int, int)[]
            {
                (1, 0), (0, 1), (-1, 1), (-1, 0), (0, -1), (1, -1)
            };

            HashSet<(int, int)> occupied = new HashSet<(int, int)>();
            foreach (var cell in boardState)
                occupied.Add((cell.q, cell.r));

            foreach (var cell in boardState)
            {
                int q = cell.q;
                int r = cell.r;
                int distance = (Math.Abs(q) + Math.Abs(r) + Math.Abs(q + r)) / 2;
                totalDistance += distance;

                int neighbors = 0;
                foreach (var (dq, dr) in directions)
                {
                    if (occupied.Contains((q + dq, r + dr)))
                        neighbors++;
                }

                contactScore += neighbors;
            }

            double avgDistance = totalDistance / boardState.Count;
            contactScore = contactScore / 2; // Optional: remove double-counting

            double weightDistance = 100;
            double weightContact = 50;

            if (aiPlayerId == 1)
            {
                // Player 1 wants to sprawl (maximize distance, minimize contact)
                return (int)(avgDistance * weightDistance - contactScore * weightContact);
            }
            else
            {
                // Player 2 logic adjusts based on whether AI goes first
                if (aiGoesFirst)
                {
                    // AI (player 2) went first — could adjust weights here
                    return (int)(avgDistance * weightDistance - contactScore * weightContact);
                }
                else
                {
                    // AI (player 2) went second — standard compact strategy
                    return (int)(-avgDistance * weightDistance + contactScore * weightContact);
                }
            }
        }
    }
}
