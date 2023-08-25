extends Node

onready var player_script = $".."

# Add any additional variables you might need
var player_position = Vector3.ZERO

func _ready():
	loadData()
	# Teleport the player to the saved position
	player_script.transform.origin = player_position




func saveData():
	var save_file = File.new()
	save_file.open("user://player_data.json", File.WRITE)
	
	var data = {
		"x_pos": $"..".transform.origin.x,
		"y_pos": $"..".transform.origin.y,
		"z_pos": $"..".transform.origin.z
	}
	
	var json_str = JSON.print(data)
	save_file.store_string(json_str)
	
	save_file.close()

func loadData():
	$"..".transform.origin = player_position
	var load_file = File.new()
	if load_file.file_exists("user://player_data.json"):
		load_file.open("user://player_data.json", File.READ)
		
		var json_str = load_file.get_as_text()
		load_file.close()
		
		var json_data = JSON.parse(json_str)
		if json_data.error == OK:
			player_position.x = json_data.result["x_pos"]
			player_position.y = json_data.result["y_pos"]
			player_position.z = json_data.result["z_pos"]
		else:
			print("Error parsing JSON")
	else:
		print("No player data found")


func _on_SaveDataTimer_timeout():
	saveData()
