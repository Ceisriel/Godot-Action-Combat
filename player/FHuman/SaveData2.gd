extends Node

const SAVE_DIR = "user://saves/"
var save_path = SAVE_DIR + "save.dat"

onready var player = $".."  
onready var camera = $"../Camroot/Camera_holder/Camera"


func _ready():
	loadPlayerData()


func savePlayerData():
	var data = {
		"vitality": player.vitality,
		"position": player.translation,
		"rotation": player.rotation_degrees,
		"strength": player.strength,
		"energy": player.energy,
		"intelligence": player.intelligence,
		"health": player.health,
		"has_Rcrossbow": player.has_Rcrossbow,
		"has_Spear": player.has_Spear,
		"has_Sword": player.has_Sword,
		"agilityModifierApplied1": player.agilityModifierApplied1,
		"agilityModifierApplied0": player.agilityModifierApplied0,
		"agility": player.agility,
		"accuracy": player.accuracy,
		"camera_rotation": camera.rotation_degrees  # Save the camera's rotation
		}

	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)

	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, "P@paB3ar6969")
	if error == OK:
		file.store_var(data)
		file.close()

func loadPlayerData():
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, "P@paB3ar6969")
		if error == OK:
			var player_data = file.get_var()
			file.close()
			if "vitality" in player_data:
				player.vitality = player_data["vitality"]
			if "position" in player_data:
				player.translation = player_data["position"]
			if "rotation" in player_data:
				player.rotation_degrees = player_data["rotation"]
			if "strength" in player_data:
				player.strength = player_data["strength"]
			if "energy" in player_data:
				player.energy = player_data["energy"]
			if "intelligence" in player_data:
				player.intelligence = player_data["intelligence"]
			if "health" in player_data:
				player.health = player_data["health"]
			if "has_Rcrossbow" in player_data:
				player.has_Rcrossbow = player_data["has_Rcrossbow"]
			if "has_Spear" in player_data:
				player.has_Spear = player_data["has_Spear"]
			if "has_Sword" in player_data:
				player.has_Sword = player_data["has_Sword"]
			if "agilityModifierApplied1" in player_data:
				player.agilityModifierApplied1 = player_data["agilityModifierApplied1"]
			if "agilityModifierApplied0" in player_data:
				player.agilityModifierApplied0 = player_data["agilityModifierApplied0"]
			if "agility" in player_data:
				player.agility = player_data["agility"]  # Set the player's agility
			if "accuracy" in player_data:
				player.accuracy = player_data["accuracy"]
			if "camera_rotation" in player_data:
				camera.rotation_degrees = player_data["camera_rotation"]  # Set the camera's rotation

func resetSavedData():
	var dir = Directory.new()
	if dir.file_exists(save_path):
		dir.remove(save_path)
		print("Saved data reset")

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_P:  # Replace with the desired key code
			resetSavedData()

func console_write(value):
	print(str(value))



func _on_SaveDataTimer_timeout():
	savePlayerData()
