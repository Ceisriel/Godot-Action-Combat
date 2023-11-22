extends Control

onready var player = $"../../.."
onready var attachment = $"../../../FHuman/Armature/Skeleton/mount_attachment"
onready var camera = $"../../../Camroot/Camera_holder/Camera"
var model0: PackedScene = preload("res://Creatures/Mounts/horse/Horse1/Horse1.tscn")
var model1: PackedScene = preload("res://Creatures/Mounts/horse/Horse2/horse2.tscn")
var currentInstance: Node = null  
var effect1_applied: bool = false

var has_model0 = false
var has_model1 = false

func switch():
	if has_model0:
		# Check if there is no current horse instance
		if currentInstance == null:
			# Instantiate the horse scene
			currentInstance = model0.instance()
			# Set the scale of the horse
			currentInstance.scale *= Vector3(100, 100, 100)
			# Add the horse as a child of the attachment node
			attachment.add_child(currentInstance)
			print("Player has horse1")
			player.has_ride = true
	else: 
		player.has_ride = false

func drop():
	if has_model0:
		if currentInstance != null:
			# Remove the instanced model from the attachment
			attachment.remove_child(currentInstance)
			# Set the scale to 1, 1, 1
			currentInstance.scale = Vector3(1, 1, 1)
			# Calculate the position in front of the camera
			# Get the global transform of the camera
			var camera_transform = camera.global_transform
			# Set the position of the horse in front of the camera
			currentInstance.global_transform.origin = camera_transform.origin + camera_transform.basis.z * (-5.0)  # Adjust the distance as needed		
			# Instance the horse back as a child of the root node
			get_tree().root.add_child(currentInstance)

			print("Horse1 dropped")
			# Reset variables
			has_model0 = false
			currentInstance = null
			player.has_ride = false

func _on_ItemDetector_body_entered(body):
	if body.is_in_group("Horse"):
		if Input.is_action_pressed("E"):
			has_model0 = true

func _physics_process(delta):
	switch()
	if Input.is_action_just_pressed("drop"):
		drop()
		has_model0 = false
		player.has_ride = false



