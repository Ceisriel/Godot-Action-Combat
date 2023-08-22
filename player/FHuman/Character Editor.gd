extends Control

onready var hair_attachment = $"../../../FHuman/Armature/Skeleton/HairAttachment"
var hair0: PackedScene = preload("res://player/FHuman/Hair/Hair0.glb")
var hair1: PackedScene = preload("res://player/FHuman/Hair/Hair1.glb")
var hair2: PackedScene = preload("res://player/FHuman/Hair/Hair2.glb")

var currentHairInstance: Node = null
var persistenceFilePath: String = "user://selected_hair.txt"

func _ready():
	if hair_attachment:
		var selectedHair = load_selected_hair()
		currentHairInstance = instance_hair(selectedHair)
		hair_attachment.add_child(currentHairInstance)

func instance_hair(hairIndex):
	if hairIndex == 0:
		return hair0.instance()
	elif hairIndex == 1:
		return hair1.instance()
	elif hairIndex == 2:
		return hair2.instance()

func load_selected_hair():
	var file = File.new()
	if file.file_exists(persistenceFilePath):
		file.open(persistenceFilePath, File.READ)
		var selectedHair = file.get_var()
		file.close()
		return selectedHair
	else:
		return 0

func save_selected_hair(hairIndex):
	var file = File.new()
	file.open(persistenceFilePath, File.WRITE)
	file.store_var(hairIndex)
	file.close()

func _on_hair0_pressed():
	if hair_attachment:
		if currentHairInstance:
			currentHairInstance.queue_free()

		currentHairInstance = instance_hair(0)
		hair_attachment.add_child(currentHairInstance)
		save_selected_hair(0)

func _on_hair1_pressed():
	if hair_attachment:
		if currentHairInstance:
			currentHairInstance.queue_free()

		currentHairInstance = instance_hair(1)
		hair_attachment.add_child(currentHairInstance)
		save_selected_hair(1)

func _on_hair2_pressed():
	if hair_attachment:
		if currentHairInstance:
			currentHairInstance.queue_free()

		currentHairInstance = instance_hair(2)
		hair_attachment.add_child(currentHairInstance)
		save_selected_hair(2)
