using BattleSheepCore.Game;
using Godot;

namespace BattleSheepCore.Players
{
	/// <summary>
	/// Represents a player in the game.
	/// </summary>
	/// 
	[GlobalClass]
	public partial class Player : Node
	{
		/// <summary>
		/// Gets the player's ID.
		/// </summary>
		public int Id { get; private set; }

		/// <summary>
		/// Gets the player's name.
		/// </summary>
		public string Name { get; private set; }

		/// <summary>
		/// Gets the player's score.
		/// </summary>
		public int Score { get; private set; }

		/// <summary>
		/// Initializes a new instance of the <see cref="Player"/> class with the specified ID and name.
		/// </summary>
		/// <param name="id">The player's ID.</param>
		/// <param name="name">The player's name.</param>
		public Player() { }

		public void Initialize(int id, string name)
		{
			Id = id;
			Name = name;
			Score = 0;
		}

		/// <summary>
		/// Places the player's initial pieces on the board.
		/// </summary>
		/// <param name="gameManager">The game manager.</param>
		/// <param name="q">The Q coordinate of the cell.</param>
		/// <param name="r">The R coordinate of the cell.</param>
		public void InitialPlacement(GameManager gameManager, int q, int r)
		{
			gameManager.PlaceInitialPieces(this, q, r);
		}

		/// <summary>
		/// Moves the player's pieces on the board.
		/// </summary>
		/// <param name="gameManager">The game manager.</param>
		/// <param name="startQ">The starting Q coordinate of the pieces.</param>
		/// <param name="startR">The starting R coordinate of the pieces.</param>
		/// <param name="count">The number of pieces to move.</param>
		/// <param name="directionIndex">The direction index to move the pieces.</param>
		public void MovePieces(GameManager gameManager, int startQ, int startR, int count, int directionIndex)
		{
			gameManager.MovePieces(this, startQ, startR, count, directionIndex);
		}

		/// <summary>
		/// Increments the player's score by one.
		/// </summary>
		public void IncrementScore()
		{
			Score++;
		}
	}
}
