extends Node

const SAVE_DIR = "user://saves/"
var save_path = SAVE_DIR + "save.dat"
onready var armors = $"../Armors"
onready var player = $".."  
onready var camera = $"../Camroot/Camera_holder/Camera"
onready var hair = $"../GUI/Edit_Character/EditorHair"
onready var face = $"../GUI/Edit_Character/EditorFace"
onready var Character = $"../GUI/Character"
onready var rides = $"../GUI/Edit_Character/MountManager"
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
		"has_Shield": player.has_Shield,		
		"has_Sword_Off": player.has_Sword_Off,
		"has_dress": armors.has_dress,
		"has_jute": armors.has_jute,
		"has_leather": armors.has_leather,
		"has_semi_plate": armors.has_semi_plate,
		"is_naked": armors.is_naked,
		"jute_modified": armors.jute_modified,					
		"dress_modified": armors.dress_modified,
		"leather_modified": armors.leather_modified,	
		"semip_modified": armors.semip_modified,	
		"agilityModifierApplied1": player.agilityModifierApplied1,
		"agilityModifierApplied0": player.agilityModifierApplied0,
		"agility": player.agility,
		"accuracy": player.accuracy,
		"attribute": player.attribute,
		"has_hair0": hair.has_hair0,
		"has_hair1": hair.has_hair1,	
		"has_hair2": hair.has_hair2,
		"has_hair3": hair.has_hair3,
		"has_hair4": hair.has_hair4,
		"has_hair5": hair.has_hair5,
		"has_face0": face.has_face0,
		"has_face1": face.has_face1,
		"has_ride": player.has_ride,
		"has_model0": rides.has_model0,
		"has_model1": rides.has_model1,
		"has_model2": rides.has_model2,
		"has_model3": rides.has_model3,
		"has_model4": rides.has_model4,
		"has_model5": rides.has_model5,	
		"has_model6": rides.has_model6,	
		"has_model7": rides.has_model7,		
		"playerName": Character.playerName,
		"camera_rotation": camera.rotation_degrees,  # Save the camera's rotation
		"effect0_horse": rides.effect0_applied
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
			if "has_Shield" in player_data:
				player.has_Shield = player_data["has_Shield"]				
			if "has_Sword_Off" in player_data:
				player.has_Sword_Off = player_data["has_Sword_Off"]	
			if "has_dress" in player_data:
				armors.has_dress = player_data["has_dress"]
			if "has_jute" in player_data:
				armors.has_jute = player_data["has_jute"]	
			if "has_leather" in player_data:
				armors.has_leather = player_data["has_leather"]	
			if "has_semi_plate" in player_data:
				armors.has_semi_plate = player_data["has_semi_plate"]											
			if "is_naked" in player_data:
				armors.is_naked = player_data["is_naked"]	
			if "jute_modified" in player_data:
				armors.jute_modified = player_data["jute_modified"]						
			if "dress_modified" in player_data:
				armors.dress_modified = player_data["dress_modified"]				
			if "leather_modified" in player_data:
				armors.leather_modified = player_data["leather_modified"]
			if "semip_modified" in player_data:
				armors.semip_modified = player_data["semip_modified"]				
			if "agilityModifierApplied1" in player_data:
				player.agilityModifierApplied1 = player_data["agilityModifierApplied1"]
			if "agilityModifierApplied0" in player_data:
				player.agilityModifierApplied0 = player_data["agilityModifierApplied0"]
			if "agility" in player_data:
				player.agility = player_data["agility"]  # Set the player's agility
			if "accuracy" in player_data:
				player.accuracy = player_data["accuracy"]
			if "attribute" in player_data:
				player.attribute = player_data["attribute"]
			if "has_hair0" in player_data:
				hair.has_hair0 = player_data["has_hair0"]	
			if "has_hair1" in player_data:
				hair.has_hair1 = player_data["has_hair1"]	
			if "has_hair2" in player_data:
				hair.has_hair2 = player_data["has_hair2"]	
			if "has_hair3" in player_data:
				hair.has_hair3 = player_data["has_hair3"]
			if "has_hair4" in player_data:
				hair.has_hair4 = player_data["has_hair4"]	
			if "has_hair5" in player_data:
				hair.has_hair5 = player_data["has_hair5"]	
			if "has_face0" in player_data:
				face.has_face0 = player_data["has_face0"]
			if "has_face1" in player_data:
				face.has_face1 = player_data["has_face1"]
			if "playerName" in player_data:
				Character.playerName = player_data["playerName"]	
			if "camera_rotation" in player_data:
				camera.rotation_degrees = player_data["camera_rotation"]  # Set the camera's rotation
			if "effect0_horse" in player_data:
				rides.effect0_applied = player_data["effect0_horse"]
			if "has_ride" in player_data:
				player.has_ride = player_data["has_ride"]
			if "has_model0" in player_data:
				rides.has_model0 = player_data["has_model0"]
			if "has_model1" in player_data:
				rides.has_model1 = player_data["has_model1"]
			if "has_model2" in player_data:
				rides.has_model2 = player_data["has_model2"]
			if "has_model3" in player_data:
				rides.has_model3 = player_data["has_model3"]
			if "has_model4" in player_data:
				rides.has_model4 = player_data["has_model4"]
			if "has_model5" in player_data:
				rides.has_model5 = player_data["has_model5"]
			if "has_model6" in player_data:
				rides.has_model6 = player_data["has_model6"]
			if "has_model7" in player_data:
				rides.has_model7 = player_data["has_model7"]
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


func _on_Button_pressed():
	loadPlayerData()

