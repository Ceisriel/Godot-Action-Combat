extends Node


onready var arrow = preload("res://Weapons/Arrow/arrow.tscn")
onready var muzle = $"../muzzle"
onready var aim = $"../Camroot/Camera_holder/Camera/Aim"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if Input.is_action_just_pressed("crouch"):
		shoot()
		
func shoot():
	var a = arrow.instance()
	muzle.add_child(a)
