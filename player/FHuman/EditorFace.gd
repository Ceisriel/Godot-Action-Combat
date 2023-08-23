extends Control

onready var face_attachment = $"../../../FHuman/Armature/Skeleton/face_attachment"
onready var parent = $"../../.."
var face0: PackedScene = preload("res://player/FHuman/Face/face0.glb")
var face1: PackedScene = preload("res://player/FHuman/Face/FaceFHuman1.glb")

var currentFaceInstance: Node = null
var currentFaceAnimation: AnimationPlayer = null
var persistenceFilePath: String = "user://selected_face.txt"

func _ready():
	if face_attachment:
		var selectedFace = load_selected_face()
		currentFaceInstance = instance_face(selectedFace)
		face_attachment.add_child(currentFaceInstance)
		currentFaceAnimation = get_animation_player(currentFaceInstance)

func instance_face(faceIndex):
	if faceIndex == 0:
		return face0.instance()
	elif faceIndex == 1:
		return face1.instance()

func load_selected_face():
	var file = File.new()
	if file.file_exists(persistenceFilePath):
		file.open(persistenceFilePath, File.READ)
		var selectedFace = file.get_var()
		file.close()
		return selectedFace
	else:
		return 0

func save_selected_face(faceIndex):
	var file = File.new()
	file.open(persistenceFilePath, File.WRITE)
	file.store_var(faceIndex)
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

func _on_face0_pressed():
	if face_attachment:
		if currentFaceInstance:
			currentFaceInstance.queue_free()

		currentFaceInstance = instance_face(0)
		face_attachment.add_child(currentFaceInstance)
		currentFaceAnimation = get_animation_player(currentFaceInstance)
		save_selected_face(0)

func _on_face1_pressed():
	if face_attachment:
		if currentFaceInstance:
			currentFaceInstance.queue_free()

		currentFaceInstance = instance_face(1)
		face_attachment.add_child(currentFaceInstance)
		currentFaceAnimation = get_animation_player(currentFaceInstance)

		save_selected_face(1)


func _physics_process(delta):
	if Input.is_action_pressed("attack"):
		currentFaceAnimation.play("talk")
