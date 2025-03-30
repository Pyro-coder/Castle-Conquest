using BattleSheepCore.Board;
using BattleSheepCore.Players;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BattleSheepCore.Game;
using Godot;
using Godot.Collections;

namespace BattleSheepCore.Game
{
	/// <summary>
	/// The GameEngine class serves as the main interface for the game, encapsulating the game logic and interactions.
	/// </summary>
	///
	[GlobalClass]
	public partial class GameEngine : Node, IGameEngine
	{
		private readonly GameController _gameController;

		private int boardSize;

		public int BoardSize => boardSize;

		/// <summary>
		/// Initializes a new instance of the <see cref="GameEngine"/> class.
		/// </summary>
		/// <param name="boardSize">The size of the game board.</param>
		/// <param name="players">The list of players participating in the game.</param>
		public GameEngine()
		{
			this.boardSize = 22;
			var humanPlayer = new Player();
			humanPlayer.Initialize(1, "Human");
			var aiPlayer = new Player();
			aiPlayer.Initialize(2, "AI");
			var players = new List<Player> { humanPlayer, aiPlayer };

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

		public void PrintBoard()
		{
			_gameController.PrintBoard();
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

		public Godot.Collections.Array GodotGetValidMoves(int playerId)
		{
			var valid = GetValidMoves(playerId);

			var arrayOfDicts = new Godot.Collections.Array();

			foreach (var placement in valid)
			{
				// Create a Godot dictionary for each placement.
				Dictionary placementDict = new Dictionary();
				placementDict["startRow"] = placement.startRow;
				placementDict["startCol"] = placement.startCol;
				placementDict["count"] = placement.count;
				placementDict["directionIndex"] = placement.directionIndex;

				arrayOfDicts.Add(placementDict);
			}

			return arrayOfDicts;
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

		public Godot.Collections.Array GodotGetValidTile()
		{
			var tile = new Tile();
			var validPlacements = _gameController.GetValidTilePlacements(tile);
			var arrayOfDicts = new Godot.Collections.Array();

			foreach (var placement in validPlacements)
			{
				// Create a Godot dictionary for each placement.
				Dictionary placementDict = new Dictionary();
				placementDict["q"] = placement.q;
				placementDict["r"] = placement.r;
				placementDict["orientation"] = placement.orientation;

				arrayOfDicts.Add(placementDict);
			}

			return arrayOfDicts;
		}

		// THESE TWO FUNCTIONS ARE IMPORTANT FOR IVY
		public void PlacePieces(int playerId, int q, int r, int count)
		{
			Player player = new Player();
			player.Initialize(playerId, "user");
			_gameController.PlacePieces(player, q, r, count);
		}

		public void InitializeCell(int q, int r)
		{
			_gameController.InitializeCell(q, r);
		}

		/// <summary>
		/// Gets the valid initial piece placements on the board.
		/// </summary>
		/// <returns>A list of valid initial piece placements as tuples of (q, r).</returns>
		public List<(int q, int r)> GetValidInitialPiecePlacements()
		{
			return _gameController.GetValidInitialPiecePlacements();
		}

		public Godot.Collections.Array GodotGetValidInitial()
		{
			var valid = GetValidInitialPiecePlacements();

			var arrayOfDicts = new Godot.Collections.Array();

			foreach (var placement in valid)
			{
				// Create a Godot dictionary for each placement.
				Dictionary placementDict = new Dictionary();
				placementDict["q"] = placement.q;
				placementDict["r"] = placement.r;

				arrayOfDicts.Add(placementDict);
			}

			return arrayOfDicts;
		}

		/// <summary>
		/// Gets the current state of the game board.
		/// </summary>
		/// <returns>The current state of the game board.</returns>
		public List<(int q, int r, int pieceCount, int playerId)> AIGetCurrentBoardState()
		{
			return _gameController.GetCurrentBoardState();
		}

		public Godot.Collections.Array GetCurrentBoardState()
		{
			var boardState = _gameController.GetCurrentBoardState();
			var listOfDicts = new Godot.Collections.Array();

			foreach (var cell in boardState)
			{
				// Create a Godot dictionary for each cell with the proper keys.
				var cellDict = new Dictionary();
				cellDict["q"] = cell.q;
				cellDict["r"] = cell.r;
				cellDict["pieceCount"] = cell.pieceCount;
				cellDict["playerId"] = cell.playerId;

				listOfDicts.Add(cellDict);
			}

			return listOfDicts;
		}

		/// <summary>
		/// Checks if there is a valid win condition.
		/// </summary>
		/// <returns>True if there is a valid win condition, otherwise false.</returns>
		public bool CheckForWin()
		{
			return _gameController.CheckForWin();
		}

		// Clone the entire game engine.
		public GameEngine Clone()
		{
			var clonedController = _gameController.Clone();
			return new GameEngine(clonedController);
		}

		IGameEngine IGameEngine.Clone()
		{
			return Clone();
		}

		// Private constructor for cloning.
		private GameEngine(GameController clonedController)
		{
			_gameController = clonedController;
		}

		public Godot.Collections.Dictionary<string, int> GetFurthestUnoccupiedHexCoords(int startQ, int startR, int directionIndex)
		{
			var hex = _gameController.GetFurthestUnoccupiedHex(startQ, startR, directionIndex);
			var returnValue = new Godot.Collections.Dictionary<string, int>
			{
				{ "q", hex.Q },
				{ "r", hex.R },
				{ "i", directionIndex }
			};

			return returnValue;
		}

		public void changeNotFirstTilePlacement()
		{
			_gameController.changeNotFirstTilePlacement();

		}
	}
}
