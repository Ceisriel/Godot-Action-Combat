extends Node

var RepeatingCrossbow: PackedScene = preload("res://player/Weapons/RepeatingCrossbow/RepeatingCrossbow.glb")
onready var weapon_holder = $"../FHuman/Armature/Skeleton/Weapon_attachment"
onready var parent = get_parent()


func _on_ItemDetector_body_entered(body):
	if body.is_in_group("RepeatingCrossbow"):
		body.queue_free()  # Delete the colliding body
		var newCrossbow = RepeatingCrossbow.instance()
		weapon_holder.add_child(newCrossbow)
		parent.has_Rcrossbow = true
