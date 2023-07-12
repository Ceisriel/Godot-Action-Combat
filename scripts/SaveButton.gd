extends Button

var save_filename = "user://save_game.save"

func _ready():
	connect("pressed", self, "_on_Button_pressed")

func _on_Button_pressed():
	save_game()

func save_game():
	var save_file = File.new()
	save_file.open(save_filename, File.WRITE)
	var saved_nodes = get_tree().get_nodes_in_group("Save")

	for node in saved_nodes:
		if node.filename.empty():
			break
		var node_details = node.get_save_stats()
		save_file.store_line(to_json(node_details))
	save_file.close()
