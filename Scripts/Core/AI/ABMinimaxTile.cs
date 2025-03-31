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
		public (int q, int r, int orientation) _GetBestTilePlacement(IGameEngine gameEngine)
		{
			int bestScore = int.MinValue;
			(int q, int r, int orientation) bestMove = (0, 0, 0);
			var tile = new Tile();
			var validPlacements = gameEngine.GetValidTilePlacements(tile);
			foreach (var placement in validPlacements)
			{
				//GD.Print(placement.q +","+ placement.r + ","+placement.orientation);
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
				if (score > bestScore)
				{
					bestScore = score;
					bestMove = (placement.q, placement.r, placement.orientation);
				}
			}
			return bestMove;
		}

		private int Minimax(IGameEngine state, int depth, int alpha, int beta, bool maximizingPlayer)
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

		private int Evaluate(IGameEngine state)
		{
			// Get the current board state. This should include only the cells that have been initialized (i.e., part of a tile).
			var boardState = state.AIGetCurrentBoardState();
			if (boardState.Count == 0)
				return 0;

			double totalDistance = 0;
			// Compute the average hex distance from the center (0,0) for every initialized cell.
			// Hex distance in axial coordinates is calculated as (|q| + |r| + |q+r|)/2.
			foreach (var cell in boardState)
			{
				int q = cell.q;
				int r = cell.r;
				int distance = (Math.Abs(q) + Math.Abs(r) + Math.Abs(q + r)) / 2;
				totalDistance += distance;
			}
			double avgDistance = totalDistance / boardState.Count;

			// For tile placement:
			// - If AI is player 1, it prefers a sprawling board (high avgDistance).
			// - If AI is player 2, it prefers a compact board (low avgDistance).
			return aiPlayerId == 1
				? (int)(avgDistance * 100)   // Reward higher average distance.
				: (int)(-avgDistance * 100); // Reward lower average distance.
		}

	}
}
