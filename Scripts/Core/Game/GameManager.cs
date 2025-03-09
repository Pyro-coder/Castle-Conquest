using BattleSheepCore.Board;
using BattleSheepCore.Players;
using System;
using System.Collections.Generic;

namespace BattleSheepCore.Game
{
    public class InvalidMoveException : Exception
    {
        public InvalidMoveException(string message) : base(message) { }
    }

    public class GameManager
    {
        private BoardManager _boardManager;
        private List<Player> _players;

        public GameManager(BoardManager boardManager, List<Player> players)
        {
            _boardManager = boardManager;
            _players = players;
        }

        public void InitializeCell(int q, int r)
        {
            var cell = _boardManager.GetCell(q, r);
            cell.InitializeCell();
        }

        public void PlaceInitialPieces(Player player, int q, int r)
        {
            var validBorderCells = _boardManager.GetTrueBorderCells();

            if (!validBorderCells.Contains((q, r)))
            {
                throw new InvalidOperationException(
                    $"Invalid initial placement. ({q}, {r}) is not on the true external edge."
                );
            }

            var cell = _boardManager.GetCell(q, r);
            cell.PlacePieces(16, player.Id);
        }

        private (int dq, int dr) GetDirectionVector(int directionIndex)
        {
            var directions = new (int dq, int dr)[]
            {
                (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)
            };

            if (directionIndex < 0 || directionIndex >= directions.Length)
            {
                throw new ArgumentException("Invalid direction index.");
            }

            return directions[directionIndex];
        }

        public void MovePieces(Player player, int startQ, int startR, int count, int directionIndex)
        {
            var startCell = _boardManager.GetCell(startQ, startR);

            if (startCell.PlayerId != player.Id)
            {
                throw new InvalidOperationException("You can only move pieces from your own cells.");
            }

            if (startCell.PieceCount <= 1)
            {
                throw new InvalidOperationException("There must be at least one piece left on the starting cell.");
            }

            if (count <= 0 || count >= startCell.PieceCount)
            {
                throw new InvalidOperationException("Invalid number of pieces to move.");
            }

            var (directionQ, directionR) = GetDirectionVector(directionIndex);
            var nextQ = startQ + directionQ;
            var nextR = startR + directionR;

            if (!_boardManager.IsCellValid(nextQ, nextR))
            {
                throw new InvalidMoveException("Move blocked by adjacent occupied cell. Try again.");
            }

            var initialPieceCount = startCell.PieceCount;
            var furthestCell = _boardManager.GetFurthestUnoccupiedHex(startQ, startR, directionQ, directionR);

            startCell.RemovePieces(count);
            furthestCell.PlacePieces(count, player.Id);

            if (startCell.PieceCount == initialPieceCount)
            {
                throw new InvalidMoveException("Invalid move. No pieces were moved.");
            }
        }

        public void PlacePieces(Player player, int q, int r, int count)
        {
            var cell = _boardManager.GetCell(q, r);
            cell.PlacePieces(count, player.Id);
        }

        public bool PlaceTile(Tile tile, int q, int r)
        {
            if (_boardManager.IsFirstPlacement)
            {
                if (q != 0 || r != 0)
                {
                    throw new InvalidOperationException("The first tile must be placed at (0, 0).");
                }
            }

            return _boardManager.PlaceTile(tile, q, r);
        }

        public void PrintBoard()
        {
            _boardManager.PrintBoardHex();
        }

        public bool CanPlayerMove(Player player)
        {
            foreach (var cell in _boardManager.GetAllCells())
            {
                if (cell.PlayerId == player.Id && cell.PieceCount > 1)
                {
                    for (int directionIndex = 0; directionIndex < 6; directionIndex++)
                    {
                        var (directionQ, directionR) = GetDirectionVector(directionIndex);
                        var nextQ = cell.Q + directionQ;
                        var nextR = cell.R + directionR;

                        if (_boardManager.IsCellValid(nextQ, nextR))
                        {
                            return true;
                        }
                    }
                }
            }

            return false;
        }

        public int GetLargestConnectedSectionSize(Player player)
        {
            var visited = new HashSet<(int q, int r)>();
            int largestSize = 0;

            foreach (var cell in _boardManager.GetAllCells())
            {
                if (cell.PlayerId == player.Id && !visited.Contains((cell.Q, cell.R)))
                {
                    int size = GetConnectedSectionSize(cell, visited);
                    if (size > largestSize)
                    {
                        largestSize = size;
                    }
                }
            }

            return largestSize;
        }

        private int GetConnectedSectionSize(HexCell startCell, HashSet<(int q, int r)> visited)
        {
            var stack = new Stack<HexCell>();
            stack.Push(startCell);
            visited.Add((startCell.Q, startCell.R));
            int size = 0;

            while (stack.Count > 0)
            {
                var cell = stack.Pop();
                size++;

                foreach (var neighbor in _boardManager.GetAdjacentCells(cell.Q, cell.R))
                {
                    if (neighbor.PlayerId == startCell.PlayerId && !visited.Contains((neighbor.Q, neighbor.R)))
                    {
                        stack.Push(neighbor);
                        visited.Add((neighbor.Q, neighbor.R));
                    }
                }
            }

            return size;
        }

        public List<(int q, int r, int orientation)> GetValidTilePlacements(Tile tile)
        {
            var validPlacements = new List<(int q, int r, int orientation)>();

            if (_boardManager.IsFirstPlacement)
            {
                for (int orientation = 0; orientation < 3; orientation++)
                {
                    tile.SetOrientation(orientation);
                    validPlacements.Add((0, 0, orientation));
                }
            }
            else
            {
                foreach (var cell in _boardManager.GetAllCells())
                {
                    for (int orientation = 0; orientation < 3; orientation++)
                    {
                        tile.SetOrientation(orientation);
                        if (tile.CanPlaceOnBoard(_boardManager, cell.Q, cell.R))
                        {
                            validPlacements.Add((cell.Q, cell.R, orientation));
                        }
                    }
                }
            }

            tile.ResetOrientation();

            return validPlacements;
        }

        public List<(int q, int r)> GetValidInitialPiecePlacements()
        {
            var borderCells = _boardManager.GetTrueBorderCells();
            return borderCells;
        }

        public List<(int q, int r, int pieceCount, int playerId)> GetCurrentBoardState()
        {
            var boardState = new List<(int q, int r, int pieceCount, int playerId)>();

            foreach (var cell in _boardManager.GetAllCells())
            {
                if (cell.IsInitialized)
                {
                    boardState.Add((cell.Q, cell.R, cell.PieceCount, cell.PlayerId));
                }
            }

            return boardState;
        }

        public bool CheckForWin()
        {
            foreach (var player in _players)
            {
                if (CanPlayerMove(player))
                {
                    return false;
                }
            }
            return true;
        }

        public void PrintEncodedState(char currentTurn)
        {
            string encodedState = _boardManager.EncodeState(currentTurn);
            Console.WriteLine($"Encoded Game State: {encodedState}");
        }

        public List<(int startQ, int startR, int count, int directionIndex)> GetValidMoves(Player player)
        {
            var validMoves = new List<(int startQ, int startR, int count, int directionIndex)>();

            foreach (var cell in _boardManager.GetAllCells())
            {
                if (cell.PlayerId == player.Id && cell.PieceCount > 1)
                {
                    for (int directionIndex = 0; directionIndex < 6; directionIndex++)
                    {
                        var (directionQ, directionR) = GetDirectionVector(directionIndex);
                        var nextQ = cell.Q + directionQ;
                        var nextR = cell.R + directionR;

                        if (_boardManager.IsCellValid(nextQ, nextR))
                        {
                            for (int count = 1; count < cell.PieceCount; count++)
                            {
                                validMoves.Add((cell.Q, cell.R, count, directionIndex));
                            }
                        }
                    }
                }
            }

            return validMoves;
        }

        public GameManager Clone()
        {
            // Clone the board manager.
            var clonedBoardManager = _boardManager.Clone();
            // Shallow copy of players if they are immutable or if sharing is acceptable.
            var clonedPlayers = new List<Player>(_players);
            return new GameManager(clonedBoardManager, clonedPlayers);
        }
    }
}
