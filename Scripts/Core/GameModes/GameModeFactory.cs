/*
using System;
using BattleSheepCore.UI;

namespace BattleSheepCore
{
	public static class GameModeFactory
	{
		public static IGameMode CreateGameMode(string modeInput, IGameUI ui)
		{
			switch (modeInput)
			{
				case "1":
					return new LocalPvPMode(ui);
				case "2":
					string diffInput = ui.GetInput("Enter AI difficulty (1 = Easy, 2 = Medium, 3 = Hard): ");
					int difficulty = int.TryParse(diffInput, out int d) ? d : 2;
					return new LocalPvAIMode(difficulty, ui);
				case "3":
					return new OnlinePvPMode(ui);
				case "4":
					return new OnlineAIMode(ui);
				default:
					throw new ArgumentException("Invalid game mode.");
			}
		}
	}
}
*/
