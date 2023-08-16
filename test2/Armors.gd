extends Node


onready var parent = $".."
onready var naked_torso = $"../FHuman/Armature/Skeleton/body0"
onready var warlock_torso = $"../FHuman/Armature/Skeleton/body1"

var wearing_warlocktorso = false
var increaseApplied = false

func Armors():
	if wearing_warlocktorso and !increaseApplied:
		warlock_torso.visible = true
		naked_torso.visible = false
		# stats
		parent.vitality += 10
		increaseApplied = true

func _on_ItemDetector_area_entered(area):
	if area.is_in_group("item"):
		wearing_warlocktorso = true
		

func _physics_process(delta):
	Armors()


