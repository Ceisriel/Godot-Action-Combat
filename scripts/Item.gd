extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if randi() % 2 == 0:
		load_and_resize_image("res://UI/Items/crystal.jpg")
	else:
		load_and_resize_image("res://UI/Items/crystal2.jpg")

# Loads the image, resizes it, and assigns it to a Sprite
func load_and_resize_image(path: String):
	var texture = load(path)
	if texture:
		var image = texture.get_data()
		image.resize(7, 7)  # Set the desired width and height

		var resized_texture = ImageTexture.new()
		resized_texture.create_from_image(image)

		var sprite = Sprite.new()
		sprite.texture = resized_texture

		add_child(sprite)
