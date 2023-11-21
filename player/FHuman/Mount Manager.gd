extends Control

onready var player = $"../../.."
onready var attachment = $"../../../FHuman/Armature/Skeleton/mount_attachment"
onready var camera = $"../../../Camroot/Camera_holder/Camera"

var horse1: PackedScene = preload("res://Creatures/Mounts/horse/Horse.tscn")
var horse2: PackedScene = preload("res://Creatures/Mounts/horse/Horse2.tscn")

var currentHorseInstance: Node = null  
var horse_effect_applied: bool = false


func _on_ItemDetector_body_entered(body):
	if body.is_in_group("Horse"):
		if Input.is_action_pressed("E"):
			# Check if there is no current horse instance
			if currentHorseInstance == null:
				# Delete the existing horse instance from the world
				body.queue_free()

				# Instantiate the horse scene
				currentHorseInstance = horse1.instance()
				# Set the scale of the horse
				currentHorseInstance.scale *= Vector3(30, 30, 30)
				# Add the horse as a child of the attachment node
				attachment.add_child(currentHorseInstance)
				print("Player has horse1")       
				player.has_Horse = true         

	elif body.is_in_group("Horse2"):
		if Input.is_action_pressed("E"):
			# Check if there is no current horse instance
			if currentHorseInstance == null:
				# Delete the existing horse instance from the world
				body.queue_free()

				# Instantiate the horse scene
				currentHorseInstance = horse2.instance()
				# Set the scale of the horse
				currentHorseInstance.scale *= Vector3(40, 40, 40)
				# Add the horse as a child of the attachment node
				attachment.add_child(currentHorseInstance)
				print("Player has horse2")
				player.has_Horse = true    
				 
func _physics_process(delta):
	if Input.is_action_pressed("drop"):  # Assuming "D" key for dropping off the horse
		drop_off_horse()
		player.has_Horse = false
	if player.has_Horse:
		HorseEffect(true)	

func HorseEffect(active: bool):
	if active and not horse_effect_applied:
		horse_effect_applied = true
		# Apply horse effect, adjust the boost values as needed
		player.walk_speed *= 2  
		player.run_speed *= 2
		player.agility += 0.75
		
	elif not active and horse_effect_applied:
		# Remove horse effect
		player.walk_speed = player.original_walk_speed  # Reset walk speed to its original value
		player.run_speed = player.original_run_speed     # Reset run speed to its original value
		player.agility -= 0.75
		horse_effect_applied = false



# In the drop_off_horse function
func drop_off_horse():
	if currentHorseInstance != null:
		# Set the scale of the horse back to its original size
		currentHorseInstance.scale = Vector3(1, 1, 1)
		
		# Remove the current horse instance from the attachment node
		attachment.remove_child(currentHorseInstance)
		
		# Call the HorseEffect function to remove the horse effect
		HorseEffect(false)
		
		# Get the global transform of the camera
		var camera_transform = camera.global_transform
		
		# Set the position of the horse in front of the camera
		currentHorseInstance.global_transform.origin = camera_transform.origin + camera_transform.basis.z * (-5.0)  # Adjust the distance as needed
		
		# Instance the horse back as a child of the root node
		get_tree().root.add_child(currentHorseInstance)
		
		currentHorseInstance = null
		print("Player dropped off the horse in front of the camera")
