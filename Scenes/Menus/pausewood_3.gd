extends Sprite2D

var _is_paused:bool = false:
	set = set_paused
	
@export var pause_menu: Control

func _ready() -> void:
	pause_menu.visible = false
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			self._is_paused = !self._is_paused
			set_paused(_is_paused)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self._is_paused = !_is_paused
		set_paused(_is_paused)
	
func set_paused(value:bool) ->void:
	_is_paused = value
	get_tree().paused = _is_paused
	visible = !_is_paused
	pause_menu.visible = _is_paused

func _on_resume_btn_pressed() -> void:
	_is_paused = false
	set_paused(_is_paused)

func _on_settings_btn_pressed() -> void:
	pass # Replace with function body.

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _on_back_2_main_btn_pressed() -> void:
	_is_paused = false
	set_paused(_is_paused)
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
