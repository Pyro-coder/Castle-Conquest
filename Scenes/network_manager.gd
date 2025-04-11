extends Node

signal connection_established
signal connection_timeout
signal move_timeout

@onready var move_timer: Timer
var move_timeout_duration := 20.0  # Seconds allowed per move
var network_peer: ENetMultiplayerPeer
var udp_broadcaster := PacketPeerUDP.new()
var broadcast_port := 54545  # The UDP port to send broadcasts
var broadcast_timer: Timer
var expected_join_code: String = ""
var is_host_connected = false
var udp_listener := PacketPeerUDP.new()
var listening_port := 54545  # Same as broadcast_port
var is_client_connected = false


@onready var status_label: Label = $StatusLabel

var is_host = false

func _ready() -> void:
	print("NetworkManager ready.")
	var multiplayer = get_tree().get_multiplayer()
	# Connect signals for when peers connect.
	setup_move_timer()
	
	multiplayer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.connect("connected_to_server", Callable(self, "_on_connected_to_server"))
	print("Local unique id in NetworkManager: ", multiplayer.get_unique_id())
	


func setup_move_timer() -> void:
	if move_timer == null:
		move_timer = Timer.new()
		add_child(move_timer)
	move_timer.wait_time = move_timeout_duration
	move_timer.one_shot = true
	move_timer.timeout.connect(_on_move_timeout)


func reset_move_timer() -> void:
	if move_timer != null:
		move_timer.stop()
		move_timer.start()
	else:
		print("Warning: move_timer is null. Cannot reset.")


func _on_move_timeout() -> void:
	print("Move timeout reached! No move made in time.")
	emit_signal("move_timeout")

	# Handle the timeout logic
	if get_tree().get_multiplayer().is_server():
		# Host (server) is handling the timeout for the current player
		print("Host move timeout – handle forfeit or skip")
	else:
		# Client's move timeout – the client should also trigger the timeout handling.
		print("Client move timeout – handle forfeit or skip")


# Called by the host.
func host_game(join_code: String) -> void:
	var port = join_code_to_port(join_code)
	print("Attempting to host on port %d" % port)
	network_peer = ENetMultiplayerPeer.new()
	var result = network_peer.create_server(port, 1)  # Allow one client.
	if result == OK:
		get_tree().get_multiplayer().set_multiplayer_peer(network_peer)
		print("Hosting game on port %d" % port)
		if status_label:
			status_label.text = "Hosting on port " + str(port)
		start_connection_timeout(30.0)
		start_broadcasting(port, join_code)
		  # Set host as connected after successfully hosting
	else:
		print("Failed to host game. Error code: ", result)
		if status_label:
			status_label.text = "Failed to host game."

func start_broadcasting(port: int, join_code: String) -> void:
	udp_broadcaster.set_broadcast_enabled(true)
	
	broadcast_timer = Timer.new()
	broadcast_timer.wait_time = 2.0  # Broadcast every 2 seconds
	broadcast_timer.one_shot = false
	broadcast_timer.timeout.connect(func():
		if !is_host_connected:
			var ip = get_local_ip()
			if ip != "":
				var message = "%s:%d:%s" % [ip, 54545, join_code]
				udp_broadcaster.set_dest_address("255.255.255.255", broadcast_port)
				udp_broadcaster.put_packet(message.to_utf8_buffer())
				print("Broadcasting host IP: ", message)
		else:
			# Stop broadcasting once the host is connected
			udp_broadcaster.set_broadcast_enabled(false)
			print("Host is connected. Stopped broadcasting.")
			broadcast_timer.stop() 
			# Stop the broadcast timer as well
	)
	add_child(broadcast_timer)
	broadcast_timer.start()

func get_local_ip() -> String:
	var ip = ""
	for addr in IP.get_local_addresses():
	   # Filter for local network addresses (IPv4)
		if addr.begins_with("192.168.") or addr.begins_with("10.") or addr.begins_with("172."):
			ip = addr
			break  # Stop after finding the first valid local IP
	return ip

# Called by the joiner (client).
func join_game(host_ip: String, join_code: String) -> void:
	if host_ip == "":
		listen_for_host(join_code)
		return
	var port = join_code_to_port(join_code)
	print("Attempting to join game on %s:%d" % [host_ip, port])
	network_peer = ENetMultiplayerPeer.new()
	var result = network_peer.create_client(host_ip, port)
	if result == OK:
		get_tree().get_multiplayer().set_multiplayer_peer(network_peer)
		print("Client: Set multiplayer peer successfully.")
		if status_label:
			status_label.text = "Attempting to join " + host_ip + ":" + str(port)
		# Print the client unique ID to verify it’s not 1.
		print("Client unique id: ", get_tree().get_multiplayer().get_unique_id())
		start_connection_timeout(30.0)
		is_client_connected = true  # Set client as connected
		udp_broadcaster.set_broadcast_enabled(false)  # Stop broadcasting when the client connects
	else:
		print("Failed to join game. Error code: ", result)
		if status_label:
			status_label.text = "Failed to join game."

func listen_for_host(join_code: String) -> void:
	if is_client_connected:
		print("Client already connected, no need to listen for more hosts.")
		return
	
	expected_join_code = join_code
	print("Listening for host broadcasts...")
	start_connection_timeout(30)
	udp_listener.close()
	udp_listener.bind(listening_port)
	
	# Set up a repeated timer to poll for broadcasts every 0.5 seconds.
	var poll_interval := 0.5
	var elapsed_time := 0.0
	var timeout_duration := 30.0

	var timer = Timer.new()
	timer.wait_time = poll_interval
	timer.one_shot = false
	timer.timeout.connect(func():
		elapsed_time += poll_interval  # Update elapsed time.
		
		# Check if we have received any UDP packets.
		if udp_listener.get_available_packet_count() > 0:
			var packet = udp_listener.get_packet()
			var message = packet.get_string_from_utf8()
			print("Received broadcast:", message)
			var parts = message.split(":")
			if parts.size() == 3 and parts[2] == expected_join_code:
				# Found matching host; stop further polling.
				var host_ip = parts[0]
				var port = int(parts[1])
				print("Found matching host at %s:%d" % [host_ip, port])
				join_game(host_ip, expected_join_code)
				timer.stop()   # Stop the timer early.
				udp_listener.close()
				return  # Exit the callback early.
		
		# If we've polled long enough, finish up.
		if elapsed_time >= timeout_duration:
			print("Timeout reached. No host found.")
			timer.stop()
			udp_listener.close()
	)
	add_child(timer)
	timer.start()

	set_process(true)


# Converts a join code to a port number.
func join_code_to_port(join_code: String) -> int:
	if join_code.length() > 32:
		join_code = join_code.substr(0, 32)
	var hash_val = 0
	for i in range(join_code.length()):
		hash_val = (hash_val * 31 + join_code.unicode_at(i))
	var port_range = 60000 - 1024
	var port = 1024 + (hash_val % port_range)
	print("Join code '%s' converted to port %d" % [join_code, port])
	return port

func parse_broadcast(message: String) -> void:
	var parts = message.split(":")
	if parts.size() == 3:
		var host_ip = parts[0]
		var host_port = int(parts[1])
		var join_code = parts[2]
		print("Received host IP: %s, Port: %d, Join Code: %s" % [host_ip, host_port, join_code])
		join_game(host_ip, join_code)  # Automatically attempt to join the game

# Sets up a timer that disconnects if no connection is made.
func start_connection_timeout(seconds: float) -> void:
	print("Starting connection timeout for %f seconds." % seconds)
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_connection_timeout"))
	add_child(timer)
	timer.start()

func _on_connection_timeout() -> void:
	var peers = get_tree().get_multiplayer().get_peers()
	print("Connection timeout reached. Number of connected peers: ", peers.size())
	if get_tree().get_multiplayer().is_server():
		if peers.size() < 1:
			print("No joiner connected within timeout. Disconnecting host.")
			get_tree().get_multiplayer().set_multiplayer_peer(null)
			emit_signal("connection_timeout")
			if status_label:
				status_label.text = "Timeout: No joiner connected."
			get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	else:
		if !is_client_connected:
			print("Failed to connect to host within timeout. Disconnecting.")
			get_tree().get_multiplayer().set_multiplayer_peer(null)
			emit_signal("connection_timeout")
			if status_label:
				status_label.text = "Timeout: Failed to connect to host."
			get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	#queue_free()
	

# Called when a client connects to the host.
func _on_peer_connected(id: int) -> void:
	print("Client connected with ID: %d" % id)
	is_host_connected = true
	if status_label:
		status_label.text = "Client connected (ID: " + str(id) + ")"
	emit_signal("connection_established")

# Called on the client when it successfully connects to the host.
func _on_connected_to_server() -> void:
	print("Successfully connected to host!")
	is_client_connected = true
	if status_label:
		status_label.text = "Connected to host!"
	emit_signal("connection_established")
