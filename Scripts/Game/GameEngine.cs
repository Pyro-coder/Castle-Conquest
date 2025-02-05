using BattleSheepCore.Board;
using BattleSheepCore.Players;
using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

namespace BattleSheepCore.Game
{
    /// <summary>
    /// The GameEngine class serves as the main interface for the game, encapsulating the game logic and interactions.
    /// </summary>
    public partial class GameEngine : Node
    {
        private readonly GameController _gameController;

        /// <summary>
        /// Initializes a new instance of the <see cref="GameEngine"/> class.
        /// </summary>
        /// <param name="boardSize">The size of the game board.</param>
        /// <param name="players">The list of players participating in the game.</param>
        public GameEngine(int boardSize, List<Player> players)
        {
            _gameController = new GameController(boardSize, players);
        }

        /// <summary>
        /// Starts the game.
        /// </summary>
        public void StartGame()
        {
            _gameController.StartGame();
        }

        /// <summary>
        /// Places a tile on the board.
        /// </summary>
        /// <param name="playerId">The ID of the player placing the tile.</param>
        /// <param name="row">The row position on the board.</param>
        /// <param name="col">The column position on the board.</param>
        /// <param name="orientation">The orientation of the tile.</param>
        public void PlaceTile(int playerId, int row, int col, int orientation)
        {
            var player = _gameController.Players.First(p => p.Id == playerId);
            var tile = new Tile();
            for (int i = 0; i < orientation; i++)
            {
                tile.RotateClockwise();
            }

            try
            {
                if (_gameController.PlaceTile(tile, row, col))
                {
                    Console.WriteLine($"Tile placed at ({row}, {col}) with orientation {orientation}.");
                    _gameController.PrintBoard();
                }
                else
                {
                    Console.WriteLine("Failed to place tile. Check bounds or overlapping cells.");
                }
            }
            catch (InvalidOperationException ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        /// <summary>
        /// Places initial pieces on the board.
        /// </summary>
        /// <param name="playerId">The ID of the player placing the pieces.</param>
        /// <param name="row">The row position on the board.</param>
        /// <param name="col">The column position on the board.</param>
        public void PlaceInitialPieces(int playerId, int row, int col)
        {
            var player = _gameController.Players.First(p => p.Id == playerId);
            _gameController.PlaceInitialPieces(player, row, col);
        }

        /// <summary>
        /// Moves pieces on the board.
        /// </summary>
        /// <param name="playerId">The ID of the player moving the pieces.</param>
        /// <param name="startRow">The starting row position of the pieces.</param>
        /// <param name="startCol">The starting column position of the pieces.</param>
        /// <param name="count">The number of pieces to move.</param>
        /// <param name="directionIndex">The direction index to move the pieces.</param>
        public void MovePieces(int playerId, int startRow, int startCol, int count, int directionIndex)
        {
            var player = _gameController.Players.First(p => p.Id == playerId);
            _gameController.MovePieces(player, startRow, startCol, count, directionIndex);
        }

        /// <summary>
        /// Checks if a player can move.
        /// </summary>
        /// <param name="playerId">The ID of the player.</param>
        /// <returns>True if the player can move, otherwise false.</returns>
        public bool CanPlayerMove(int playerId)
        {
            var player = _gameController.Players.First(p => p.Id == playerId);
            return _gameController.CanPlayerMove(player);
        }

        /// <summary>
        /// Gets the size of the largest connected section for a player.
        /// </summary>
        /// <param name="playerId">The ID of the player.</param>
        /// <returns>The size of the largest connected section.</returns>
        public int GetLargestConnectedSectionSize(int playerId)
        {
            var player = _gameController.Players.First(p => p.Id == playerId);
            return _gameController.GetLargestConnectedSectionSize(player);
        }

        /// <summary>
        /// Gets the valid moves for a player.
        /// </summary>
        /// <param name="playerId">The ID of the player.</param>
        /// <returns>A list of valid moves as tuples of (startRow, startCol, count, directionIndex).</returns>
        public List<(int startRow, int startCol, int count, int directionIndex)> GetValidMoves(int playerId)
        {
            var player = _gameController.Players.First(p => p.Id == playerId);
            return _gameController.GetValidMoves(player);
        }

        /// <summary>
        /// Gets the valid tile placements on the board.
        /// </summary>
        /// <param name="tile">The tile to place.</param>
        /// <returns>A list of valid tile placements as tuples of (q, r, orientation).</returns>
        public List<(int q, int r, int orientation)> GetValidTilePlacements(Tile tile)
        {
            return _gameController.GetValidTilePlacements(tile);
        }

        /// <summary>
        /// Gets the valid initial piece placements on the board.
        /// </summary>
        /// <returns>A list of valid initial piece placements as tuples of (q, r).</returns>
        public List<(int q, int r)> GetValidInitialPiecePlacements()
        {
            return _gameController.GetValidInitialPiecePlacements();
        }

        /// <summary>
        /// Gets the current state of the game board.
        /// </summary>
        /// <returns>The current state of the game board.</returns>
        public List<(int q, int r, int pieceCount, int playerId)> GetCurrentBoardState()
        {
            return _gameController.GetCurrentBoardState();
        }

        /// <summary>
        /// Checks if there is a valid win condition.
        /// </summary>
        /// <returns>True if there is a valid win condition, otherwise false.</returns>
        public bool CheckForWin()
        {
            return _gameController.CheckForWin();
        }
    }
}

