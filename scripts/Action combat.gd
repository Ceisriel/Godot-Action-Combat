extends KinematicBody

# Camera movement
onready var head = $Camroot
onready var head_pos = head.transform
onready var campivot = $Camroot/Camera_holder
onready var camera = $Camroot/Camera_holder/Camera
# Animation
onready var animation = $Knight/AnimationPlayer

# Allows to pick your character's mesh from the inspector
export (NodePath) var PlayerCharacterMesh
export onready var player_mesh = get_node(PlayerCharacterMesh)

# Gamplay mechanics and Inspector tweakables
export var gravity = 9.8
export var jump_force = 5
export var walk_speed = 8
export var run_speed = 16
export var teleport_distance = 35
export var dash_power = 12
export (float) var mouse_sense = 0.1

# Dodge
export var double_press_time: float = 0.3
var dash_count: int = 0
var dash_timer: float = 0.0
var dash_count2: int = 0
var dash_timer2: float = 0.0
var dash_count3: int = 0
var dash_timer3: float = 0.0
var dash_count4: int = 0
var dash_timer4: float = 0.0

# Condition States
var is_rolling = bool()
var is_walking = bool()
var is_running = bool()
var is_sprinting = bool()
var is_aiming = bool()
var mousemode = bool()
var staggered = false
var blocking = false
var dodge = bool()

# Physics values
var direction = Vector3()
var horizontal_velocity = Vector3()
var aim_turn = float()
var movement = Vector3()
var vertical_velocity = Vector3()
var movement_speed = int()
var angular_acceleration = int()
var acceleration = int()
var wall_normal

#player stats 
var maxhealth = 500.0
var health = 500.0
var maxenergy = 50.0
var energy = 50.0
var defense = 4.25
var damage = 60

func setStateIdle():
	animation.play("idle", 0.2, 0.3)
func hurt():
	animation.play("t pose")	
func setStateWalk():
	animation.play("walk", 0.25)
func setStateWalkBack():
	animation.play_backwards("walk")
func setStateAttack():
	animation.play("base attack", 0.1)
func setStateGuard():
	animation.play("t pose", 0.1)	
func setStateRun():
	animation.play("run", 0.1)
func setStateSprint():
	animation.play("run", 0, 0.95)
func setStateSlide():
	animation.play("slide")
func setStateJump():
	animation.play("jump")
	
#Damage 
onready var hitbox = $Knight/Hitbox
func attack():
	var enemies = hitbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.has_method("onhit"):
			enemy.onhit(damage)


func _ready(): 
	health = maxhealth
	energy = maxenergy
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/Camera_holder.global_transform.basis.get_euler().y)
#getting damaged
func onhitP(damage):
	if not blocking: 
		health -= (damage - defense)
		staggered = true
	else:
		staggered = false	
		

	
	
func _input(event):  # All major mouse and button input events
	# Get mouse input for camera rotation
	if event is InputEventMouseMotion and (mousemode == false):
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(+event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-60), deg2rad(90))
	
	# Toggle mouse mode

	if Input.is_action_just_pressed("ESC"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mousemode = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mousemode = false
func _process(delta):
	# Update energy bar
	$GUI/EnergyBar.value = int((energy / maxenergy) * 100)
	$GUI/EnergyBar/Label.text = "Energy: " + str(energy) + "/" +str(maxenergy)
	# Update health bar
	$GUI/HealthBar.value = int((health / maxhealth) * 100)
	$GUI/HealthBar/Label.text = "Health: " + str(health) + "/" +str(maxhealth)



func _physics_process(delta: float):
#healthbar and energy text
	if health <= 0:
		close_game()
# Raycast to detect obstacles in front of the character
	var ray_length = 1  # Adjust this value based on the desired length of the ray
	var ray_direction = direction.normalized()  # Use the same direction as the character's movement
	var ray_start = translation + Vector3(0, 0.15, 0)  # Adjust the starting position of the ray based on your character's position
	var ray_end = ray_start + ray_direction * ray_length
	var climb_speed = 2
	var is_climbing = false
	var enabled_climbing = true
	var ray_cast = get_world().direct_space_state.intersect_ray(ray_start, ray_end, [self])

	if Input.is_action_pressed("sprint") or Input.is_action_pressed("run") or Input.is_action_pressed("attack") :
		enabled_climbing = false
		if Input.is_action_pressed("forward") and enabled_climbing and not is_on_floor():
			vertical_velocity = Vector3.UP * climb_speed
			is_climbing = true
		else:
			is_climbing = false

	if ray_cast:
		if Input.is_action_pressed("forward") and enabled_climbing:
			vertical_velocity = Vector3.UP * climb_speed
			is_climbing = true
		else:
			is_climbing = false

	# State control for jumping/falling/landing
	var on_floor = is_on_floor()
	var h_rot = $Camroot/Camera_holder.global_transform.basis.get_euler().y
	movement_speed = 0
	angular_acceleration = 10
	acceleration = 15

	# Gravity and stop sliding on floors
	if not is_on_floor():
		vertical_velocity += Vector3.DOWN * gravity * 2 * delta
	else:
		vertical_velocity = -get_floor_normal() * gravity / 2.5

	# Jump and slide
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_velocity = Vector3.UP * jump_force

	if Input.is_action_just_pressed("slide") and is_on_floor() and energy >= 2.5 and is_walking:  # Check if energy is above or equal to 2.5
		energy -= 2.5
		horizontal_velocity = direction * 12

	# Teleportation
	# Teleportation
	if Input.is_action_just_pressed("blink") and energy >= 5:
		energy -= 5
		var teleport_vector = direction.normalized() * teleport_distance
		var teleport_position = translation + teleport_vector
		var collision = move_and_collide(teleport_vector)
		if collision:
			teleport_position = collision.position
			translation = teleport_position


	# Movement and strafe
	if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
					0,
					Input.get_action_strength("forward") - Input.get_action_strength("backward"))
		direction = direction.rotated(Vector3.UP, h_rot).normalized()
		is_walking = true

		# Movement States
		if Input.is_action_pressed("run") and is_walking and not is_climbing:
			movement_speed = run_speed
			is_running = true
			enabled_climbing = false
		elif Input.is_action_pressed("sprint") and is_walking and not is_climbing:
			movement_speed = run_speed * 2
			is_sprinting = true
			enabled_climbing = false
		else:  # Walk State and speed
			movement_speed = walk_speed
			is_running = false
			is_sprinting = false
			enabled_climbing = true
	else:
		is_walking = false
		is_running = false
		is_sprinting = false

	# Strafe and normal movement
	if Input.is_action_pressed("aim") and not is_running and not is_sprinting:  # Aim/Strafe input and mechanics
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/Camera_holder.rotation.y, delta * angular_acceleration)
	else:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)

#Dodge forward
	if dash_count > 0:
		dash_timer += delta
	if dash_timer >= double_press_time:
		dash_count = 0
		dash_timer = 0.0
	if Input.is_action_just_pressed("forward"):
		dash_count += 1
	if dash_count == 2 and dash_timer < double_press_time:
		horizontal_velocity = direction * dash_power * 3
		setStateSlide()
		dodge = true 
	else:
		dodge = false	
#Dodge back
	if dash_count2 > 0:
		dash_timer2 += delta
	if dash_timer2 >= double_press_time:
		dash_count2 = 0
		dash_timer2 = 0.0	
	if Input.is_action_just_pressed("backward"):
		dash_count2 += 1
	if dash_count2 == 2 and dash_timer2 < double_press_time:
		horizontal_velocity = direction * dash_power * 3
		setStateSlide()
		dodge = true 
	else:
		dodge = false		
#Dodge left		
	if dash_count3 > 0:
		dash_timer3 += delta
	if dash_timer3 >= double_press_time:
		dash_count3 = 0
		dash_timer3 = 0.0	
	if Input.is_action_just_pressed("left"):
		dash_count3 += 1
	if dash_count3 == 2 and dash_timer3 < double_press_time:
		horizontal_velocity = direction * dash_power * 3
		setStateSlide()
		dodge = true 
	else:
		dodge = false			
#Dodge right	
	if dash_count4 > 0:
		dash_timer4 += delta
	if dash_timer4 >= double_press_time:
		dash_count4 = 0
		dash_timer4 = 0.0	
	if Input.is_action_just_pressed("right"):
		dash_count4 += 1
	if dash_count4 == 2 and dash_timer4 < double_press_time:
		horizontal_velocity = direction * dash_power * 3
		setStateSlide()
	# Attacking while moving
	elif Input.is_action_pressed("attack") && (Input.is_action_pressed("slide")):
		horizontal_velocity = direction * 12
	elif Input.is_action_pressed("attack") and is_on_floor() and not mousemode and not dodge:
		horizontal_velocity = direction * 1.25	
	else:
		horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)
	if Input.is_action_pressed("guard") and is_on_floor() and not mousemode :
		blocking = true

	else: 
		blocking = false	
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)

	# Animation order

	if Input.is_action_pressed("slide") and (Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("attack")) and is_on_floor():
		setStateSlide()
	elif Input.is_action_pressed("guard") and not mousemode and not is_climbing:
		setStateGuard()
	elif Input.is_action_pressed("attack") and not mousemode and not is_climbing:
		setStateAttack()
	elif Input.is_action_pressed("sprint") and (Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		setStateSprint()
	elif is_running:
		setStateRun()
	elif Input.is_action_pressed("backward") and is_on_floor() and Input.is_action_pressed("aim"):
		setStateWalkBack()
	elif is_walking and is_on_floor():
		setStateWalk()
	else:
		setStateIdle()
func close_game():
	get_tree().quit()
	print("game over")
