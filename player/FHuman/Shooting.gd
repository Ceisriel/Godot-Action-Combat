extends Node

var damage = 12
onready var parent = get_parent()
onready var weapon = $"../FHuman/Armature/Skeleton/Weapon_attachment"
onready var aim = $"../Camroot/Camera_holder/Camera/Aim"
onready var firerate_controller = $Timer
var firerate = 0.5

func _ready():
	firerate_controller.wait_time = firerate
	firerate_controller.start()

func shoot():
	if parent.has_Rcrossbow and !parent.is_sprinting or !parent.is_running:
		if Input.is_action_pressed("attack"):
			parent.is_aiming = true
			if aim.is_colliding():
				var body = aim.get_collider()
				if body.is_in_group("Enemy"):
					body.takeDamage(damage)
		else:
			parent.is_aiming = false

func _on_Timer_timeout():
	shoot()
