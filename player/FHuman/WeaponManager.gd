extends Control

onready var player = $"../../.."  # Adjust the path based on your scene structure
onready var attachment = $"../../../FHuman/Armature/Skeleton/Weapon_attachment"
var weapon1: PackedScene = preload("res://RepeatingCrossbow.tscn")
var weapon2: PackedScene = preload("res://player/Weapons/Spear/Spear.tscn")
var droppedWeapon: Node = null
var currentWeaponInstance: Node = null
var persistenceFilePath: String = "user://selected_weapon.txt"

func _ready():
	loadSelectedWeapon()

	if currentWeaponInstance:
		attachment.add_child(currentWeaponInstance)

func instanceWeapon(weaponIndex):
	if weaponIndex == 1:
		return weapon1.instance()
	elif weaponIndex == 2:
		return weapon2.instance()
	else:
		return null  # No weapon instance

func loadSelectedWeapon():
	var file = File.new()
	if file.file_exists(persistenceFilePath):
		file.open(persistenceFilePath, File.READ)
		var selectedWeaponIndex = file.get_var()
		file.close()
		currentWeaponInstance = instanceWeapon(selectedWeaponIndex)
		updatePlayerWeaponStatus(selectedWeaponIndex)
	else:
		currentWeaponInstance = null
		updatePlayerWeaponStatus(0)  # Empty-handed

func saveSelectedWeapon(weaponIndex):
	var file = File.new()
	file.open(persistenceFilePath, File.WRITE)
	file.store_var(weaponIndex)
	file.close()

func updatePlayerWeaponStatus(weaponIndex):
	player.has_Rcrossbow = (weaponIndex == 1)
	player.has_Spear = (weaponIndex == 2)

func _on_ItemDetector_body_entered(body):
	if body.is_in_group("Weapon1"):
		if Input.is_action_pressed("E"):
			var newWeapon1 = weapon1.instance() as Node
		
			if !attachment.has_node(newWeapon1.name):
				if attachment.get_child_count() > 0:
					droppedWeapon = attachment.get_child(0)
					droppedWeapon.queue_free()
					spawnDroppedWeapon(droppedWeapon.global_transform.origin)
			
				attachment.add_child(newWeapon1)
				body.queue_free()
				print("Player has a repeating crossbow")
				saveSelectedWeapon(1)
				updatePlayerWeaponStatus(1)

	elif body.is_in_group("Weapon2"):
		if Input.is_action_pressed("E"):
			var newWeapon2 = weapon2.instance() as Node
		
			if !attachment.has_node(newWeapon2.name):
				if attachment.get_child_count() > 0:
					droppedWeapon = attachment.get_child(0)
					droppedWeapon.queue_free()
					spawnDroppedWeapon(droppedWeapon.global_transform.origin)
			
				attachment.add_child(newWeapon2)
				body.queue_free()
				print("Player has a spear")
				saveSelectedWeapon(2)
				updatePlayerWeaponStatus(2)

func dropWeapon():
	if attachment.get_child_count() > 0:
		droppedWeapon = attachment.get_child(0)
		droppedWeapon.queue_free()
		print("Weapon dropped")
		droppedWeapon = null
		currentWeaponInstance = null
		updatePlayerWeaponStatus(0)  # Empty-handed

func _physics_process(delta):
	if Input.is_action_just_pressed("drop"):
		dropWeapon()
		spawnWeapon()

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

	if newWeaponInstance:
		newWeaponInstance.global_transform.origin = spawn_position
		newWeaponInstance.scale = Vector3(0.01, 0.01, 0.01)
		currentWeaponInstance = newWeaponInstance
		get_tree().root.add_child(newWeaponInstance)
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

