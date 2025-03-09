/*

using System;
using System.Collections.Generic;
using BattleSheepCore.Board;
using BattleSheepCore.Game;
using BattleSheepCore.Players;
using BattleSheepCore.UI;

namespace BattleSheepCore
{
    public class LocalPvPMode : IGameMode
    {
        private IGameUI ui;

        public LocalPvPMode(IGameUI ui)
        {
            this.ui = ui;
        }

        public void RunGame()
        {
            // Set up two human players.
            var player1 = new Player(1, "Player 1");
            var player2 = new Player(2, "Player 2");
            var players = new List<Player> { player1, player2 };

            const int boardSize = 22;
            IGameEngine gameEngine = new GameEngine(boardSize, players);

            ui.ShowMessage("Starting Local PvP Game...");
            gameEngine.StartGame();
            gameEngine.PrintBoard();

            // --- Phase 1: Tile Placement (4 rounds) ---
            for (int round = 1; round <= 4; round++)
            {
                ui.ShowMessage($"\n--- Tile Placement Round {round} ---");
                foreach (var player in players)
                {
                    ui.ShowMessage($"{player.Name}'s turn for tile placement.");
                    var tile = new Tile();
                    var validPlacements = gameEngine.GetValidTilePlacements(tile);
                    ui.ShowMessage("Valid tile placements:");
                    foreach (var placement in validPlacements)
                    {
                        ui.ShowMessage($"Placement: q: {placement.q}, r: {placement.r}, orientation: {placement.orientation}");
                    }
                    string input = ui.GetInput("Enter tile placement parameters (q r orientation): ");
                    if (!string.IsNullOrEmpty(input))
                    {
                        var tokens = input.Split(' ');
                        if (tokens.Length == 3 &&
                            int.TryParse(tokens[0], out int q) &&
                            int.TryParse(tokens[1], out int r) &&
                            int.TryParse(tokens[2], out int orientation))
                        {
                            gameEngine.PlaceTile(player.Id, q, r, orientation);
                        }
                        else
                        {
                            ui.ShowMessage("Invalid input, skipping turn.");
                        }
                    }
                    else
                    {
                        ui.ShowMessage("No input, skipping turn.");
                    }
                    gameEngine.PrintBoard();
                }
            }

            // --- Phase 2: Initial Piece Placement ---
            ui.ShowMessage("\n--- Initial Piece Placement ---");
            foreach (var player in players)
            {
                ui.ShowMessage($"{player.Name}'s turn for initial piece placement.");
                var validInitialPlacements = gameEngine.GetValidInitialPiecePlacements();
                ui.ShowMessage("Valid initial placements:");
                foreach (var placement in validInitialPlacements)
                {
                    ui.ShowMessage($"Placement: q: {placement.q}, r: {placement.r}");
                }
                string initInput = ui.GetInput("Enter initial placement parameters (q r): ");
                if (!string.IsNullOrEmpty(initInput))
                {
                    var tokens = initInput.Split(' ');
                    if (tokens.Length == 2 &&
                        int.TryParse(tokens[0], out int q) &&
                        int.TryParse(tokens[1], out int r))
                    {
                        gameEngine.PlaceInitialPieces(player.Id, q, r);
                    }
                    else
                    {
                        ui.ShowMessage("Invalid input, skipping turn.");
                    }
                }
                else
                {
                    ui.ShowMessage("No input, skipping turn.");
                }
                gameEngine.PrintBoard();
            }

            // --- Phase 3: Move Phase ---
            ui.ShowMessage("\n--- Move Phase ---");
            bool gameOver = false;
            while (!gameEngine.CheckForWin() && !gameOver)
            {
                foreach (var player in players)
                {
                    if (!gameEngine.CanPlayerMove(player.Id))
                    {
                        ui.ShowMessage($"{player.Name} cannot move. Game over.");
                        gameOver = true;
                        break;
                    }
                    ui.ShowMessage($"{player.Name}'s turn to move.");
                    var validMoves = gameEngine.GetValidMoves(player.Id);
                    ui.ShowMessage("Valid moves:");
                    foreach (var move in validMoves)
                    {
                        ui.ShowMessage($"Move {move.count} pieces from ({move.startRow}, {move.startCol}) in direction {move.directionIndex}");
                    }
                    string moveInput = ui.GetInput("Enter move parameters (startRow startCol count directionIndex): ");
                    if (!string.IsNullOrEmpty(moveInput))
                    {
                        var tokens = moveInput.Split(' ');
                        if (tokens.Length == 4 &&
                            int.TryParse(tokens[0], out int startRow) &&
                            int.TryParse(tokens[1], out int startCol) &&
                            int.TryParse(tokens[2], out int count) &&
                            int.TryParse(tokens[3], out int directionIndex))
                        {
                            gameEngine.MovePieces(player.Id, startRow, startCol, count, directionIndex);
                        }
                        else
                        {
                            ui.ShowMessage("Invalid input, skipping turn.");
                        }
                    }
                    else
                    {
                        ui.ShowMessage("No input, skipping turn.");
                    }
                    gameEngine.PrintBoard();
                }
            }
            ui.ShowMessage("Game Over. Final Board State:");
            gameEngine.PrintBoard();
        }
    }
}
*/