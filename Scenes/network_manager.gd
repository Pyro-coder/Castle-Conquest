extends Node

signal connection_established
signal connection_timeout
signal server_discovered(server_ip, join_code)

var network_peer: ENetMultiplayerPeer
var udp_socket: PacketPeerUDP
const DISCOVERY_PORT = 4242
const DISCOVERY_MESSAGE = "DISCOVER_SERVER"

@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	print("NetworkManager ready.")
	var multiplayer = get_tree().get_multiplayer()
	multiplayer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.connect("connected_to_server", Callable(self, "_on_connected_to_server"))
	print("Local unique id in NetworkManager: ", multiplayer.get_unique_id())
	# Set up UDP discovery on the designated port.
	setup_udp_discovery()

func setup_udp_discovery() -> void:
	udp_socket = PacketPeerUDP.new()
	udp_socket.set_broadcast_enabled(true)
	var err = udp_socket.bind(DISCOVERY_PORT)
	if err != OK:
		print("Failed to bind UDP socket: ", err)
	else:
		print("UDP socket bound on port %d" % DISCOVERY_PORT)
	set_process(true)

# Client: Broadcast discovery message on the LAN.
func discover_servers() -> void:
	var packet = DISCOVERY_MESSAGE.to_utf8_buffer()
	udp_socket.set_broadcast_enabled(true)
	udp_socket.connect_to_host("255.255.255.255", DISCOVERY_PORT)
	udp_socket.put_packet(packet)

	print("Broadcasted discovery message.")

# Process incoming UDP packets.
func _process(delta: float) -> void:
	while udp_socket.get_available_packet_count() > 0:
		var data = udp_socket.get_packet()
		var sender_ip = udp_socket.get_packet_ip()
		var message = data.get_string_from_utf8()
		# If this is a host and receives a discovery message, send a response.
		if message == DISCOVERY_MESSAGE and is_server():
			# For this example, we send back a join code.
			var join_code = generate_join_code()
			var response = "SERVER_RESPONSE:" + join_code
			udp_socket.send_packet(sender, response.to_utf8())
			print("Responded to discovery from ", sender)
		elif message.begins_with("SERVER_RESPONSE:"):
			# Client receives a server response.
			var join_code = message.replace("SERVER_RESPONSE:", "")
			print("Discovered server at ", sender, " with join code: ", join_code)
			emit_signal("server_discovered", sender, join_code)
		else:
			print("Received UDP packet from ", sender, ": ", message)

# A simple method to generate a join code.
func generate_join_code() -> String:
	return "ABC123"  # Replace with your actual join code generation.

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
	else:
		print("Failed to host game. Error code: ", result)
		if status_label:
			status_label.text = "Failed to host game."

# Called by the joiner (client).
func join_game(host_ip: String, join_code: String) -> void:
	var port = join_code_to_port(join_code)
	print("Attempting to join game on %s:%d" % [host_ip, port])
	network_peer = ENetMultiplayerPeer.new()
	var result = network_peer.create_client(host_ip, port)
	if result == OK:
		get_tree().get_multiplayer().set_multiplayer_peer(network_peer)
		print("Client: Set multiplayer peer successfully.")
		if status_label:
			status_label.text = "Attempting to join " + host_ip + ":" + str(port)
		print("Client unique id: ", get_tree().get_multiplayer().get_unique_id())
		start_connection_timeout(30.0)
	else:
		print("Failed to join game. Error code: ", result)
		if status_label:
			status_label.text = "Failed to join game."

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

# Sets up a timer to disconnect if no connection is made.
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
	else:
		if peers.size() < 1:
			print("Failed to connect to host within timeout. Disconnecting.")
			get_tree().get_multiplayer().set_multiplayer_peer(null)
			emit_signal("connection_timeout")
			if status_label:
				status_label.text = "Timeout: Failed to connect to host."

# Called when a client connects to the host.
func _on_peer_connected(id: int) -> void:
	print("Client connected with ID: %d" % id)
	if status_label:
		status_label.text = "Client connected (ID: " + str(id) + ")"
	emit_signal("connection_established")

# Called on the client when it successfully connects to the host.
func _on_connected_to_server() -> void:
	print("Successfully connected to host!")
	if status_label:
		status_label.text = "Connected to host!"
	emit_signal("connection_established")

func is_server() -> bool:
	return get_tree().get_multiplayer().is_server()
