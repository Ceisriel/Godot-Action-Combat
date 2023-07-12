# Singleton

# If the loading crashes, delete the file in C:\Users\Username\AppData\Roaming\Godot\app_userdata\your_godot_project
# and check if the values loaded match the values saved

extends Node

# Change the line bellow with the nodes you want to access:
onready var player = get_tree().get_root().find_node("Player", true, false)			# to save the player's position
onready var head = get_tree().get_root().find_node("Head", true, false)				# to save the head (camera as child) rotation
onready var weapon = get_tree().get_root().find_node("ShootRayCast", true, false)	# to save the ammo remaining

var path = "user://save.dat" # C:\Users\Username\AppData\Roaming\Godot\app_userdata\your_godot_project
var file = File.new()
var menu = VBoxContainer.new() # A container that will display "> game saved" and "> game loaded" information

var can_use = true # To avoid spamming quick save and quick load a boolean with a yield is used

func _ready():
	pause_mode = PAUSE_MODE_PROCESS # This script can't get paused
	
	add_child(menu)
	
	if file.file_exists(path):
		load_game()

func _input(event):
	if can_use:
		if Input.is_key_pressed(KEY_F5): # Quick save with F5
			save_game()
			can_use = false
			yield(get_tree().create_timer(0.5), "timeout")
			can_use = true
			
		if Input.is_key_pressed(KEY_F6): # Quick load with F6
			load_game()
			can_use = false
			yield(get_tree().create_timer(0.5), "timeout")
			can_use = true

func save_game(): # Note: you can call this function with an Area node to make a checkpoint
	file.open(path, File.WRITE)
	
	# Edit this line with what you want to save:
	file.store_line(to_json({"transform" : var2str(player.transform), "head_rotation" : head.rotation.x, "ammo" : weapon.ammo}))
	file.close()
	
	display_info("> game saved")

func load_game():
	file.open(path, File.READ)
	var data = parse_json(file.get_as_text() )
	file.close()
	
	# Edit the lines bellow with what you want to load:
	player.transform = str2var(data["transform"])
	head.rotation.x = data["head_rotation"]
	weapon.ammo = data["ammo"]
	
	display_info("> game loaded")
	
	return data

func display_info(message): # Display in the top left an information when the text is saved or loaded
	var label = Label.new()
	label.text = message
	label.set("custom_colors/font_color", Color(0,1,0))
	menu.add_child(label)
	yield(get_tree().create_timer(3.0), "timeout")
	label.queue_free()
