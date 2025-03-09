using System.Collections.Generic;
using BattleSheepCore.Board;

namespace BattleSheepCore
{
    public interface IGameEngine
    {
        int BoardSize { get; }
        IGameEngine Clone();
        List<(int q, int r, int orientation)> GetValidTilePlacements(Tile tile);
        List<(int q, int r)> GetValidInitialPiecePlacements();
        List<(int startRow, int startCol, int count, int directionIndex)> GetValidMoves(int playerId);
        void PlaceTile(int playerId, int q, int r, int orientation);
        void PlaceInitialPieces(int playerId, int q, int r);
        void MovePieces(int playerId, int startRow, int startCol, int count, int directionIndex);
        bool CanPlayerMove(int playerId);
        bool CheckForWin();
        int GetLargestConnectedSectionSize(int playerId);
        List<(int q, int r, int pieceCount, int playerId)> AIGetCurrentBoardState();
        void PrintBoard();
        void StartGame();
    }
}
