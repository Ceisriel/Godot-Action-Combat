extends Control

onready var back_weapon_attachment = $"../../../FHuman/Armature/Skeleton/BackWeapon_attachment"
onready var weapon_attachment = $"../../../FHuman/Armature/Skeleton/Weapon_attachment"
var repeating_crossbow: PackedScene = preload("res://RepeatingCrossbow.tscn")
var spear: PackedScene = preload("res://player/Weapons/Spear/spear.glb")
onready var player = $"../../.."

var currentWeaponInstance: Node = null
var persistenceFilePath: String = "user://selected_weapon.txt"
var noWeaponIndex: int = -2  # Index representing no weapon

func _ready():
	if weapon_attachment:
		var selectedWeapon = load_selected_weapon()
		currentWeaponInstance = instance_weapon(selectedWeapon)
		weapon_attachment.add_child(currentWeaponInstance)
		update_player_crossbow(selectedWeapon)
		
		if selectedWeapon != noWeaponIndex:
			player.has_Rcrossbow = false  # If not holding a repeating crossbow initially

func instance_weapon(weaponIndex):
	if weaponIndex == 0:
		return repeating_crossbow.instance()
	elif weaponIndex == 1:
		return spear.instance()

func update_player_crossbow(selectedWeapon):
	player.has_Rcrossbow = selectedWeapon == 0

func load_selected_weapon():
	var file = File.new()
	if file.file_exists(persistenceFilePath):
		file.open(persistenceFilePath, File.READ)
		var selectedWeapon = file.get_var()
		file.close()
		return selectedWeapon
	else:
		return noWeaponIndex

func save_selected_weapon(weaponIndex):
	var file = File.new()
	file.open(persistenceFilePath, File.WRITE)
	file.store_var(weaponIndex)
	file.close()

func dropWeapon():
	if weapon_attachment and currentWeaponInstance:
		var originalScale = Vector3(1, 1, 1)
		var smallerScale = Vector3(0.01, 0.01, 0.01)

		weapon_attachment.remove_child(currentWeaponInstance)
		back_weapon_attachment.remove_child(currentWeaponInstance)  # Remove from back attachment too
		get_tree().root.add_child(currentWeaponInstance)
		
		if currentWeaponInstance.get_parent() == weapon_attachment:
			currentWeaponInstance.scale = originalScale
		else:
			currentWeaponInstance.scale = smallerScale

		var camera = $"../../../Camroot/Camera_holder/Camera"  # Replace with your actual camera path
		var camera_transform = camera.global_transform
		var camera_backward = -camera_transform.basis.z.normalized()

		# Adjust the drop distance and position as needed
		var drop_distance = 3  # Distance from the camera
		var drop_position = camera_transform.origin + camera_backward * drop_distance

		currentWeaponInstance.global_transform.origin = drop_position
		currentWeaponInstance = null  # Reset the current weapon instance

func _on_weapon0_pressed():
	if weapon_attachment:
		if currentWeaponInstance:
			dropWeapon()  # Drop the old weapon first

		currentWeaponInstance = instance_weapon(0)
		weapon_attachment.add_child(currentWeaponInstance)
		save_selected_weapon(0)
		update_player_crossbow(0)

func _on_weapon1_pressed():
	if weapon_attachment:
		if currentWeaponInstance:
			dropWeapon()  # Drop the old weapon first

		currentWeaponInstance = instance_weapon(1)
		weapon_attachment.add_child(currentWeaponInstance)
		save_selected_weapon(1)
		update_player_crossbow(1)

func _physics_process(delta):
	if Input.is_action_just_pressed("drop"):
		# Set the weapon index to represent no weapon
		save_selected_weapon(noWeaponIndex)
		dropWeapon()
		update_player_crossbow(noWeaponIndex)  # Update player state to indicate no weapon


func pickupCrossbow():
	if weapon_attachment:
		if currentWeaponInstance:
			currentWeaponInstance.queue_free()  # Delete the old crossbow
		currentWeaponInstance = instance_weapon(0)
		weapon_attachment.add_child(currentWeaponInstance)
		save_selected_weapon(0)
		update_player_crossbow(0)
