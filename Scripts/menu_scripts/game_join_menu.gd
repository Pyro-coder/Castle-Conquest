extends Control


@export var Address = '127.0.0.1'
@export var port = 1234

var peer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	pass # Replace with function body.

func peer_connected(id):
	print("Player Connected" + str(id))

func peer_disconnected(id):
	print("Player Disconnected" + str(id))

func connected_to_server():
	print("Connected to server!")
	SendPlayerInformation.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())

func connection_failed():
	print("Couldn't connect")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/player_mode_menu.tscn")
	



func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_conquer_button_pressed() -> void:
	if multiplayer.get_peers().size() < 1:
		print("Not enough players to start")
		return
		
	StartGame.rpc()
	#get_tree().change_scene_to_file("res://Scenes/Menus/main_game.tscn")
	

@rpc("any_peer")
func SendPlayerInformation(username, id):
	print("Received player info:", username, ", ", id)
	print("Current players before:", GamePlayerManager.Players)
	
	if !GamePlayerManager.Players.has(id):
		GamePlayerManager.Players[id]={
			"name" : username,
			"id" : id
		}
	print("Current players after:", GamePlayerManager.Players)
	if multiplayer.is_server():
		for i in GamePlayerManager.Players:
			SendPlayerInformation.rpc(GamePlayerManager.Players[i].name, i)


@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://Scenes/board.tscn") #figure out what to put in here to play the game
	
	if scene == null:
		print("Failed to load the scene.")
		return
	else:
		print("Scene successfully loaded!")
	
	var instance = scene.instantiate()
	
	if instance == null:
		print("Failed to instantiate the scene.")
		return
	else:
		print("Scene successfully instantiated")
		
	get_tree().root.add_child(instance)
	self.hide()
	print("Game started successfully!")


func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host: " + error)
		return
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players!")
	#SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())
	pass # Replace with function body.


func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	multiplayer.set_multiplayer_peer(peer)
	pass # Replace with function body.
