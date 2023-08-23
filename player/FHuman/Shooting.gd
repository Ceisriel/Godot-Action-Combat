extends Node

var damage = 12
var recoil_angle = 5  # Adjust the initial recoil angle in degrees as needed
var max_recoil_angle = 30  # Maximum recoil angle in degrees
var recoil_speed = 5  # Adjust the speed of the camera's rotation back to normal
var bullets_per_shotgun = 5  # Number of bullets in shotgun mode

var original_rotation = Vector3.ZERO
var current_recoil_angle = 0

onready var parent = get_parent()
onready var weapon = $"../FHuman/Armature/Skeleton/Weapon_attachment"
onready var aim = $"../Camroot/Camera_holder/Camera/Aim"
onready var aim2 = $"../Camroot/Camera_holder/Camera/Aim2"
onready var aim3 = $"../Camroot/Camera_holder/Camera/Aim3"
onready var aim4 = $"../Camroot/Camera_holder/Camera/Aim4"
onready var aim5 = $"../Camroot/Camera_holder/Camera/Aim5"
onready var aim6 = $"../Camroot/Camera_holder/Camera/Aim6"
onready var camera = $"../Camroot/Camera_holder/Camera"

onready var firerate_controller = $Timer
var firerate = 0.25
var shotgun_mode : bool

func _ready():
	firerate_controller.wait_time = firerate
	firerate_controller.start()
	original_rotation = camera.rotation_degrees

func shoot():
	if parent.has_Rcrossbow and (!parent.is_sprinting or !parent.is_running):
		if Input.is_action_pressed("attack"):
			parent.is_aiming = true	
			if !shotgun_mode:				
				if aim.is_colliding():
					var body = aim.get_collider()
					if body.is_in_group("Enemy"):
						body.takeDamage(damage)
				# Apply recoil effect to the camera by rotating it upwards
				camera.rotation_degrees.x += recoil_angle
				current_recoil_angle = recoil_angle
			if current_recoil_angle > max_recoil_angle:
				current_recoil_angle = max_recoil_angle
		else:
			parent.is_aiming = false
			
func shootShotgun(): 
	if parent.has_Rcrossbow and (!parent.is_sprinting or !parent.is_running):
		if Input.is_action_just_pressed("attack"):
			parent.is_aiming = true
			for i in range(bullets_per_shotgun):
					if aim.is_colliding():
						var body = aim.get_collider()
						if body.is_in_group("Enemy"):
							body.takeDamage(damage)
					if aim2.is_colliding():
						var body = aim2.get_collider()
						if body.is_in_group("Enemy"):
							body.takeDamage(damage)		
					if aim3.is_colliding():
						var body = aim3.get_collider()
						if body.is_in_group("Enemy"):
							body.takeDamage(damage)		
					if aim4.is_colliding():
						var body = aim4.get_collider()
						if body.is_in_group("Enemy"):
							body.takeDamage(damage)			
			camera.rotation_degrees.x += recoil_angle
			current_recoil_angle = recoil_angle	

func _on_Timer_timeout():
	shoot()

func _physics_process(delta):
	switchFireMode()
	if shotgun_mode: 
		shootShotgun()
		
	if current_recoil_angle > 0:
		# Interpolate the camera's rotation back to the original position
		var interpolation_amount = recoil_speed * get_process_delta_time()
		camera.rotation_degrees = camera.rotation_degrees.linear_interpolate(original_rotation, interpolation_amount)
		
		current_recoil_angle -= interpolation_amount

func switchFireMode():
	if Input.is_action_just_pressed("guard"):
		shotgun_mode = !shotgun_mode	
	if shotgun_mode:
		damage = 1.75
		recoil_angle = 5
		recoil_speed = 0.75
		firerate = 1
	else: 
		damage = 12
		recoil_angle = 3.5
		recoil_speed = 0.5
		firerate = 0.2	
