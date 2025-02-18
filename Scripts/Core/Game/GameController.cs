﻿using BattleSheepCore.Board;
using BattleSheepCore.Players;
using Godot;
using System;
using System.Collections.Generic;

namespace BattleSheepCore.Game
{
    public partial class GameController : Node
    {
        private readonly GameManager _gameManager;
        private readonly List<Player> _players;
        public GameController(int boardSize, List<Player> players)
        {
            var boardManager = new BoardManager(boardSize);
            _players = players;
            _gameManager = new GameManager(boardManager, players);
        }
        public List<Player> Players => _players;

        public void StartGame()
        {
            Console.WriteLine("Welcome to the BattleSheep Test Program!");
            Console.WriteLine("\nInitial Board:");
            _gameManager.PrintBoard();
        }

        public bool PlaceTile(Tile tile, int row, int col)
        {
            return _gameManager.PlaceTile(tile, row, col);
        }

        public void PlaceInitialPieces(Player player, int row, int col)
        {
            _gameManager.PlaceInitialPieces(player, row, col);
        }

        public void MovePieces(Player player, int startRow, int startCol, int count, int directionIndex)
        {
            _gameManager.MovePieces(player, startRow, startCol, count, directionIndex);
        }

        public bool CanPlayerMove(Player player)
        {
            return _gameManager.CanPlayerMove(player);
        }

        public int GetLargestConnectedSectionSize(Player player)
        {
            return _gameManager.GetLargestConnectedSectionSize(player);
        }

        public List<(int startRow, int startCol, int count, int directionIndex)> GetValidMoves(Player player)
        {
            return _gameManager.GetValidMoves(player);
        }

        public List<(int q, int r, int orientation)> GetValidTilePlacements(Tile tile)
        {
            return _gameManager.GetValidTilePlacements(tile);
        }

        public List<(int q, int r)> GetValidInitialPiecePlacements()
        {
            return _gameManager.GetValidInitialPiecePlacements();
        }

        public List<(int q, int r, int pieceCount, int playerId)> GetCurrentBoardState()
        {
            return _gameManager.GetCurrentBoardState();
        }

        public bool CheckForWin()
        {
            return _gameManager.CheckForWin();
        }

        public void PrintBoard()
        {
            _gameManager.PrintBoard();
        }
    }
}
