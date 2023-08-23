extends Control

onready var weapon_attachment = $"../../../FHuman/Armature/Skeleton/Weapon_attachment"
var repeating_crossbow: PackedScene = preload("res://RepeatingCrossbow.tscn")
var sword: PackedScene = preload("res://sword.tscn")
onready var player = $"../../.."

var currentWeaponInstance: Node = null
var persistenceFilePath: String = "user://selected_weapon.txt"

func _ready():
	if weapon_attachment:
		var selectedWeapon = load_selected_weapon()
		currentWeaponInstance = instance_weapon(selectedWeapon)
		weapon_attachment.add_child(currentWeaponInstance)
		update_player_crossbow(selectedWeapon)
		
		if selectedWeapon != 0:
			player.has_Rcrossbow = false  # If not holding a repeating crossbow initially

func instance_weapon(weaponIndex):
	if weaponIndex == 0:
		return repeating_crossbow.instance()
	elif weaponIndex == 1:
		return sword.instance()

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
		return 0

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
		get_tree().root.add_child(currentWeaponInstance)
		
		if currentWeaponInstance.get_parent() == weapon_attachment:
			currentWeaponInstance.scale = originalScale
		else:
			currentWeaponInstance.scale = smallerScale

		currentWeaponInstance.global_transform.origin = player.global_transform.origin + Vector3(0, 1, 4)  # Adjust the position offset as needed
		currentWeaponInstance = null  # Reset the current weapon instance

func _on_weapon0_pressed():
	if weapon_attachment:
		if currentWeaponInstance:
			currentWeaponInstance.queue_free()

		currentWeaponInstance = instance_weapon(0)
		weapon_attachment.add_child(currentWeaponInstance)
		save_selected_weapon(0)
		update_player_crossbow(0)

func _on_weapon1_pressed():
	if weapon_attachment:
		if currentWeaponInstance:
			currentWeaponInstance.queue_free()

		currentWeaponInstance = instance_weapon(1)
		weapon_attachment.add_child(currentWeaponInstance)
		save_selected_weapon(1)
		update_player_crossbow(1)

func _physics_process(delta):
	if Input.is_action_just_pressed("drop"):
		dropWeapon()
	# Continuously update has_Rcrossbow based on the currently held weapon
	update_player_crossbow(load_selected_weapon())
