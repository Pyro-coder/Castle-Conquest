using System;
using System.Buffers;
using System.Net.Http;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Godot;
using System.Linq;
using BattleSheepCore.Game;
using BattleSheepCore.AI;
using BattleSheepCore.Players;
using BattleSheepCore.Board;
using System.Diagnostics;
using static Godot.WebSocketPeer;
using BattleSheepCore;
using System.Reflection.Metadata;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics.X86;


namespace Capstone25.Scripts.Core.Networking
{
	[GlobalClass]
	public partial class NetworkAi : Node
	{

        private bool _isRunning = false;

        private class Game
		{
			public string State { get; set; }
			public string action_id { get; set; }

			public string player = "castleconquest";

			public string token = "w_2jZ-tsd7MQFrd2Fs9K3XMKrSyJGDJ6DDz3JxQSjVI";


			public GameEngine gameEngine = new GameEngine();

			public ABMinimaxTile tileAI = new ABMinimaxTile();

			public MonteCarloInitialMovement movementAi = new MonteCarloInitialMovement();


			public Game()
			{
				tileAI.Initialize(10, 1);
				movementAi.Initialize(800, 1);
			}

            ~Game()
            {
				tileAI.QueueFree();
				movementAi.QueueFree();
            }
		}

		public override void _Ready()
		{
            _isRunning = true;

            GD.Print("NetworkAi initialized!");

			_ = Client.ProcessGameLogic(this);
		}

        public override void _ExitTree()
        {
            _isRunning = false;
            GD.Print("Exiting scene, stopping game logic");
        }

        private class Client
		{

			private static Game game = new();
			//private static GameEngine gameEngine = new GameEngine();


			private static readonly string baseUrl = "https://softserve.harding.edu/";
			private static readonly System.Net.Http.HttpClient client = new System.Net.Http.HttpClient();

		   
			public static async Task ProcessGameLogic(NetworkAi Owner)
			{
		
				//Game game = new Game();
				string winner = "none";

				dynamic playState;
				string State;
				char turn;
				int[,] parsedState;

				while (Owner._isRunning)
				{
					//SET UP THE GAME ENGINE
					playState = await GetPlayStateAsync();
					
					while(playState == null){
						await Task.Delay(1000);
						//GD.Print("Waiting for play state");
						playState = await GetPlayStateAsync();
					}
					
					State = playState.state;
					GD.Print(State);

					string state = playState.state;
					turn = State[State.Length - 1];

					parsedState = ParseState(state);

					var gameEngine = SetUpGameEngine(parsedState);

					
					
					//DETERMINE ACTION TO PLAY BASED ON STATE 
					int gamePhase = DetermineGamePhase(state);
					GD.Print($"Detected game phase: {gamePhase}");
					string moveString = "";

					if (gamePhase == 1)
					{
						//tile placement
						GD.Print("I am in phase 1");
						moveString = GetBestTilePlacementFromAI(gameEngine);
						GD.Print(moveString);
					}
					else if (gamePhase == 2)
					{
						//initial stack placement
						GD.Print("I am in phase 2");
						moveString = GetBestInitialStackPlacementFromAI(gameEngine);
						GD.Print(moveString);
					}
					else if (gamePhase == 3)
					{
						//movement
						GD.Print("I am in phase 3");
						moveString = await GetBestMovementFromAI(gameEngine, turn);
						GD.Print(moveString);
					}


					winner = await SubmitActionAsync(moveString, playState.action_id);
				}
			}


			private static async Task<string> GetBestMovementFromAI(GameEngine gameEngine, char turn)
			{
				GD.Print("I am getting the best move from the AI");
				//int id = ((game.movementAi.aiPlayerId + 1) % 2) +1;
				if (turn == 'h')
				{
					game.movementAi.aiPlayerId = 1;
				}
				else
				{
					game.movementAi.aiPlayerId = 2;
				}

				var move = await Task.Run(() => game.movementAi.GetBestMovement(gameEngine));
				int q = (int)move["startRow"];
				int r = (int)move["startCol"];
				int count  = (int)move["count"];
				int direction = (int)move["directionIndex"];

				Godot.Collections.Dictionary<string, int> MovedTo = new Godot.Collections.Dictionary<string, int>();
				MovedTo = gameEngine.GetFurthestUnoccupiedHexCoords(q, r, direction);

				string movestring = q + "," + r + "|" + count + "|" + MovedTo["q"] + "," + MovedTo["r"];
				return movestring;
			}
			 
			private static string GetBestInitialStackPlacementFromAI(GameEngine gameEngine)
			{
				var move = game.movementAi.GetBestInitialPlacement(gameEngine);
				int q = (int)move["q"];
				int r = (int)move["r"];

				string placement = q + "," + r;
				return placement;
			}

			private static string GetBestTilePlacementFromAI(GameEngine gameEngine)
			{
				// Get the best tile placement from the AI
				var move = game.tileAI.GetBestTilePlacement(gameEngine);
			
				// Convert the move dictionary to a string representation
				int q = (int)move["q"];

				int r = (int)move["r"];

				int orientation = (int)move["orientation"];

				var coordinates = GetHexCoordinates(q,r ,orientation );
				string movestring = "";
				foreach (var coord in coordinates)
				{
					if (movestring.Length > 0)
						movestring += "|";

					movestring += coord.q + "," + coord.r;
				}

				return movestring;
			}
			private static GameEngine SetUpGameEngine(int[,] parsedState)
			{
				GameEngine gameEngine = new GameEngine();
				gameEngine.StartGame();

				//initialize the game engine with the state
				for (int i = 0; i < parsedState.GetLength(0); i++)
				{
					int q = parsedState[i, 0];
					int r = parsedState[i, 1];
					int piececount = parsedState[i, 2];
					int owner = parsedState[i, 3];

					if (piececount == 0)
					{
						gameEngine.InitializeCell(q, r);
					}
					else
					{
						gameEngine.PlacePieces(owner, q, r, piececount);
					}

				}

				gameEngine.changeNotFirstTilePlacement();

				return gameEngine;
			}

			private static async Task<dynamic> GetPlayStateAsync()
			{
				string @event = "mirror";
				string player = game.player;
				string token = game.token;

				var requestData = new
				{
					@event,
					player,
					token
				};

				string json = JsonConvert.SerializeObject(requestData);
				HttpContent content = new StringContent(json, Encoding.UTF8, "application/json");

				HttpResponseMessage response = await client.PostAsync(baseUrl + "aivai/play-state", content);
				//Console.WriteLine(response);
				//response.EnsureSuccessStatusCode();
				if(response.StatusCode == System.Net.HttpStatusCode.NoContent){
					GD.Print("Received 204 No Content. Waiting before retrying...");
					return null; // wait 1 second before retrying
				}
				response.EnsureSuccessStatusCode();
				var responseBody = await response.Content.ReadAsStringAsync();
				dynamic jsonResponse = JsonConvert.DeserializeObject(responseBody);
				//submit state to the game engine
				GD.Print("State: " + jsonResponse.state + "\n" + "ID: " + jsonResponse.action_id);
				return jsonResponse;
			}

			private static async Task<dynamic> SubmitActionAsync( string action, dynamic actionId)
			{

				int action_id = actionId;
				string player = game.player;
				string token = game.token;

				var requestData = new
				{
					action,
					player,
					token,
					action_id
				};

				GD.Print("submitting action");
				string json = JsonConvert.SerializeObject(requestData);
				HttpContent content = new StringContent(json, Encoding.UTF8, "application/json");

				HttpResponseMessage response = await client.PostAsync(baseUrl + "aivai/submit-action", content);

				
				 response.EnsureSuccessStatusCode();
				if (response.StatusCode != System.Net.HttpStatusCode.OK)
				{
					GD.Print("FAIL");
				}
				else{
					GD.Print("SUCCESS");
				}
				
				var responseBody = await response.Content.ReadAsStringAsync();
				dynamic jsonResponse = JsonConvert.DeserializeObject(responseBody);
				GD.Print("Winner: " + jsonResponse.winner);
				return jsonResponse.winner;
			}

			private static async Task<string> GetResultingState(string state, string action)
			{
				HttpResponseMessage response = await client.GetAsync(baseUrl + $"state/{state}/act/{action}");

				response.EnsureSuccessStatusCode();
				var responseBody = await response.Content.ReadAsStringAsync();
				dynamic jsonResponse = JsonConvert.DeserializeObject(responseBody);
				string newState = jsonResponse.state;
				Console.WriteLine("New state after action: " + newState);
				return newState;
			}

			static bool ContainsElement(int[,] array, int x, int y)
			{
				for (int i = 0; i < array.GetLength(0); i++)
				{
					if (array[i, 0] == x && array[i, 1] == y)
					{
						return true; // Coordinate already exists
					}
				}
				return false;
			}
			
			public static int[,] ParseState(string state)
			{
				string[] components = state.Split('|');
				int validCount = 0;

				foreach (string component in components)
				{
					if (!string.IsNullOrEmpty(component) && component != "t" && component != "h")
					{
						validCount++;
					}
				}

				int[,] result = new int[validCount, 4];

				int index = 0;

				foreach (string component in components)
				{
				
					if (component == "h" || component == "t")
					{
						continue;
					}
					else
					{
						if (component.Contains("h") || component.Contains("t"))
						{
							string[] parts = component.Split(new[] { 'h', 't' });
							string coord = parts[0];
							char ownerType = component[component.IndexOfAny(new[] { 'h', 't' })];
							int owner = ownerType == 'h' ? 1 : 2;
							int count = int.Parse(parts[1]);

							int p = int.Parse(coord.Split(',')[0]);
							int q = int.Parse(coord.Split(',')[1]);

							result[index, 0] = p;
							result[index, 1] = q;
							result[index, 2] = count;
							result[index, 3] = owner;
						}
						else
						{
							string[] coord = component.Split(',');
							int p = int.Parse(coord[0]); // p
							int q = int.Parse(coord[1]); // q
							if (!ContainsElement(result, p, q))
							{
								result[index, 0] = p;
								result[index, 1] = q;
								result[index, 2] = 0; // # of pieces (default to 0)
								result[index, 3] = 0; // piece owner (default to 0)
							}
						}

						index++;
					}
				}

				return result;
			}



			private static int DetermineGamePhase(string currentState)
			{
				//determine the game phase based on the move made
				//1 - tile placement
				//2 - initial stack placement
				//3 - movement
				string[] state = currentState.Split('|');

				if (state.Length < 32)
				{
					GD.Print("Phase 1: tile placement");
					return 1;
				}
				else if (state.Length == 32 || state.Length == 33 || state.Length == 34)
				{
					GD.Print("Phase 2: initial stack placement");
					return 2;
				}
				else
				{
					GD.Print("Phase 3: movement");
					return 3;
				}
			}

			// Predefined orientations as in the original Tile class
			private static readonly List<List<(int q, int r)>> _orientations = new List<List<(int q, int r)>>
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

			public static List<(int q, int r)> GetHexCoordinates(int q, int r, int orientationIndex)
			{
				// Ensure the orientation index is valid
				if (orientationIndex < 0 || orientationIndex >= _orientations.Count)
				{
					throw new ArgumentException("Invalid orientation index.");
				}

				// Get the orientation cells for the given index
				var orientationCells = _orientations[orientationIndex];

				// Create a list to hold the coordinates
				List<(int q, int r)> hexCoordinates = new List<(int q, int r)>();

				// Calculate the coordinates of each hex by adding the base q, r to the cell's q, r
				foreach (var (cellQ, cellR) in orientationCells)
				{
					hexCoordinates.Add((q + cellQ, r + cellR));
				}

				return hexCoordinates;
			}
		}
	}
}
