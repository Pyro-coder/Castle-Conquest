using Godot;
using System.Collections.Generic;
using System;
using System.Linq;

namespace BattleSheepCore.Board
{
    /// <summary>
    /// Manages the game board, including the placement of tiles and pieces.
    /// </summary>
    public partial class BoardManager : Node
    {
        private readonly int size;
        private readonly Dictionary<(int q, int r), HexCell> _board;
        private readonly List<(int q, int r, Tile tile)> _placedTiles = new List<(int q, int r, Tile tile)>();
        private readonly List<(int q, int r, char player, int count)> _stacks = new List<(int q, int r, char player, int count)>();
        private bool _isFirstPlacement = true;

        /// <summary>
        /// Initializes a new instance of the <see cref="BoardManager"/> class.
        /// </summary>
        /// <param name="size">The size of the game board.</param>
        public BoardManager(int size)
        {
            this.size = size;
            _board = new Dictionary<(int q, int r), HexCell>();

            // Initialize the board with empty HexCells
            for (var q = -size; q <= size; q++)
            {
                for (var r = -size; r <= size; r++)
                {
                    if (Math.Abs(q + r) <= size)
                    {
                        _board[(q, r)] = new HexCell(q, r);
                    }
                }
            }
        }

        /// <summary>
        /// Adds a tile to the list of placed tiles (for state encoding purposes).
        /// </summary>
        /// <param name="tile">The tile to add.</param>
        /// <param name="q">The Q coordinate of the tile's origin.</param>
        /// <param name="r">The R coordinate of the tile's origin.</param>
        public void AddPlacedTile(Tile tile, int q, int r)
        {
            _placedTiles.Add((q, r, tile));
        }

        /// <summary>
        /// Adds a stack to the list of placed stacks (for state encoding purposes).
        /// </summary>
        /// <param name="q">The Q coordinate of the stack's location.</param>
        /// <param name="r">The R coordinate of the stack's location.</param>
        /// <param name="player">The player ('h' or 't') who owns the stack.</param>
        /// <param name="count">The number of sheep in the stack.</param>
        public void AddStack(int q, int r, char player, int count)
        {
            _stacks.Add((q, r, player, count));
        }

        /// <summary>
        /// Encodes the current game state into a string representation.
        /// </summary>
        /// <param name="currentTurn">The current turn ('h' for Player 1, 't' for Player 2).</param>
        /// <returns>A string representing the current state of the game.</returns>
        public string EncodeState(char currentTurn)
        {
            // Define the orientation mapping
            var orientationMapping = new Dictionary<int, string>
            {
                { 0, "ee" },
                { 1, "ne" },
                { 2, "se" }
            };

            // Encode tiles with the mapped orientation and rebase for "se"
            var tileString = string.Join("|", _placedTiles.Select(t =>
            {
                string orientation = orientationMapping.ContainsKey(t.tile.Orientation)
                    ? orientationMapping[t.tile.Orientation]
                    : t.tile.Orientation.ToString(); // Fallback for unexpected orientations

                // Rebase coordinates for "se"
                int adjustedQ = t.q;
                int adjustedR = t.r;
                if (orientation == "se")
                {
                    adjustedQ -= 1;
                    adjustedR -= 1;
                }

                return $"{adjustedQ},{adjustedR}{orientation}";
            }));

            // Encode stacks
            var stackString = string.Join("|", _stacks.Select(s => $"{s.q},{s.r},{s.player},{s.count}"));

            // Combine and return the encoded state
            return $"{tileString};{stackString};{currentTurn}";
        }



        /// <summary>
        /// Gets a HexCell at a given position.
        /// </summary>
        /// <param name="q">The Q coordinate of the cell.</param>
        /// <param name="r">The R coordinate of the cell.</param>
        /// <returns>The HexCell at the specified position.</returns>
        /// <exception cref="ArgumentException">Thrown when the coordinates are out of bounds.</exception>
        public HexCell GetCell(int q, int r)
        {
            if (!_board.ContainsKey((q, r)))
            {
                throw new ArgumentException("Coordinates are out of bounds.");
            }
            return _board[(q, r)];
        }

        /// <summary>
        /// Gets all cells on the board.
        /// </summary>
        /// <returns>An enumerable collection of all HexCells on the board.</returns>
        public IEnumerable<HexCell> GetAllCells()
        {
            return _board.Values;
        }

        /// <summary>
        /// Gets the adjacent cells based on the hexagonal grid.
        /// </summary>
        /// <param name="q">The Q coordinate of the cell.</param>
        /// <param name="r">The R coordinate of the cell.</param>
        /// <returns>A list of adjacent HexCells.</returns>
        public List<HexCell> GetAdjacentCells(int q, int r)
        {
            var adjacentCells = new List<HexCell>();

            // Define relative offsets for axial coordinates
            var offsets = new (int dq, int dr)[]
            {
                (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)
            };

            foreach (var (dq, dr) in offsets)
            {
                var neighborQ = q + dq;
                var neighborR = r + dr;

                if (_board.ContainsKey((neighborQ, neighborR)))
                {
                    adjacentCells.Add(_board[(neighborQ, neighborR)]);
                }
            }

            return adjacentCells;
        }

        /// <summary>
        /// Checks if a cell is within the bounds of the board.
        /// </summary>
        /// <param name="q">The Q coordinate of the cell.</param>
        /// <param name="r">The R coordinate of the cell.</param>
        /// <returns><c>true</c> if the cell is within bounds; otherwise, <c>false</c>.</returns>
        public bool IsCellWithinBounds(int q, int r)
        {
            return _board.ContainsKey((q, r));
        }

        /// <summary>
        /// Checks if a cell is adjacent to an initialized cell.
        /// </summary>
        /// <param name="q">The Q coordinate of the cell.</param>
        /// <param name="r">The R coordinate of the cell.</param>
        /// <returns><c>true</c> if the cell is adjacent to an initialized cell; otherwise, <c>false</c>.</returns>
        private bool IsAdjacentToInitializedCell(int q, int r)
        {
            var offsets = new (int dq, int dr)[]
            {
                (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)
            };

            foreach (var (dq, dr) in offsets)
            {
                var neighborQ = q + dq;
                var neighborR = r + dr;

                if (_board.ContainsKey((neighborQ, neighborR)) && _board[(neighborQ, neighborR)].IsInitialized)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Places a tile on the board.
        /// </summary>
        /// <param name="tile">The tile to place.</param>
        /// <param name="q">The Q coordinate of the base position.</param>
        /// <param name="r">The R coordinate of the base position.</param>
        /// <returns><c>true</c> if the tile was successfully placed; otherwise, <c>false</c>.</returns>
        public bool PlaceTile(Tile tile, int q, int r)
        {
            // Validate placement
            foreach (var cell in tile.Cells)
            {
                var targetQ = q + cell.Q;
                var targetR = r + cell.R;

                if (!_board.ContainsKey((targetQ, targetR)) || _board[(targetQ, targetR)].IsInitialized)
                {
                    return false; // Invalid placement
                }
            }

            // Check if the tile is adjacent to any initialized cell, unless it's the first placement
            if (!_isFirstPlacement)
            {
                bool isAdjacent = false;
                foreach (var cell in tile.Cells)
                {
                    var targetQ = q + cell.Q;
                    var targetR = r + cell.R;

                    if (IsAdjacentToInitializedCell(targetQ, targetR))
                    {
                        isAdjacent = true;
                        break;
                    }
                }

                if (!isAdjacent)
                {
                    return false; // Not adjacent to any initialized cell
                }
            }

            // Place the tile and initialize the cells
            foreach (var cell in tile.Cells)
            {
                var targetQ = q + cell.Q;
                var targetR = r + cell.R;

                _board[(targetQ, targetR)].InitializeCell();
            }

            // Add the placed tile to the list for encoding
            AddPlacedTile(tile, q, r);

            // Update the flag after the first placement
            _isFirstPlacement = false;

            return true;
        }



        /// <summary>
        /// Checks if a cell is on the edge of the board.
        /// </summary>
        /// <param name="q">The Q coordinate of the cell.</param>
        /// <param name="r">The R coordinate of the cell.</param>
        /// <returns><c>true</c> if the cell is on the edge of the board; otherwise, <c>false</c>.</returns>
        public bool IsEdgeCell(int q, int r)
        {
            var offsets = new (int dq, int dr)[]
            {
                (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)
            };

            foreach (var (dq, dr) in offsets)
            {
                var neighborQ = q + dq;
                var neighborR = r + dr;

                if (_board.ContainsKey((neighborQ, neighborR)) && !_board[(neighborQ, neighborR)].IsInitialized)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Gets the furthest unoccupied hex cell in a given direction.
        /// </summary>
        /// <param name="startQ">The starting Q coordinate.</param>
        /// <param name="startR">The starting R coordinate.</param>
        /// <param name="directionQ">The Q direction vector.</param>
        /// <param name="directionR">The R direction vector.</param>
        /// <returns>The furthest unoccupied HexCell in the given direction.</returns>
        public HexCell GetFurthestUnoccupiedHex(int startQ, int startR, int directionQ, int directionR)
        {
            int currentQ = startQ;
            int currentR = startR;

            while (true)
            {
                int nextQ = currentQ + directionQ;
                int nextR = currentR + directionR;

                if (!_board.ContainsKey((nextQ, nextR)))
                {
                    break; // Out of bounds
                }

                var nextCell = _board[(nextQ, nextR)];

                if (!nextCell.IsInitialized || nextCell.IsOccupied)
                {
                    break; // Hit a blocked or uninitialized cell
                }

                currentQ = nextQ;
                currentR = nextR;
            }

            return _board[(currentQ, currentR)];
        }

        /// <summary>
        /// Checks if a cell is valid for placement.
        /// </summary>
        /// <param name="q">The Q coordinate of the cell.</param>
        /// <param name="r">The R coordinate of the cell.</param>
        /// <returns><c>true</c> if the cell is valid for placement; otherwise, <c>false</c>.</returns>
        public bool IsCellValid(int q, int r)
        {
            if (!_board.ContainsKey((q, r)))
            {
                return false; // The cell is out of bounds.
            }

            var cell = _board[(q, r)];
            return cell.IsInitialized && !cell.IsOccupied;
        }

        /// <summary>
        /// Prints the board for debugging purposes.
        /// </summary>
        public void PrintBoardHex()
        {
            // Loop over rows from -size to +size
            for (int r = -size; r <= size; r++)
            {
                // Indent each row by |r|, multiplied by 2 for spacing
                int leadingSpaces = Math.Abs(r);
                Console.Write(new string(' ', leadingSpaces * 2));

                // For each row, loop columns from -size to +size
                for (int q = -size; q <= size; q++)
                {
                    // Check if (q, r) is within the hex boundaries AND in our board dictionary
                    if (Math.Abs(q + r) <= size && _board.ContainsKey((q, r)))
                    {
                        var cell = _board[(q, r)];

                        // Uninitialized cell
                        if (!cell.IsInitialized)
                        {
                            Console.Write("  . ");
                        }
                        else
                        {
                            // If the cell is occupied, color by PlayerId
                            if (cell.IsOccupied)
                            {
                                if (cell.PlayerId == 1)
                                    Console.ForegroundColor = ConsoleColor.Red;
                                else if (cell.PlayerId == 2)
                                    Console.ForegroundColor = ConsoleColor.Blue;
                                else
                                    Console.ForegroundColor = ConsoleColor.Gray;

                                // Print the piece count (two digits wide)
                                Console.Write($" {cell.PieceCount:D2} ");
                                Console.ResetColor();
                            }
                            else
                            {
                                // An initialized but unoccupied cell
                                Console.Write("  o ");
                            }
                        }
                    }
                }

                // Move to the next row
                Console.WriteLine();
                Console.WriteLine();
            }
        }

        /// <summary>
        /// Returns all uninitialized cells that are connected to the true outer board boundary
        /// (i.e., not part of a "hole" in the middle).
        /// </summary>
        public HashSet<(int q, int r)> GetExternalUninitializedCells()
        {
            var externalUninitialized = new HashSet<(int q, int r)>();
            var visited = new HashSet<(int q, int r)>();
            var queue = new Queue<(int q, int r)>();

            // 1) Identify uninitialized cells on the outer boundary
            foreach (var ((q, r), cell) in _board)
            {
                if (!cell.IsInitialized && IsOnOuterBoardBoundary(q, r))
                {
                    queue.Enqueue((q, r));
                    visited.Add((q, r));
                    externalUninitialized.Add((q, r));
                }
            }

            // 2) BFS through uninitialized cells, starting from the outer boundary
            while (queue.Count > 0)
            {
                var (currentQ, currentR) = queue.Dequeue();

                // Check neighbors
                foreach (var neighbor in GetAdjacentCells(currentQ, currentR))
                {
                    // If neighbor is also uninitialized and not visited, it's external
                    if (!neighbor.IsInitialized)
                    {
                        var neighborPos = (neighbor.Q, neighbor.R);
                        if (!visited.Contains(neighborPos))
                        {
                            visited.Add(neighborPos);
                            externalUninitialized.Add(neighborPos);
                            queue.Enqueue(neighborPos);
                        }
                    }
                }
            }

            return externalUninitialized;
        }

        /// <summary>
        /// Determines if the given coordinates (q, r) are on the outer boundary of the board.
        /// For a hex board of radius 'size', the boundary is where:
        ///     |q| = size or |r| = size or |q + r| = size
        /// </summary>
        private bool IsOnOuterBoardBoundary(int q, int r)
        {
            // Adjust for your specific board definition if needed
            return (Math.Abs(q) == size || Math.Abs(r) == size || Math.Abs(q + r) == size);
        }

        /// <summary>
        /// Returns the truly valid "edge" cells (initialized + unoccupied),
        /// which are adjacent to at least one external uninitialized cell (not a hole).
        /// </summary>
        public List<(int q, int r)> GetTrueBorderCells()
        {
            var validBorderCells = new List<(int q, int r)>();
            var externalUninitialized = GetExternalUninitializedCells();

            // For each initialized, unoccupied cell, check if it touches the external region
            foreach (var ((q, r), cell) in _board)
            {
                if (cell.IsInitialized && !cell.IsOccupied)
                {
                    // Check adjacency to external uninitialized
                    var neighbors = GetAdjacentCells(q, r);
                    bool adjacentToExternal = neighbors
                        .Any(n => externalUninitialized.Contains((n.Q, n.R)));

                    if (adjacentToExternal)
                    {
                        validBorderCells.Add((q, r));
                    }
                }
            }

            return validBorderCells;
        }


        /// <summary>
        /// Gets a value indicating whether it is the first placement on the board.
        /// </summary>
        public bool IsFirstPlacement => _isFirstPlacement;
    }
}
