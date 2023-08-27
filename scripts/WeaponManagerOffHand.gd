extends Control

onready var player = $"../../.." 
onready var attachment = $"../../../FHuman/Armature/Skeleton/Weapon_attachment_Off_Hand"
var weapon1 :  PackedScene = preload("res://Weapons/Shield/Shield.tscn")
var weapon2: PackedScene = preload("res://Weapons/Sword/Sword.tscn")

var droppedWeapon: Node = null
var currentWeaponInstance: Node = null  


func _on_ItemDetector_body_entered(body):

	if body.is_in_group("Shield"):
		if Input.is_action_pressed("E"):
				var newWeapon1 = weapon1.instance() as Node
		
				if !attachment.has_node(newWeapon1.name):
					if attachment.get_child_count() > 0:
						droppedWeapon = attachment.get_child(0)
						droppedWeapon.queue_free()
						spawnDroppedWeapon(droppedWeapon.global_transform.origin)  # Spawn the dropped weapon on the floor
			
					attachment.add_child(newWeapon1)
					player.has_Sword_Off = false
					player.has_Shield = true
					body.queue_free()
					print("player has shield")

	elif body.is_in_group("Weapon3"):
		if Input.is_action_pressed("E"):
			if !player.has_Spear:
				var newWeapon2 = weapon2.instance() as Node
				if !attachment.has_node(newWeapon2.name):
					if attachment.get_child_count() > 0:
						droppedWeapon = attachment.get_child(0)
						droppedWeapon.queue_free()
						spawnDroppedWeapon(droppedWeapon.global_transform.origin)  # Spawn the dropped weapon on the floor
					attachment.add_child(newWeapon2)
					player.has_Sword_Off = true
					player.has_Shield = false
					body.queue_free()					
					print("Player has secondary sword")

func dropWeapon():
	if attachment.get_child_count() > 0:
		droppedWeapon = attachment.get_child(0)
		droppedWeapon.queue_free()
		print("Weapon dropped")
		droppedWeapon = null  # Reset droppedWeapon variable
		currentWeaponInstance = null  # Reset currentWeaponInstance

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if player.has_Sword:
			player.has_Sword_Off = 	true
	if Input.is_action_just_pressed("ui_cancel"):

		player.has_Shield = true			
	if Input.is_action_just_pressed("drop"):
		dropWeapon()
		spawnWeapon()
		player.has_Shield = false
		player.has_Sword_Off = false
	if player.has_Shield and !player.has_Sword_Off:
		instanceShield()
		player.has_Sword_Off = 	false
	if player.has_Sword_Off and !player.has_Shield:
		instanceSword()
		player.has_Shield= false
		player.has_Spear = false
		player.has_Rcrossbow = false

			
func spawnWeapon():
	var camera = $"../../../Camroot/Camera_holder/Camera"  # Replace with your actual camera path
	var camera_transform = camera.global_transform
	var camera_forward = -camera_transform.basis.z.normalized()

	var spawn_distance = 4.5  # Distance from the camera
	var spawn_position = camera_transform.origin + camera_forward * spawn_distance

	var newWeaponInstance: Node = null

	if player.has_Shield:
		newWeaponInstance = weapon1.instance() as Node
	elif player.has_Sword_Off:
		newWeaponInstance = weapon2.instance() as Node
		
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
		var spawn_distance = 4.5  # Distance from the player
		var spawn_position = position + player_forward * spawn_distance
		droppedWeaponInstance.global_transform.origin = spawn_position
		droppedWeaponInstance.scale = Vector3(0.01, 0.01, 0.01)
		get_tree().root.add_child(droppedWeaponInstance)
		print("Dropped weapon spawned on the floor")

func instanceShield():
	if weapon1 and !attachment.has_node(weapon1.instance().name):
		var newWeaponInstance = weapon1.instance() as Node
		attachment.add_child(newWeaponInstance)
		currentWeaponInstance = newWeaponInstance
		print("Shield instanced")

func instanceSword():
		if weapon2 and !attachment.has_node(weapon2.instance().name):
			var newWeaponInstance = weapon2.instance() as Node
			attachment.add_child(newWeaponInstance)
			currentWeaponInstance = newWeaponInstance
			print("Secondary sword instanced")

