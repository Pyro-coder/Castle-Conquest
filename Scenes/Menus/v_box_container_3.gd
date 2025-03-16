extends VBoxContainer
@export var tween_intensity: float
@export var tween_duration: float

@onready var play: Button = $PlayButton

func start_tween(object: Object, property: String, final_val: Variant, duration: float):
	var tween = create_tween()
	tween.tween_property(object, property, final_val, duration)
	
func hover_process(button: Button) -> void:
	if button:
		#button.pivot_offset = button.size / 2
		if button.is_hovered():
			start_tween(button, "scale", Vector2.ONE * tween_intensity, tween_duration)
		else:
			start_tween(button, "scale", Vector2.ONE, tween_duration)
			
func _ready() -> void: 
	if play:
		play.mouse_entered.connect(func(): hover_process(play))
		play.mouse_exited.connect(func(): hover_process(play))
		
