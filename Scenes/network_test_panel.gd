# NetworkTestUI.gd
extends Panel

@onready var NetworkManager: Node = $"../../NetworkManager"
@onready var joinCodeLabel: Label = $JoinCodeLabel
@onready var joinCodeLineEdit: LineEdit = $JoinCodeLineEdit
@onready var hostButton: Button = $HostButton
@onready var joinButton: Button = $JoinButton
@onready var discoverButton: Button = $DiscoverButton  # Make sure this button exists in your scene.

func _ready() -> void:
	hostButton.connect("pressed", Callable(self, "_on_host_pressed"))
	joinButton.connect("pressed", Callable(self, "_on_join_pressed"))
	discoverButton.connect("pressed", Callable(self, "_on_discover_pressed"))
	NetworkManager.connect("server_discovered", Callable(self, "_on_server_discovered"))

func _on_host_pressed() -> void:
	var join_code: String = joinCodeLineEdit.text.strip_edges()
	if join_code == "":
		joinCodeLabel.text = "Please enter a join code."
		return
	GlobalVars.is_host = true  # Assuming you have a GlobalVars singleton.
	NetworkManager.host_game(join_code)
	print("Hosting with join code:", join_code)
	joinCodeLabel.text = "Hosting game..."

func _on_join_pressed() -> void:
	var join_code: String = joinCodeLineEdit.text.strip_edges()
	if join_code == "":
		joinCodeLabel.text = "Please enter a join code."
		return
	GlobalVars.is_host = false
	# For testing, this example uses localhost.
	NetworkManager.join_game("", join_code)
	print("Joining game with join code:", join_code)
	joinCodeLabel.text = "Attempting to join..."

func _on_discover_pressed() -> void:
	print("Discovering servers on LAN...")
	NetworkManager.discover_servers()

func _on_server_discovered(server_ip: String, join_code: String) -> void:
	print("Server discovered at ", server_ip, " with join code: ", join_code)
	joinCodeLabel.text = "Server discovered: " + server_ip + " [" + join_code + "]"
