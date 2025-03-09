/*
using System;
using System.Collections.Generic;
using BattleSheepCore.Board;
using BattleSheepCore.Game;
using BattleSheepCore.Players;
using BattleSheepCore.AI;
using BattleSheepCore.UI;

namespace BattleSheepCore
{
    public class LocalPvAIMode : IGameMode
    {
        private int difficulty;
        private IGameUI ui;

        public LocalPvAIMode(int difficulty, IGameUI ui)
        {
            this.difficulty = difficulty;
            this.ui = ui;
        }

        public void RunGame()
        {
            // Ask the user if they want to go first.
            string input = ui.GetInput("Do you want to go first? (y/n): ");
            bool humanFirst = input.Trim().ToLower() == "y";

            // Set up players: Human (id = 1) and AI (id = 2)
            var humanPlayer = new Player(1, "Human");
            var aiPlayer = new Player(2, "AI");

            // Build turn order based on selection.
            List<Player> turnOrder = humanFirst
                ? new List<Player> { humanPlayer, aiPlayer }
                : new List<Player> { aiPlayer, humanPlayer };

            // Overall players list remains the same.
            var players = new List<Player> { humanPlayer, aiPlayer };

            const int boardSize = 22;
            IGameEngine gameEngine = new GameEngine(boardSize, players);
            ui.ShowMessage("Starting Local PvAI Game...");
            gameEngine.StartGame();
            gameEngine.PrintBoard();

            // Set AI parameters based on difficulty.
            int maxDepth = difficulty switch
            {
                1 => 2,   // Easy
                2 => 4,   // Medium
                3 => 6,   // Hard
                _ => 3
            };

            // Instantiate AI components.
            var aiTile = new ABMinimaxTile(maxDepth, 2);
            int simulationsPerMove = 250 * (maxDepth / 2); 
            var monteCarloAI = new MonteCarloInitialMovement(simulationsPerMove, 2);

            // --- Phase 1: Tile Placement ---
            for (int round = 1; round <= 4; round++)
            {
                ui.ShowMessage($"\n--- Tile Placement Round {round} ---");
                foreach (var player in turnOrder)
                {
                    if (player.Id == 1) // Human turn
                    {
                        ui.ShowMessage("Your turn for tile placement.");
                        var tile = new Tile();
                        var validPlacements = gameEngine.GetValidTilePlacements(tile);

                        ui.ShowMessage("Valid tile placements:");
                        foreach (var placement in validPlacements)
                        {
                            ui.ShowMessage($"Placement: q: {placement.q}, r: {placement.r}, orientation: {placement.orientation}");
                        }

                        bool validInput = false;

                        while (!validInput){
                            string tileInput = ui.GetInput("Enter tile placement parameters (q r orientation): ");
                            var tokens = tileInput.Split(' ');

                            if (tokens.Length == 3 &&
                                int.TryParse(tokens[0], out int q) &&
                                int.TryParse(tokens[1], out int r) &&
                                int.TryParse(tokens[2], out int orientation))
                            {
                                bool isValidMove = validPlacements.Any(m => m.q == q &&
                                                                    m.r == r &&
                                                                    m.orientation == orientation);
                                if (isValidMove)
                                {
                                    gameEngine.PlaceTile(1, q, r, orientation);
                                    validInput = true;
                                }
                                else
                                {
                                    ui.ShowMessage("The move is not valid. Please use a valid move");
                                }
                            }

                            else
                            {
                                ui.ShowMessage("Invalid input, please try agian");
                            }
                        }
                        gameEngine.PrintBoard();
                    }
                    else // AI turn for tile placement
                    {
                        ui.ShowMessage("AI's turn for tile placement.");
                        var bestTile = aiTile.GetBestTilePlacement(gameEngine);
                        ui.ShowMessage($"AI places tile at ({bestTile.q}, {bestTile.r}) with orientation {bestTile.orientation}.");
                        gameEngine.PlaceTile(2, bestTile.q, bestTile.r, bestTile.orientation);
                        gameEngine.PrintBoard();
                    }
                }
            }

            // --- Phase 2: Initial Piece Placement ---
            ui.ShowMessage("\n--- Initial Piece Placement ---");
            foreach (var player in turnOrder)
            {
                if (player.Id == 1) // Human initial placement
                {
                    ui.ShowMessage("Your turn for initial piece placement.");
                    var validInitialPlacements = gameEngine.GetValidInitialPiecePlacements();
                    ui.ShowMessage("Valid initial placements:");
                    foreach (var placement in validInitialPlacements)
                    {
                        ui.ShowMessage($"Placement: q: {placement.q}, r: {placement.r}");
                    }

                    bool validInput = false;

                    while (!validInput)
                    {
                        string initInput = ui.GetInput("Enter initial placement parameters (q r): ");
                        var tokens = initInput.Split(' ');
                        if (tokens.Length == 2 &&
                            int.TryParse(tokens[0], out int q) &&
                            int.TryParse(tokens[1], out int r))
                        {
                            bool isValidMove = validInitialPlacements.Any(m => m.q == q &&
                                                                    m.r == r);
                            if (isValidMove)
                            {
                                gameEngine.PlaceInitialPieces(1, q, r);
                                validInput = true;
                            }
                            else
                            {
                                ui.ShowMessage("The move is not valid. Please use a valid move");
                            }

                            
                        }

                        else
                        {
                            ui.ShowMessage("Invalid input, please try agian");
                        }
                    }
                    

                    gameEngine.PrintBoard();
                }

                else // AI initial placement using Monte Carlo.
                {
                    ui.ShowMessage("AI's turn for initial piece placement.");
                    var bestInitial = monteCarloAI.GetBestInitialPlacement(gameEngine);
                    ui.ShowMessage($"AI places initial pieces at ({bestInitial.q}, {bestInitial.r}).");
                    gameEngine.PlaceInitialPieces(2, bestInitial.q, bestInitial.r);
                    gameEngine.PrintBoard();
                }
            }

            // --- Phase 3: Move Phase ---
            ui.ShowMessage("\n--- Move Phase ---");
            bool gameOver = false;
            while (!gameEngine.CheckForWin() && !gameOver)
            {
                foreach (var player in turnOrder)
                {
                    if (!gameEngine.CanPlayerMove(player.Id))
                    {
                        ui.ShowMessage($"{player.Name} cannot move. Game over.");
                        gameOver = true;
                        break;
                    }
                    if (player.Id == 1) // Human move
                    {
                        ui.ShowMessage("Your turn to move.");
                        var validMoves = gameEngine.GetValidMoves(1);
                        ui.ShowMessage("Valid moves:");
                        foreach (var move in validMoves)
                        {
                            ui.ShowMessage($"Move {move.count} pieces from ({move.startRow}, {move.startCol}) in direction {move.directionIndex}");
                        }

                        bool validInput = false;

                        while (!validInput) 
                        {
                            string moveInput = ui.GetInput("Enter move parameters (startRow startCol count directionIndex): ");
                            var tokens = moveInput.Split(' ');
                            if (tokens.Length == 4 &&
                                int.TryParse(tokens[0], out int startRow) &&
                                int.TryParse(tokens[1], out int startCol) &&
                                int.TryParse(tokens[2], out int count) &&
                                int.TryParse(tokens[3], out int directionIndex))
                            {
                                bool isValidMove = validMoves.Any(m => m.startRow == startRow &&
                                                                    m.startCol == startCol &&
                                                                    m.count == count &&
                                                                    m.directionIndex == directionIndex);
                                if (isValidMove)
                                {
                                    gameEngine.MovePieces(1, startRow, startCol, count, directionIndex);
                                    validInput = true;
                                }
                                else
                                {
                                    ui.ShowMessage("The move is not valid. Please use a valid move");
                                }
                            }

                            else
                            {
                                ui.ShowMessage("Invalid input, please try agian");
                            }
                        }

                        gameEngine.PrintBoard();
                    }
                    else // AI move using Monte Carlo.
                    {
                        ui.ShowMessage("AI's turn to move.");
                        if (!gameEngine.CanPlayerMove(2))
                        {
                            ui.ShowMessage("AI cannot move. Game over.");
                            gameOver = true;
                            break;
                        }
                        var bestMove = monteCarloAI.GetBestMovement(gameEngine);
                        ui.ShowMessage($"AI moves {bestMove.count} pieces from ({bestMove.startRow}, {bestMove.startCol}) in direction {bestMove.directionIndex}");
                        gameEngine.MovePieces(2, bestMove.startRow, bestMove.startCol, bestMove.count, bestMove.directionIndex);
                        gameEngine.PrintBoard();
                    }
                }
            }
            ui.ShowMessage("Game Over. Final Board State:");
            gameEngine.PrintBoard();
        }
    }
}
*/