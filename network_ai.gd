extends Control

var baseurl = "https://softserve.harding.edu/"

@onready var http_request = $HTTPRequest

enum RequestType{
	INITIAL,
	PLAY_STATE,
	SUBMIT_ACTION,
	VALID_ACTIONS
}

var cur_request_type: RequestType
var prevstates = []
var curstate = ""
var response_recieved = false
var ValidActions = []
var action_id = 0
var basic = 0
var ht = 0

#signal response_recieved(response: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	http_request.request_completed.connect(_on_request_completed)
	
	
	#send_initial_request()
	#await wait_for_response()
	
	#send_play_state_request()
	
	#response_recieved = false
	#await wait_for_response()
	
	#prevstates.append(curstate)
	
	
	#response_recieved = false
	#await wait_for_response()
	
	compare_states()
	
	#submit_action()
	
	
	pass # Replace with function body.

func wait_for_response():
	# Wait until response_received is true
	while response_recieved == false:
		await get_tree().process_frame

func find_action():
	if prevstates.size() >0:
		var last_state = prevstates[-1]
		var action_taken = compare_states()
		print("Action taken: ", action_taken)
	
	prevstates.append(curstate)

func compare_states():
#	var previous = "0,4|1,2|2,3|0,4h2|2,3t3|t"
#	var current = "0,4|1,2|2,3|0,4h2|2,3t2|1,2t1|h"
#	var prev = parse_state(previous)
#	var curr = parse_state(current)
	var curr = parse_state(curstate)
	var prev = parse_state(prevstates[-1])
	var changed_tiles = []
	var new_tiles = []
	for curr_tile in curr:
		var found = false
		for prev_tile in prev:
			if curr_tile[0] == prev_tile[0] and curr_tile[1] == prev_tile[1]:  # Compare coordinates
				found = true
				if curr_tile[2] != prev_tile[2]:  # Check tokens or ownership
					changed_tiles.append(curr_tile)
				break
		if not found:
			new_tiles.append(curr_tile)  # New tile added
	if new_tiles.size() > 0:
		print("Action: Tile added at ", new_tiles[0][0], ", ", new_tiles[0][1])
	elif changed_tiles.size() > 0:
		var prev_tile = changed_tiles[0][0]
		var curr_tile = changed_tiles[0][1]
		print("Action: Tokens changed at (", curr_tile[0], ", ", curr_tile[1], ")")
		var action = "[]"
		print("  Previous: ", prev_tile[2], " tokens, owned by player ", prev_tile[3])
		print("  Current: ", curr_tile[2], " tokens, owned by player ", curr_tile[3])
	else:
		print("Action: No changes detected")

func send_post(url: String, headers: Array, body: String, request_type: RequestType) -> void:
	cur_request_type = request_type
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("An error occurred in the HTTP request.")
	else:
		print("Request sent successfully. Type: ", RequestType.keys()[request_type])
		
func send_get(url: String, request_type: RequestType) -> void:
	cur_request_type = request_type
	var error = http_request.request(url)
	if error != OK:
		print("An error occurred in the HTTP request.")
	else:
		print("Request sent successfully. Type: ", RequestType.keys()[request_type])

func send_play_state_request():
	var headers = ["Content-Type: application/json"]
	var url = baseurl + "aivai/play-state"
	
	var event = "mirror"
	var player = "Castle Conquest"
	
	var body = JSON.stringify({
		"event": event,
		"player" : player
	})
	send_post(url, headers, body, RequestType.PLAY_STATE)

func send_initial_request():
	var headers = ["Content-Type: application/json"]
	var url = baseurl + "state/initial"
	send_get(url, RequestType.INITIAL)
	
func get_valid_actions():
	if curstate.is_empty():
		print("Error: Current state is empty.")
		'return'
	var newCurState = transform_state(curstate)	
	var headers = ["Content-Type: application/json"]
	var url = baseurl + "state/"+ newCurState +"/actions"
	#print(url)
	send_get(url, RequestType.VALID_ACTIONS)
	
func parse_state(state: String) -> Array:
	# Split the state string into components
	var components = state.split("|", false)
	
	# Initialize an array to store the parsed data
	var result = []
	
	# Iterate through each component
	for component in components:
		if component.is_empty() or component == "t" or component == "h":
			continue  # Skip empty components or turn indicators
		
		if "h" in component or "t" in component:
			# Parse positions with tokens
			var parts = component.split("h" if "h" in component else "t")
			var coord = parts[0]  # e.g., "4,6"
			var count = int(parts[1])  # e.g., "1"
			var owner = 1 if "h" in component else 2  # 1 for 'h', 2 for 't'
			
			# Split the coordinates into p and q
			var pq = coord.split(",")
			var p = int(pq[0])
			var q = int(pq[1])
			
			# Add the parsed data to the result array
			result.append([p, q, count, owner])
		else:
			# Parse positions without tokens
			var pq = component.split(",")
			var p = int(pq[0])
			var q = int(pq[1])
			
			# Add the parsed data to the result array (default to 0 tokens and no owner)
			result.append([p, q, 0, 0])
	
	# Print the result for debugging
	for row in result:
		print("[%d, %d, %d, %d]" % [row[0], row[1], row[2], row[3]])
	
	return result

func transform_state(state: String) -> String:
	# Step 1: Split the state into two parts
	var parts = state.split("|", false)
	
	# Step 2: Separate the basic pairs and the h/t pairs
	var basic_pairs = []
	var ht_pairs = []
	var turn = ""
	for part in parts:
		if part == "t" or part == "h":
			turn = part
			
		elif "h" in part or "t" in part:
			ht_pairs.append(part)
			ht +=1
		else:
			basic_pairs.append(part)
			basic+=1
	
	# Step 3: Wrap the basic pairs in parentheses and add {0,32}
	var basic_part = "(" + "|".join(basic_pairs) + ")"
	
	# Step 4: Wrap the h/t pairs in parentheses and add {0,32}
	var ht_part = "{" + "|".join(ht_pairs) + "}"
	
	# Step 5: Combine the parts and ensure it ends with [ht]
	var transformed_state = basic_part + ht_part + "[" + turn + "]"
	
	return transformed_state

func choose_random_action(valid_actions: Array) -> String:
	if valid_actions.is_empty():
		print("Error: No valid actions available.")
		return ""  # Return an empty string if there are no valid actions
	
	var random_action
	# Choose a random index from the valid_actions array
	if basic >= 8:
		var random_index = randi() % (valid_actions.size() - 9 + 1) + 9
		random_action = valid_actions[random_index]
	else:
		var random_index = randi() % valid_actions.size()
		random_action = valid_actions[random_index]
	
	
	print("Randomly Chosen Action: ", random_action)
	return random_action

func submit_action():
	var headers = ["Content-Type: application/json"]
	var url = baseurl + "aivai/submit-action"
	
	var action = GetBestMovement()#get action from ai
	var player = "Castle Conquest"
	var actionid = action_id
	
	var body = JSON.stringify({
		"action": action,
		"player" : player,
		"action_id" : actionid
	})
	print(url)
	send_post(url, headers, body, RequestType.SUBMIT_ACTION)

func handle_play_state_response(response: Dictionary) -> void:
		var state = response.get("state", "")
		curstate = state
		action_id = response.get("action_id", "")
		print("State: ", state)
		print("Action ID: ", action_id)
				
		var state_components = state.split("|")
		print("State components: ", state_components)
		response_recieved = true
		
func handle_initial_response(response: Dictionary) -> void:
	var log = response.get("Log", "")
	var state = response.get("state","")
	print("Log: ", log)
	print("State: ", state)
	response_recieved = true

	
func handle_submit_action_response(response: Dictionary) -> void:
	var winner = response.get("winner", "")
	print("Winner", winner)
	response_recieved = true
	
func handle_valid_actions(response: Dictionary):
	var log = response.get("log", "")
	var actions = response.get("actions", "")
	print("Valid Actions", actions)
	response_recieved = true
	ValidActions = actions
	
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var body_string = body.get_string_from_utf8()
		#print("Raw response body: ", body_string)
		var json = JSON.new()
		var parse_result = json.parse(body_string)
		if parse_result == OK:
			var response = json.data
			
			if cur_request_type == RequestType.PLAY_STATE:
				handle_play_state_response(response)
			elif cur_request_type == RequestType.INITIAL:
				handle_initial_response(response)
			elif cur_request_type == RequestType.SUBMIT_ACTION:
				handle_submit_action_response(response)
			elif cur_request_type == RequestType.VALID_ACTIONS:
				handle_valid_actions(response)
			else:
				print("Unknown request type.")
		else:
			print("Failed to parse JSON response. Error code: ", parse_result)
	else:
		print("HTTP request failed with response code: ", response_code)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
