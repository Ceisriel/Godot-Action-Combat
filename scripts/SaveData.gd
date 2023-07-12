extends Node2D


func save_data(path, data):
	var file = File.new()
	file.open(path, File.Write)
	file.store_var(data)
	file.close()

func load_data(path):
	var file = File.new()
	var content
	file.open(path, File.READ)
	content = file.get_var()
	file.close()
	return content

func _on_Save_pressed():
	sava_data("user:")
func _on_Load_pressed():
	pass		
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
