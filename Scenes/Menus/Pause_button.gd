extends TextureButton
@export var new_width : int = 10
@export var new_height : int = 10

func _ready():
	if texture_normal:
		var image : Image = texture_normal.get_image()
		image.resize(new_width, new_height)
		texture_normal = ImageTexture.create_from_image(image)
	if texture_pressed:
		var image_pressed : Image = texture_pressed.get_image()
		image_pressed.resize(new_width, new_height)
		texture_pressed = ImageTexture.create_from_image(image_pressed)
	if texture_hover:
		var image_hover : Image = texture_hover.get_image()
		image_hover.resize(new_width, new_height)
		texture_hover = ImageTexture.create_from_image(image_hover)
	if texture_disabled:
		var image_disabled : Image = texture_disabled.get_image()
		image_disabled.resize(new_width, new_height)
		texture_disabled = ImageTexture.create_from_image(image_disabled)
	if texture_focused:
		var image_focused : Image = texture_focused.get_image()
		image_focused.resize(new_width, new_height)
		texture_focused = ImageTexture.create_from_image(image_focused)

	# Optional: Adjust the button's minimum size to match the new texture dimensions.
	self.custom_minimum_size = Vector2(new_width, new_height)
