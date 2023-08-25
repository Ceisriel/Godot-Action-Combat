extends Control
onready var parent = $"../../.."
onready var torso_attachment = $"../../../FHuman/Armature/Skeleton/TorsoAttachment"
var torso0: PackedScene = preload("res://player/FHuman/Torso/torso0.glb")
var torso1: PackedScene = preload("res://player/FHuman/Torso/torso1.glb")

var currentTorsoInstance: Node = null
var currentTorsoAnimation: AnimationPlayer = null
var persistenceFilePath: String = "user://selected_torso.txt"

func _ready():
	if torso_attachment:
		var selectedTorso = load_selected_torso()
		currentTorsoInstance = instance_torso(selectedTorso)
		torso_attachment.add_child(currentTorsoInstance)
		currentTorsoAnimation = get_animation_player(currentTorsoInstance)

func instance_torso(torsoIndex):
	if torsoIndex == 0:
		return torso0.instance()
	elif torsoIndex == 1:
		return torso1.instance()

func load_selected_torso():
	var file = File.new()
	if file.file_exists(persistenceFilePath):
		file.open(persistenceFilePath, File.READ)
		var selectedTorso = file.get_var()
		file.close()
		return selectedTorso
	else:
		return 0

func save_selected_torso(torsoIndex):
	var file = File.new()
	file.open(persistenceFilePath, File.WRITE)
	file.store_var(torsoIndex)
	file.close()

func get_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	else:
		for child in node.get_children():
			var player = get_animation_player(child)
			if player:
				return player
		return null


func _on_Torso0_pressed():
	if torso_attachment:
		if currentTorsoInstance:
			currentTorsoInstance.queue_free()

		currentTorsoInstance = instance_torso(0)
		torso_attachment.add_child(currentTorsoInstance)
		currentTorsoAnimation = get_animation_player(currentTorsoInstance)
		save_selected_torso(0)


func _on_Torso1_pressed():
	if torso_attachment:
		if currentTorsoInstance:
			currentTorsoInstance.queue_free()

		currentTorsoInstance = instance_torso(1)
		torso_attachment.add_child(currentTorsoInstance)
		currentTorsoAnimation = get_animation_player(currentTorsoInstance)
		save_selected_torso(1)


func _physics_process(delta):
	if parent.is_walking: 
		currentTorsoAnimation.play("walk cycle",0.2)
	else:
		pass
