using Godot;
using System;

namespace BattleSheepCore.Board
{
    /// <summary>
    /// Represents a hexagonal cell on the game board.
    /// </summary>
    public partial class HexCell : Node
    {
        /// <summary>
        /// Gets or sets the Q coordinate (axial column) of the cell.
        /// </summary>
        public int Q { get; set; }

        /// <summary>
        /// Gets or sets the R coordinate (axial row) of the cell.
        /// </summary>
        public int R { get; set; }

        /// <summary>
        /// Gets a value indicating whether the cell is occupied by any pieces.
        /// </summary>
        public bool IsOccupied => PieceCount > 0;

        /// <summary>
        /// Gets a value indicating whether the cell is initialized.
        /// </summary>
        public bool IsInitialized => PieceCount != -1;

        /// <summary>
        /// Gets or sets the ID of the player who controls the cell. -1 means no player has control.
        /// </summary>
        public int PlayerId { get; set; } = -1;

        /// <summary>
        /// Gets or sets the number of pieces on the cell. -1 means the cell is uninitialized.
        /// </summary>
        public int PieceCount { get; set; } = -1;

        /// <summary>
        /// Initializes a new instance of the <see cref="HexCell"/> class with the specified coordinates.
        /// </summary>
        /// <param name="q">The Q coordinate (axial column) of the cell.</param>
        /// <param name="r">The R coordinate (axial row) of the cell.</param>
        public HexCell(int q, int r)
        {
            Q = q;
            R = r;
        }

        /// <summary>
        /// Initializes the cell, setting the piece count to 0.
        /// </summary>
        /// <exception cref="InvalidOperationException">Thrown when the cell is already initialized.</exception>
        public void InitializeCell()
        {
            if (IsInitialized)
            {
                throw new InvalidOperationException("Cell is already initialized.");
            }
            PieceCount = 0; // Set to 0 once initialized
        }

        /// <summary>
        /// Places pieces on the cell.
        /// </summary>
        /// <param name="count">The number of pieces to place.</param>
        /// <param name="playerId">The ID of the player placing the pieces.</param>
        /// <exception cref="ArgumentException">Thrown when the count is not positive.</exception>
        /// <exception cref="InvalidOperationException">Thrown when the cell is uninitialized or occupied by another player.</exception>
        public void PlacePieces(int count, int playerId)
        {
            if (count <= 0)
                throw new ArgumentException("Count must be positive.");

            if (!IsInitialized)
                throw new InvalidOperationException("Cannot place pieces on uninitialized cell.");

            if (PieceCount > 0 && PlayerId != playerId)
                throw new InvalidOperationException("Cell is occupied by another player.");

            PieceCount += count;
            PlayerId = playerId;
        }

        /// <summary>
        /// Removes pieces from the cell.
        /// </summary>
        /// <param name="count">The number of pieces to remove.</param>
        /// <exception cref="ArgumentException">Thrown when the count is not positive.</exception>
        /// <exception cref="InvalidOperationException">Thrown when there are not enough pieces to remove.</exception>
        public void RemovePieces(int count)
        {
            if (count <= 0)
                throw new ArgumentException("Count must be positive.");

            if (PieceCount < count)
                throw new InvalidOperationException("Not enough pieces to remove.");

            PieceCount -= count;

            if (PieceCount == 0)
            {
                PlayerId = -1;
            }
        }

        /// <summary>
        /// Returns a string that represents the current cell.
        /// </summary>
        /// <returns>A string that represents the current cell.</returns>
        public override string ToString()
        {
            return IsInitialized
                ? $"HexCell(Q: {Q}, R: {R}, PlayerId: {PlayerId}, PieceCount: {PieceCount})"
                : $"HexCell(Q: {Q}, R: {R}, Uninitialized)";
        }
    }
}

