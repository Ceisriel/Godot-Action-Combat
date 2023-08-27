extends Control

onready var player = $"../../.." 
onready var attachment = $"../../../FHuman/Armature/Skeleton/Weapon_attachment"
var weapon1: PackedScene = preload("res://player/Weapons/RepeatingCrossbow/RepeatingCrossbow.tscn")
var weapon2: PackedScene = preload("res://player/Weapons/Spear/Spear.tscn")
var weapon3: PackedScene = preload("res://player/Weapons/Sword/Sword.tscn")

var droppedWeapon: Node = null
var currentWeaponInstance: Node = null  


func _on_ItemDetector_body_entered(body):

	if body.is_in_group("Weapon1"):
		if Input.is_action_pressed("E"):
			var newWeapon1 = weapon1.instance() as Node
		
			if !attachment.has_node(newWeapon1.name):
				if attachment.get_child_count() > 0:
					droppedWeapon = attachment.get_child(0)
					droppedWeapon.queue_free()
					spawnDroppedWeapon(droppedWeapon.global_transform.origin)  # Spawn the dropped weapon on the floor
			
				attachment.add_child(newWeapon1)
				player.has_Rcrossbow = true
				player.has_Spear = false
				player.has_Sword = false
				player.has_Sword_Off = false
				body.queue_free()
				print("Player has a repeating crossbow")

	elif body.is_in_group("Weapon2"):
		if Input.is_action_pressed("E"):
			var newWeapon2 = weapon2.instance() as Node
		
			if !attachment.has_node(newWeapon2.name):
				if attachment.get_child_count() > 0:
					droppedWeapon = attachment.get_child(0)
					droppedWeapon.queue_free()
					spawnDroppedWeapon(droppedWeapon.global_transform.origin)  # Spawn the dropped weapon on the floor
			
				attachment.add_child(newWeapon2)
				player.has_Spear = true
				player.has_Rcrossbow = false
				player.has_Sword = false
				player.has_Sword_Off = false
				body.queue_free()
				print("Player has a spear")
	elif body.is_in_group("Weapon3"):
		if Input.is_action_pressed("E"):
			var newWeapon3 = weapon3.instance() as Node
		
			if !attachment.has_node(newWeapon3.name):
				if attachment.get_child_count() > 0:
					droppedWeapon = attachment.get_child(0)
					droppedWeapon.queue_free()
					spawnDroppedWeapon(droppedWeapon.global_transform.origin)  # Spawn the dropped weapon on the floor
			
				attachment.add_child(newWeapon3)
				player.has_Spear = false
				player.has_Rcrossbow = false
				player.has_Sword = true
				body.queue_free()
				if player.has_Sword:
					player.has_Sword_Off = true 
				print("Player has a sword")	

func dropWeapon():
	if attachment.get_child_count() > 0:
		droppedWeapon = attachment.get_child(0)
		droppedWeapon.queue_free()
		print("Weapon dropped")
		droppedWeapon = null  # Reset droppedWeapon variable
		currentWeaponInstance = null  # Reset currentWeaponInstance

func _physics_process(delta):

		
	if Input.is_action_just_pressed("drop"):
		dropWeapon()
		spawnWeapon()
		player.has_Rcrossbow = false
		player.has_Spear = false
		player.has_Sword = false

	if player.has_Rcrossbow:
		instanceCrossbow()
		player.has_Spear = false
		player.has_Sword = false
		player.has_Sword_Off = false		
	if player.has_Spear:
		player.has_Rcrossbow = false
		player.has_Sword = false
		player.has_Sword_Off = false
		instanceSpear()
	if player.has_Sword:
		player.has_Rcrossbow = false
		player.has_Spear = false
		instanceSword()
func spawnWeapon():
	var camera = $"../../../Camroot/Camera_holder/Camera"  # Replace with your actual camera path
	var camera_transform = camera.global_transform
	var camera_forward = -camera_transform.basis.z.normalized()

	var spawn_distance = 6.0  # Distance from the camera
	var spawn_position = camera_transform.origin + camera_forward * spawn_distance

	var newWeaponInstance: Node = null

	if player.has_Rcrossbow:
		newWeaponInstance = weapon1.instance() as Node
	elif player.has_Spear:
		newWeaponInstance = weapon2.instance() as Node
	elif player.has_Sword:
		newWeaponInstance = weapon3.instance() as Node
		
		
	if newWeaponInstance:
		newWeaponInstance.global_transform.origin = spawn_position
		newWeaponInstance.scale = Vector3(0.01, 0.01, 0.01)  # Set the scale to 0.01
		get_tree().root.add_child(newWeaponInstance)  # Add to the root node of the scene
		print("Weapon spawned on the floor")
	else:
		print("No weapon to spawn")

func spawnDroppedWeapon(position: Vector3):
	if droppedWeapon:
		var droppedWeaponInstance = droppedWeapon.duplicate()
		var player_forward = +player.global_transform.basis.z.normalized()
		var spawn_distance = 6.0  # Distance from the player
		var spawn_position = position + player_forward * spawn_distance
		droppedWeaponInstance.global_transform.origin = spawn_position
		droppedWeaponInstance.scale = Vector3(0.01, 0.01, 0.01)
		get_tree().root.add_child(droppedWeaponInstance)
		print("Dropped weapon spawned on the floor")

func instanceCrossbow():
	if weapon1 and !attachment.has_node(weapon1.instance().name):
		var newWeaponInstance = weapon1.instance() as Node
		attachment.add_child(newWeaponInstance)
		currentWeaponInstance = newWeaponInstance
		print("Crossbow instanced")

func instanceSpear():
	if weapon2 and !attachment.has_node(weapon2.instance().name):
		var newWeaponInstance = weapon2.instance() as Node
		attachment.add_child(newWeaponInstance)
		currentWeaponInstance = newWeaponInstance
		print("Spear instanced")

func instanceSword():
	if weapon3 and !attachment.has_node(weapon3.instance().name):
		var newWeaponInstance = weapon3.instance() as Node
		attachment.add_child(newWeaponInstance)
		currentWeaponInstance = newWeaponInstance
		print("Spear instanced")		
