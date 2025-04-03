# NetworkTestUI.gd
extends Panel
@onready var NetworkManager: Node = $"../../NetworkManager"
@onready var joinCodeLabel: Label = $JoinCodeLabel
@onready var joinCodeLineEdit: LineEdit = $JoinCodeLineEdit
@onready var hostButton: Button = $HostButton
@onready var joinButton: Button = $JoinButton

func _ready() -> void:
	# Connect button signals to our handler functions.
	hostButton.connect("pressed", Callable(self, "_on_host_pressed"))
	joinButton.connect("pressed", Callable(self, "_on_join_pressed"))

func _on_host_pressed() -> void:
	var join_code: String = joinCodeLineEdit.text.strip_edges()
	if join_code == "":
		joinCodeLabel.text = "Please enter a join code."
		return
	# Call the host function in your NetworkManager.
	# If you set up NetworkManager as an autoload, you can call it directly.
	GlobalVars.is_host = true
	NetworkManager.host_game(join_code)
	print("Hosting with join code:", join_code)
	joinCodeLabel.text = "Hosting game..."

func _on_join_pressed() -> void:
	var join_code: String = joinCodeLineEdit.text.strip_edges()
	if join_code == "":
		joinCodeLabel.text = "Please enter a join code."
		return
	# For testing, we'll use localhost. Change "127.0.0.1" if needed.
	GlobalVars.is_host = false
	NetworkManager.join_game("127.0.0.1", join_code)
	print("Joining game with join code:", join_code)
	joinCodeLabel.text = "Attempting to join..."
