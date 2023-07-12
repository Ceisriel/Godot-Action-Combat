extends Node

var save_filename = "user://save_game.save"
var save_filename1 = "user://save_game.save1"



func save_game():
	var save_file = File.new()
	save_file.open(save_filename, File.WRITE)
	var saved_nodes = get_tree().get_nodes_in_group("Save")
	var saved_node_data = []

	for node in saved_nodes:
		if node.filename.empty():
			break
		var node_details = node.get_save_stats()
		saved_node_data.append(node_details)

	save_file.store_line(to_json(saved_node_data))
	save_file.close()

func save_game1():
	var save_file1 = File.new()
	save_file1.open(save_filename1, File.WRITE)
	var saved_nodes = get_tree().get_nodes_in_group("Save")
	var saved_node_data = []

	for node in saved_nodes:
		if node.filename.empty():
			break
		var node_details = node.get_save_stats()
		saved_node_data.append(node_details)

	save_file1.store_line(to_json(saved_node_data))
	save_file1.close()

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

func load_game2():
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
