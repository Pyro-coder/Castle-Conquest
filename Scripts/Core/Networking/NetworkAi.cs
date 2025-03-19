using System;
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


namespace Capstone25.Scripts.Core.Networking
{
	[GlobalClass]
	public partial class NetworkAi : Node
	{
	  
		private class Game
		{
			public string State { get; set; }
			public string action_id { get; set; }

			public string player = "Castle Conquest";

			public GameEngine gameEngine = new GameEngine();

			public ABMinimaxTile tileAI = new ABMinimaxTile();

			public MonteCarloInitialMovement movementAi = new MonteCarloInitialMovement();


			public Game()
			{
				tileAI.Initialize(10, 1);
				movementAi.Initialize(800, 1);
			}
		}

		private class Client
		{

			private static Game game = new();
			private static GameEngine gameEngine = new GameEngine();


			private static readonly string baseUrl = "https://softserve.harding.edu/";
			private static readonly System.Net.Http.HttpClient client = new System.Net.Http.HttpClient();

			public static async Task Main(string[] args)
			{
				string loggedState = ""; // this is so i am able to compare to the previous state

				//Get an initial state from the server
				// dynamic initialState = await GetInitialStateAsync();

				//get a state and action_id from the server
				dynamic playState = await GetPlayStateAsync();


				//calculate last move based on state and determine move to make
				string selectedAction = GetMove(loggedState, playState.State);

				loggedState = playState.state;

				//submit action to the server and get the resulting state
				await SubmitActionAsync(playState.state, selectedAction, playState.action_id);
			}

			private static async Task<dynamic> GetInitialStateAsync()
			{
				HttpResponseMessage response = await client.GetAsync(baseUrl + "state/initial");
				response.EnsureSuccessStatusCode();
				var responseBody = await response.Content.ReadAsStringAsync();
				dynamic json = JsonConvert.DeserializeObject(responseBody);
				//submit state to the game engine
				gameEngine = json.state;
				return json;
			}

			private static async Task<dynamic> GetPlayStateAsync()
			{
				HttpResponseMessage response = await client.GetAsync(baseUrl + "aivai/play-state");
				response.EnsureSuccessStatusCode();
				var responseBody = await response.Content.ReadAsStringAsync();
				dynamic json = JsonConvert.DeserializeObject(responseBody);
				//submit state to the game engine
				gameEngine = json.state;
				return json;
			}

			private static async Task SubmitActionAsync(string state, string action, int action_id)
			{
				var requestData = new
				{
					state,
					action,
					action_id
				};

				string json = JsonConvert.SerializeObject(requestData);
				HttpContent content = new StringContent(json, Encoding.UTF8, "application/json");

				HttpResponseMessage response = await client.PostAsync(baseUrl + "aivai/submit-action", content);

				response.EnsureSuccessStatusCode();
				var responseBody = await response.Content.ReadAsStringAsync();
				dynamic jsonResponse = JsonConvert.DeserializeObject(responseBody);

				//get the resulting state after the action
				string loggedState = await GetResultingState(state, action);
				//return loggedState;
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

			private static string FindMoveMade(string loggedState, string currentState)
			{
				//find move that opponent made and pass it to the game engine
				List<string> changedRows = new List<string>();

				string[] A = loggedState.Split('|');
				string[] B = currentState.Split('|');

				foreach (string a in A)
				{
					if (!B.Contains(a))
					{
						changedRows.Add(a);
					}
				}

				string c = changedRows[0];
				string d = changedRows[1];

				string action = $"{c[0]}, {c[1]}|{d[2]}|{d[0]}, {d[1]}";

				return action;
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
					return 1;
				}
				else if (state.Length == 32 || state.Length == 33)
				{
					return 2;
				}
				else
				{
					return 3;
				}
			}

			private static string GetMove(string loggedState, string currentState)
			{
				//find move that opponent made and pass it to the game engine
				string moveMade = FindMoveMade(loggedState, currentState);

				//send move to the AI to determine the next move, depending on game phase
				int phase = DetermineGamePhase(currentState);

				if (phase == 1)
				{
					//tile placement
					Godot.Collections.Dictionary move = game.tileAI.GetBestTilePlacement(gameEngine);
					//move will be a coordinate with orientation
					return null;

				}
				else if (phase == 2)
				{
					//initial stack placement
					Godot.Collections.Dictionary<string, int> move = game.movementAi.GetBestInitialPlacement(gameEngine);
					//move will be a coordinate
					string placement = $"{move["q"]}, {move["r"]}";
					return placement;
				}
				else
				{
					//movement
					Godot.Collections.Dictionary<string, int> move = game.movementAi.GetBestMovement(gameEngine);
					//move will be a coordinate and direction with number of tokens to move
					return null;
				}
			}
		}
	}
}
