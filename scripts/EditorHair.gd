extends Control

onready var hair_attachment = $"../../../FHuman/Armature/Skeleton/hair_attachment"
var hair0: PackedScene = preload("res://player/FHuman/Hair/Hair0.glb")
var hair1: PackedScene = preload("res://player/FHuman/Hair/Hair1.glb")
var hair2: PackedScene = preload("res://player/FHuman/Hair/Hair2.glb")
var hair3: PackedScene = preload("res://player/FHuman/Hair/hair3.glb")
var hair4: PackedScene = preload("res://player/FHuman/Hair/hair4.glb")
var hair5: PackedScene = preload("res://player/FHuman/Hair/Hair5.glb")

var current_hair_instance: Node = null

var has_hair0 = false
var has_hair1 = false
var has_hair2 = false
var has_hair3 = false
var has_hair4 = false
var has_hair5 = false

func _ready():
	switchHair()

func switchHair():
	if current_hair_instance:
		current_hair_instance.queue_free() # Remove the current hair instance
	
	if has_hair0:
		instanceHair0()
	elif has_hair1:
		instanceHair1()
	elif has_hair2:
		instanceHair2()	
	elif has_hair3:
		instanceHair3()
	elif has_hair4:
		instanceHair4()	
	elif has_hair5:
		instanceHair5()
	else:
		instanceHair0()	
	# Add cases for other hair options

func _physics_process(delta):
	switchHair()

func instanceHair0():
	if hair_attachment and hair0:
		var hair_instance = hair0.instance()
		hair_attachment.add_child(hair_instance)
		current_hair_instance = hair_instance

func instanceHair1():
	if hair_attachment and hair1:
		var hair_instance = hair1.instance()
		hair_attachment.add_child(hair_instance)
		current_hair_instance = hair_instance
func instanceHair2():
	if hair_attachment and hair2:
		var hair_instance = hair2.instance()
		hair_attachment.add_child(hair_instance)
		current_hair_instance = hair_instance
func instanceHair3():
	if hair_attachment and hair3:
		var hair_instance = hair3.instance()
		hair_attachment.add_child(hair_instance)
		current_hair_instance = hair_instance		
func instanceHair4():
	if hair_attachment and hair4:
		var hair_instance = hair4.instance()
		hair_attachment.add_child(hair_instance)
		current_hair_instance = hair_instance
func instanceHair5():
	if hair_attachment and hair5:
		var hair_instance = hair5.instance()
		hair_attachment.add_child(hair_instance)
		current_hair_instance = hair_instance		
# Add instance functions for other hair options

func _on_hair0_pressed():
	has_hair0 = true
	has_hair1 = false
	has_hair2 = false	
	has_hair3 = false
	has_hair4 = false
	has_hair5 = false
func _on_hair1_pressed():
	has_hair0 = false
	has_hair1 = true
	has_hair2 = false	
	has_hair3 = false
	has_hair4 = false
	has_hair5 = false
func _on_hair2_pressed():
	has_hair0 = false
	has_hair1 = false
	has_hair2 = true	
	has_hair3 = false
	has_hair4 = false
	has_hair5 = false	


func _on_hair3_pressed():
	has_hair0 = false
	has_hair1 = false
	has_hair2 = false	
	has_hair3 = true
	has_hair4 = false
	has_hair5 = false	



func _on_hair4_pressed():
	has_hair0 = false
	has_hair1 = false
	has_hair2 = false	
	has_hair3 = false
	has_hair4 = true
	has_hair5 = false	


func _on_hair5_pressed():
	has_hair0 = false
	has_hair1 = false
	has_hair2 = false	
	has_hair3 = false
	has_hair4 = false
	has_hair5 = true	



