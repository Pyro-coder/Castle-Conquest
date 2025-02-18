using Godot;
using System;
using System.Collections.Generic;

namespace BattleSheepCore.Board
{
	/// <summary>
	/// Represents a tile consisting of multiple hexagonal cells.
	/// </summary>
	public partial class Tile : Node
	{
		/// <summary>
		/// Gets the hex cells within the tile.
		/// </summary>
		public List<HexCell> Cells { get; private set; }

		/// <summary>
		/// Exposes the current orientation of the tile.
		/// </summary>
		public int Orientation => _currentOrientation;

		/// <summary>
		/// Predefined orientations of the tile.
		/// </summary>
		private readonly List<List<(int q, int r)>> _orientations;

		/// <summary>
		/// The current orientation index of the tile.
		/// </summary>
		private int _currentOrientation;

		/// <summary>
		/// Initializes a new instance of the <see cref="Tile"/> class.
		/// </summary>
		public Tile()
		{
			Cells = new List<HexCell>();

			// Define predefined orientations
			_orientations = new List<List<(int q, int r)>>
			{
				new List<(int q, int r)>
				{
					(0, 0), (1, 0), (1, -1), (2, -1) // Original orientation
				},
				new List<(int q, int r)>
				{
					(0, 0), (0, 1), (-1, 1), (-1, 2) // Rotated 120° clockwise
				},
				new List<(int q, int r)>
				{
					(0, 0), (-1, 0), (0, -1), (-1, -1) // Rotated 240° clockwise
				}
			};

			// Set the initial orientation
			SetOrientation(0);
		}

		/// <summary>
		/// Sets the tile's cells based on the given orientation.
		/// </summary>
		/// <param name="orientationIndex">The index of the orientation to set.</param>
		public void SetOrientation(int orientationIndex)
		{
			_currentOrientation = orientationIndex;
			Cells.Clear();

			foreach (var (q, r) in _orientations[_currentOrientation])
			{
				Cells.Add(new HexCell(q, r));
			}
		}

		/// <summary>
		/// Rotates the tile to the next orientation (120° clockwise).
		/// </summary>
		public void RotateClockwise()
		{
			_currentOrientation = (_currentOrientation + 1) % _orientations.Count; // Cycle through orientations
			SetOrientation(_currentOrientation);
		}

		/// <summary>
		/// Rotates the tile to the previous orientation (120° counterclockwise).
		/// </summary>
		public void RotateCounterClockwise()
		{
			_currentOrientation = (_currentOrientation - 1 + _orientations.Count) % _orientations.Count; // Cycle backwards
			SetOrientation(_currentOrientation);
		}

		/// <summary>
		/// Resets the tile's orientation to the original.
		/// </summary>
		public void ResetOrientation()
		{
			SetOrientation(0);
		}

		/// <summary>
		/// Determines whether the tile can be placed on the board at the specified position.
		/// </summary>
		/// <param name="boardManager">The board manager.</param>
		/// <param name="baseQ">The base Q coordinate on the board.</param>
		/// <param name="baseR">The base R coordinate on the board.</param>
		/// <returns><c>true</c> if the tile can be placed on the board; otherwise, <c>false</c>.</returns>
		public bool CanPlaceOnBoard(BoardManager boardManager, int baseQ, int baseR)
		{
			bool isAdjacentToInitializedCell = false;

			foreach (var cell in Cells)
			{
				var targetQ = baseQ + cell.Q;
				var targetR = baseR + cell.R;

				// Check if the cell exists on the board
				if (!boardManager.IsCellWithinBounds(targetQ, targetR))
				{
					// Cell is out of bounds
					return false;
				}

				var targetCell = boardManager.GetCell(targetQ, targetR);

				// Check if the cell is already initialized (i.e., occupied)
				if (targetCell.IsInitialized)
				{
					// Cannot place over an initialized cell
					return false;
				}

				// Check for adjacency to initialized cells
				foreach (var neighbor in boardManager.GetAdjacentCells(targetQ, targetR))
				{
					if (neighbor.IsInitialized)
					{
						isAdjacentToInitializedCell = true;
						break;
					}
				}
			}

			return isAdjacentToInitializedCell;
		}

		/// <summary>
		/// Prints the current tile configuration for debugging purposes.
		/// </summary>
		public void PrintTile()
		{
			Console.WriteLine("Current Tile Configuration:");
			foreach (var cell in Cells)
			{
				Console.WriteLine($"Cell: (Q: {cell.Q}, R: {cell.R})");
				Console.WriteLine($"Current Orientation: {_currentOrientation}");
			}
		}
	}
}
