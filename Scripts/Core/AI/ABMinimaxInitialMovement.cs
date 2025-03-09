using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BattleSheepCore.Game;
using Godot;

namespace BattleSheepCore.AI
{
    public class ABMinimaxInitialMovement
    {
        private int maxDepth;
        private int aiPlayerId;
        private readonly TimeSpan timeLimit = TimeSpan.FromSeconds(4);

        public ABMinimaxInitialMovement(int maxDepth, int aiPlayerId)
        {
            // At highest difficulty, you can set maxDepth = 5 externally.
            this.maxDepth = maxDepth;
            this.aiPlayerId = aiPlayerId;
        }

        // Returns the best initial placement as (q, r) using iterative deepening.
        public (int q, int r) GetBestInitialPlacement(IGameEngine gameEngine)
        {
            DateTime startTime = DateTime.Now;
            int bestScore = int.MinValue;
            (int q, int r) bestMove = (0, 0);
            var validPlacements = gameEngine.GetValidInitialPiecePlacements();

            // Iterative deepening over increasing depth.
            for (int depth = 1; depth <= maxDepth; depth++)
            {
                if (DateTime.Now - startTime > timeLimit)
                    break;
                // Evaluate each candidate in parallel.
                var results = validPlacements.AsParallel().Select(placement =>
                {
                    var simulatedGame = gameEngine.Clone();
                    try
                    {
                        simulatedGame.PlaceInitialPieces(aiPlayerId, placement.q, placement.r);
                    }
                    catch (Exception)
                    {
                        return (score: int.MinValue, placement: placement);
                    }
                    int score = IterativeMinimax(simulatedGame, depth - 1, int.MinValue, int.MaxValue, false, startTime);
                    return (score: score, placement: placement);
                }).ToList();

                var localBest = results.OrderByDescending(t => t.score).FirstOrDefault();
                if (localBest.score > bestScore)
                {
                    bestScore = localBest.score;
                    bestMove = (localBest.placement.q, localBest.placement.r);
                }
            }
            return bestMove;
        }

        // Returns the best movement move as (startRow, startCol, count, directionIndex) using iterative deepening.
        public (int startRow, int startCol, int count, int directionIndex) GetBestMovement(IGameEngine gameEngine)
        {
            DateTime startTime = DateTime.Now;
            int bestScore = int.MinValue;
            (int startRow, int startCol, int count, int directionIndex) bestMove = (0, 0, 0, 0);
            var validMoves = gameEngine.GetValidMoves(aiPlayerId);

            // Order moves based on empty squares along the direction and closeness to an optimal count.
            validMoves = validMoves.OrderByDescending(move =>
            {
                int empty = GetEmptySquares(gameEngine, move.startRow, move.startCol, move.directionIndex);
                int sourcePieces = GetSourcePieceCount(gameEngine, move.startRow, move.startCol);
                int optimal = sourcePieces > 1 ? (int)Math.Round((sourcePieces - 1) * 0.7) : 0;
                int diffPenalty = 5 * Math.Abs(move.count - optimal);
                return empty - diffPenalty;
            }).ToList();

            for (int depth = 1; depth <= maxDepth; depth++)
            {
                if (DateTime.Now - startTime > timeLimit)
                    break;
                var results = validMoves.AsParallel().Select(move =>
                {
                    var simulatedGame = gameEngine.Clone();
                    try
                    {
                        simulatedGame.MovePieces(aiPlayerId, move.startRow, move.startCol, move.count, move.directionIndex);
                    }
                    catch (Exception)
                    {
                        return (score: int.MinValue, move: move);
                    }
                    int score = IterativeMinimax(simulatedGame, depth - 1, int.MinValue, int.MaxValue, false, startTime);
                    return (score: score, move: move);
                }).ToList();

                var localBest = results.OrderByDescending(t => t.score).FirstOrDefault();
                if (localBest.score > bestScore)
                {
                    bestScore = localBest.score;
                    bestMove = localBest.move;
                }
            }
            return bestMove;
        }

        // Helper: Count the number of continuous empty squares in the given direction.
        private int GetEmptySquares(IGameEngine state, int startRow, int startCol, int directionIndex)
        {
            // Axial coordinate directions for six hex directions.
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

        // Helper: Get the number of pieces at the source cell.
        private int GetSourcePieceCount(IGameEngine state, int q, int r)
        {
            foreach (var cell in state.AIGetCurrentBoardState())
            {
                if (cell.q == q && cell.r == r)
                    return cell.pieceCount;
            }
            return 0;
        }

        // Iterative deepening minimax with time check.
        private int IterativeMinimax(IGameEngine state, int depth, int alpha, int beta, bool maximizingPlayer, DateTime startTime)
        {
            if (DateTime.Now - startTime > timeLimit)
                return Evaluate(state);
            if (depth == 0 || state.CheckForWin())
                return Evaluate(state);

            int currentPlayerId = maximizingPlayer ? aiPlayerId : GetOpponentId();
            bool isInitialPhase = !HasPlacedInitial(state, currentPlayerId);

            if (maximizingPlayer)
            {
                int maxEval = int.MinValue;
                if (isInitialPhase)
                {
                    var moves = state.GetValidInitialPiecePlacements();
                    foreach (var move in moves)
                    {
                        var newState = state.Clone();
                        try
                        {
                            newState.PlaceInitialPieces(currentPlayerId, move.q, move.r);
                        }
                        catch (Exception)
                        {
                            continue;
                        }
                        int eval = IterativeMinimax(newState, depth - 1, alpha, beta, false, startTime);
                        maxEval = Math.Max(maxEval, eval);
                        alpha = Math.Max(alpha, eval);
                        if (beta <= alpha)
                            break;
                        if (DateTime.Now - startTime > timeLimit)
                            break;
                    }
                }
                else
                {
                    var moves = state.GetValidMoves(currentPlayerId);
                    foreach (var move in moves)
                    {
                        var newState = state.Clone();
                        try
                        {
                            newState.MovePieces(currentPlayerId, move.startRow, move.startCol, move.count, move.directionIndex);
                        }
                        catch (Exception)
                        {
                            continue;
                        }
                        int eval = IterativeMinimax(newState, depth - 1, alpha, beta, false, startTime);
                        maxEval = Math.Max(maxEval, eval);
                        alpha = Math.Max(alpha, eval);
                        if (beta <= alpha)
                            break;
                        if (DateTime.Now - startTime > timeLimit)
                            break;
                    }
                }
                return maxEval;
            }
            else
            {
                int minEval = int.MaxValue;
                if (isInitialPhase)
                {
                    var moves = state.GetValidInitialPiecePlacements();
                    foreach (var move in moves)
                    {
                        var newState = state.Clone();
                        try
                        {
                            newState.PlaceInitialPieces(currentPlayerId, move.q, move.r);
                        }
                        catch (Exception)
                        {
                            continue;
                        }
                        int eval = IterativeMinimax(newState, depth - 1, alpha, beta, true, startTime);
                        minEval = Math.Min(minEval, eval);
                        beta = Math.Min(beta, eval);
                        if (beta <= alpha)
                            break;
                        if (DateTime.Now - startTime > timeLimit)
                            break;
                    }
                }
                else
                {
                    var moves = state.GetValidMoves(currentPlayerId);
                    foreach (var move in moves)
                    {
                        var newState = state.Clone();
                        try
                        {
                            newState.MovePieces(currentPlayerId, move.startRow, move.startCol, move.count, move.directionIndex);
                        }
                        catch (Exception)
                        {
                            continue;
                        }
                        int eval = IterativeMinimax(newState, depth - 1, alpha, beta, true, startTime);
                        minEval = Math.Min(minEval, eval);
                        beta = Math.Min(beta, eval);
                        if (beta <= alpha)
                            break;
                        if (DateTime.Now - startTime > timeLimit)
                            break;
                    }
                }
                return minEval;
            }
        }

        private bool HasPlacedInitial(IGameEngine state, int playerId)
        {
            var boardState = state.AIGetCurrentBoardState();
            foreach (var cell in boardState)
            {
                if (cell.playerId == playerId)
                    return true;
            }
            return false;
        }

        private int GetOpponentId()
        {
            return (aiPlayerId == 1) ? 2 : 1;
        }

        // Revised evaluation function.
        private int Evaluate(IGameEngine state)
        {
            // Base score: difference in largest connected section sizes.
            int baseScore = state.GetLargestConnectedSectionSize(aiPlayerId) - state.GetLargestConnectedSectionSize(GetOpponentId());

            // Mobility score: difference in valid move counts.
            int aiMobility = state.GetValidMoves(aiPlayerId).Count;
            int opponentMobility = state.GetValidMoves(GetOpponentId()).Count;
            int mobilityScore = (aiMobility - opponentMobility) * 10;

            // Choke bonus: analyze each AI-occupied cell for narrow, evenly spaced passages.
            int boardRadius = state.BoardSize;
            List<(int q, int r)> allCells = new List<(int, int)>();
            for (int q = -boardRadius; q <= boardRadius; q++)
            {
                for (int r = Math.Max(-boardRadius, -q - boardRadius); r <= Math.Min(boardRadius, -q + boardRadius); r++)
                {
                    allCells.Add((q, r));
                }
            }
            int chokeBonus = 0;
            Dictionary<(int, int), (int pieceCount, int playerId)> boardDict = new Dictionary<(int, int), (int, int)>();
            foreach (var cell in state.AIGetCurrentBoardState())
            {
                boardDict[(cell.q, cell.r)] = (cell.pieceCount, cell.playerId);
            }
            (int dq, int dr)[] offsets = new (int, int)[]
            {
                (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)
            };
            foreach (var cell in state.AIGetCurrentBoardState().Where(c => c.playerId == aiPlayerId))
            {
                int[] pairSums = new int[3];
                for (int i = 0; i < 6; i++)
                {
                    var neighbor = (cell.q + offsets[i].dq, cell.r + offsets[i].dr);
                    bool empty = true;
                    if (boardDict.ContainsKey(neighbor))
                    {
                        if (boardDict[neighbor].pieceCount > 0)
                            empty = false;
                    }
                    if (empty)
                    {
                        int pairIndex = i % 3;
                        pairSums[pairIndex]++;
                    }
                }
                int sum = pairSums.Sum();
                double variance = pairSums.Select(val => Math.Pow(val - (sum / 3.0), 2)).Average();
                if (sum < 3)
                    chokeBonus += 20;
                else if (sum < 5)
                    chokeBonus += 10;
                if (variance < 1.0)
                    chokeBonus += 10;
            }

            // Capture potential: adjust score based on opponent's ability to capture empty squares.
            int capturePotential = 0;
            int opponentThreshold = 5;
            foreach (var cell in allCells)
            {
                if (!boardDict.ContainsKey(cell))
                    continue;
                var info = boardDict[cell];
                if (info.pieceCount > 0)
                    continue;
                int maxOpponent = 0;
                foreach (var (dq, dr) in offsets)
                {
                    var neighbor = (cell.q + dq, cell.r + dr);
                    if (boardDict.ContainsKey(neighbor))
                    {
                        var nInfo = boardDict[neighbor];
                        if (nInfo.playerId == GetOpponentId())
                            maxOpponent = Math.Max(maxOpponent, nInfo.pieceCount);
                    }
                }
                if (maxOpponent >= opponentThreshold)
                {
                    // If the opponent has a large stack, assume they can capture about half the empty area.
                    capturePotential -= 5;
                }
                else if (maxOpponent > 0)
                {
                    // If the opponent's stack is small, reward aggressive play.
                    capturePotential += 5;
                }
            }

            return baseScore + mobilityScore + chokeBonus + capturePotential;
        }
    }
}
