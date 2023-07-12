extends Button

var save_filename = "user://save_game.save"

func _ready():
	connect("pressed", self, "_on_Button_pressed")

func _on_Button_pressed():
	load_game()

func load_game():
	var save_file = File.new()
	if not save_file.file_exists(save_filename):
		return
	
	var saved_nodes = get_tree().get_nodes_in_group("Save")
	
	for node in saved_nodes:
		node.queue_free()
	
	save_file.open(save_filename,File.READ)
	while save_file.get_position() < save_file.get_len():
		var node_data = parse_json(save_file.get_line())
		var new_obj = load(node_data.filename).instance()
		get_node(node_data.parent).call_deferred('add_child',new_obj)
		new_obj.load_save_stats(node_data)
