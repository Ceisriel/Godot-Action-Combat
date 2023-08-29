extends Control

onready var face_attachment = $"../../../FHuman/Armature/Skeleton/face_attachment"
onready var parent = $"../../.."
var face0: PackedScene = preload("res://player/FHuman/Face/face0.glb")
var face1: PackedScene = preload("res://player/FHuman/Face/FaceFHuman1.glb")

var current_face_instance: Node = null

var has_face0 = false
var has_face1 = false

func _ready():
	switchFace()

func switchFace():
	if current_face_instance:
		current_face_instance.queue_free() # Remove the current face instance
	
	if has_face0:
		instanceFace0()
	elif has_face1:
		instanceFace1()
	else:
		instanceFace0() # Default to face0 if no option is selected

func _physics_process(delta):
	switchFace()

func instanceFace0():
	if face_attachment and face0:
		var face_instance = face0.instance()
		face_attachment.add_child(face_instance)
		current_face_instance = face_instance

func instanceFace1():
	if face_attachment and face1:
		var face_instance = face1.instance()
		face_attachment.add_child(face_instance)
		current_face_instance = face_instance

func _on_face0_pressed():
	has_face0 = true
	has_face1 = false

func _on_face1_pressed():
	has_face0 = false
	has_face1 = true

