extends KinematicBody
#imports
onready var criticallabel = $GUI/Character/Attributes/Acc/CriticalChance
onready var agillabel = $GUI/Character/Attributes/AGI/AGI
onready var vitalitylabel = $GUI/Character/Attributes/VIT/VIT
onready var intlabel = $GUI/Character/Attributes/INT/INT
onready var strlabel = $GUI/Character/Attributes/STR/STR
onready var acclabel = $GUI/Character/Attributes/Acc/Acc
onready var attributelabel = $GUI/Character/Attributes/AttributePoints
onready var head = $Camroot
onready var head_pos = head.transform
onready var campivot = $Camroot/Camera_holder
onready var camera = $Camroot/Camera_holder/Camera
onready var hitbox = $Hitbox
onready var animation = $Evi/AnimationPlayer
onready var weapon = $Evi/Armature/Skeleton/sword
onready var hook = $Camroot/Camera_holder/Camera/Hook
onready var collision_torso = $CollisonTorso
export var grapple_point : NodePath 
var velocity := Vector3()
# Allows to pick your character's mesh from the inspector
export (NodePath) var PlayerCharacterMesh
export onready var player_mesh = get_node(PlayerCharacterMesh)
# movement variables
export var gravity = 9.8
export var jump_force = 7
export var walk_speed = 4
export var run_speed = 7.7
const basesprint = 15
export var sprint_speed = 15
export var teleport_distance = 35
const basedash = 25
export var dash_power = 25
export var dodge_power = 12
export (float) var mouse_sense = 0.1
#climbing 
const base_climb_speed = 4
var climb_speed = 4
# Dodge
export var double_press_time: float = 0.4
var dash_count2: int = 0
var dash_timer2: float = 0.0
var dash_count3: int = 0
var dash_timer3: float = 0.0
var dash_count4: int = 0
var dash_timer4: float = 0.0
# Condition States
var enabled_climbing = true
var is_falling = bool()
var is_swimming =bool()
var is_rolling = bool()
var is_walking = bool()
var is_running = bool()
var is_sprinting = bool()
var is_aiming = bool()
var is_crouching = bool()
var mousemode = bool()
var staggered = false
var blocking = false
var dodge = bool()
# Mobile 
var runToggle := false
var sprintToggle := false
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
export var initial_maxhealth = 10
const basemaxhealth = 10
export var maxhealth = 10.0
export var health = 10.0
const basemaxenergy = 25
export var maxenergy = 25
export var energy = 25
export var defense = 0
const basedamage = 2
export var damage = 2
export var criticalDefenseChance = 0.60
export var criticalDefenseMultiplier = 2
export var criticalChance = 0.01
const criticalChancebase = 0.01
export var criticalMultiplier = 2
#player attributes 
var attribute = 100
var vitality = 1.0
var strength = 1.0
var intelligence = 1.0
var accuracy = 1.0
var agility = 1.0
#Energy regeneration 
var regenerationRate = 0.5  # 1 point every 2 seconds
var regenerateEnergy = true
var regenerationTimer = 0
var floatingtext = preload("res://UI/floatingtext.tscn")





func _ready(): 
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/Camera_holder.global_transform.basis.get_euler().y)

#Damage 
func attack():
	var enemies = hitbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.has_method("onhit"):
			if randf() <= criticalChance:
				var criticalDamage = damage * criticalMultiplier
				enemy.onhit(criticalDamage)
			else: 	
				enemy.onhit(damage)
		if energy < maxenergy: 
			energy += 0.5	
			
#Getting damaged
func onhitP(damage):
	if not blocking: 
	# Apply critical defense chance
		if randf() <= criticalDefenseChance:
			damage = damage / criticalDefenseMultiplier
			health -= (damage - defense)
			staggered = true
			#var text = floatingtext.instance()
			 #text.amount = float(damage)
			#add_child(text)
	else:
		staggered = false	
#Getting knocked back
func onhitKnockback(impact):
	# Calculate the angle between the player's forward direction and the camera's forward direction
	var angle_to_camera = direction.angle_to(Vector3.FORWARD)
	
	# Check if the player is facing the camera
	if angle_to_camera < 0.5:
		horizontal_velocity = direction.normalized() * impact
	# Check if the player is showing their back to the camera
	elif angle_to_camera > 0.51:
		horizontal_velocity = -direction.normalized() * impact
	else:
		pass
		#horizontal_velocity = -direction.normalized() * impact

func _input(event):  # All major mouse and button input events
	# Get mouse input for camera rotation
	if event is InputEventMouseMotion and (mousemode == false):
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(+event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-60), deg2rad(90))
#Dodging by sliding on the floor, also modifies the collision shapes to slide below bostacles
func dodge(delta):		
	#Dodge back and front
	if dash_count2 > 0:
		dash_timer2 += delta
	if dash_timer2 >= double_press_time:
		dash_count2 = 0
		dash_timer2 = 0.0	
	if Input.is_action_just_pressed("backward") or Input.is_action_just_pressed("forward"):
		dash_count2 += 1
	if dash_count2 == 2 and dash_timer2 < double_press_time and energy >= 1.25:
		horizontal_velocity = direction * dash_power  
		energy -= 0.125 * delta
		animation.play("slide",0.1)
		dodge = true 
		collision_torso.disabled = true
		enabled_climbing = false
	else:
		dodge = false
		collision_torso.disabled = false
#Dodge right	
	if dash_count4 > 0:
		dash_timer4 += delta
	if dash_timer4 >= double_press_time:
		dash_count4 = 0
		dash_timer4 = 0.0	
	if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("left") :
		dash_count4 += 1
	if dash_count4 == 2 and dash_timer4 < double_press_time and energy >= 1.25:
		horizontal_velocity = direction * dash_power 
		energy -= 0.125 * delta
		animation.play("slide",0.1)
		collision_torso.disabled = true
		enabled_climbing = false
	else:
		dodge = false
		collision_torso.disabled = false
		enabled_climbing = true

		
func _physics_process(delta: float):	
	
	dodge(delta /  2)
# Update attribute and stats 
	climb_speed = base_climb_speed * strength
	dash_power = basedash * agility 
	sprint_speed = basesprint * agility
	criticalChance = criticalChancebase * accuracy * 10
	damage = basedamage * strength
	maxhealth = basemaxhealth * vitality
	maxenergy = basemaxenergy * intelligence
	
	criticallabel.text =  "%.3f" % criticalChance
	agillabel.text = "%.3f" % agility
	acclabel.text = "%.3f" % accuracy
	intlabel.text = "%.3f" % intelligence
	strlabel.text = "%.3f" % strength
	vitalitylabel.text = "%.3f" % vitality
	attributelabel.text = "Attribute Points: " + str(attribute)
	
	
# Raycast to detect obstacles in front of the character
	var ray_length = 1  # Adjust this value based on the desired length of the ray
	var ray_direction = direction.normalized()  # Use the same direction as the character's movement
	var ray_start = translation + Vector3(0, 0.15, 0)  # Adjust the starting position of the ray based on your character's position
	var ray_end = ray_start + ray_direction * ray_length
	var is_climbing = false
	var ray_cast = get_world().direct_space_state.intersect_ray(ray_start, ray_end, [self])

	if Input.is_action_pressed("sprint") or Input.is_action_pressed("run") or Input.is_action_pressed("attack") or dodge :
		enabled_climbing = false

		if  enabled_climbing:
			vertical_velocity = Vector3.UP * climb_speed
			is_climbing = true
		else:
			is_climbing = false

	if is_on_wall() or is_on_floor() or is_on_ceiling() or ray_cast:
		if  Input.is_action_pressed("jump") and enabled_climbing:
			if strength >= 1:
				vertical_velocity = Vector3.UP * climb_speed 
				horizontal_velocity = direction * climb_speed
				is_climbing = true
				is_swimming = false
			else: 
				is_climbing = false	
	else:
			is_climbing = false

# State control for jumping/falling/landing
	var on_floor = is_on_floor()
	var h_rot = $Camroot/Camera_holder.global_transform.basis.get_euler().y
	movement_speed = 0
	angular_acceleration = 10
	acceleration = 15

# Gravity and stop sliding on floors
	if not is_on_floor() and not is_swimming:
		vertical_velocity += Vector3.DOWN * gravity * 2 * delta
		is_falling = true
		is_swimming = false
	else:
		vertical_velocity = -get_floor_normal() * gravity / 2.5
		is_falling = false

# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_velocity = Vector3.UP * jump_force
	if Input.is_action_pressed("jump") and is_swimming:
		vertical_velocity = Vector3.UP * 15 * delta
# Teleportation
	if Input.is_action_just_pressed("blink") and energy >= 5:
		energy -= 5
		var teleport_vector = direction.normalized() * teleport_distance
		var teleport_position = translation + teleport_vector
		var collision = move_and_collide(teleport_vector)
		if collision:
			teleport_position = collision.position
			translation = teleport_position
			
	if (Input.is_action_just_pressed("RunOFFON")):
		runToggle = !runToggle				
	if (Input.is_action_just_pressed("SprintOFFON")):
		sprintToggle = !sprintToggle
# Movement and strafe
	if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
					0,
					Input.get_action_strength("forward") - Input.get_action_strength("backward"))
		direction = direction.rotated(Vector3.UP, h_rot).normalized()
		is_walking = true
		
		

		# Movement States
		if Input.is_action_pressed("run") and is_walking and not is_climbing and not blocking and not is_swimming:
			movement_speed = run_speed
			is_running = true
			enabled_climbing = false
		#Mobile
		elif runToggle and not is_climbing and not blocking and not is_swimming:
			movement_speed = run_speed
			is_running = true
			enabled_climbing = false	
		#Computer	
		elif Input.is_action_pressed("sprint") and is_walking and not is_climbing and not blocking and not is_swimming:
			movement_speed = sprint_speed
			is_sprinting = true
			enabled_climbing = false	
		#Mobile	
		elif sprintToggle  and not is_climbing and not blocking:
			movement_speed = sprint_speed
			is_sprinting = true
			enabled_climbing = false	
			
		else:  # Walk State and speed
			movement_speed = walk_speed
			is_running = false
			is_sprinting = false
			is_crouching = false
			enabled_climbing = true
	else:
		is_walking = false
		is_running = false
		is_sprinting = false
		is_crouching = false
#mobile controls 		



	# Strafe and normal movement
	if Input.is_action_pressed("aim") and not is_running and not is_sprinting:  # Aim/Strafe input and mechanics
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/Camera_holder.rotation.y, delta * angular_acceleration)
	else:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)


	# Attacking while moving
	if Input.is_action_pressed("attack") && (Input.is_action_pressed("slide")) and not is_swimming:
		horizontal_velocity = direction * 12
	elif Input.is_action_pressed("attack") and dash_count2 == 0 and is_on_floor() and not mousemode and not dodge and not is_swimming:
		horizontal_velocity = direction * 0.70
	else:
		horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)
	# Attacking while moving
	if Input.is_action_pressed("slash") && (Input.is_action_pressed("slide")) and not is_swimming:
		horizontal_velocity = direction * 12
	elif Input.is_action_pressed("slash") and dash_count2 == 0 and is_on_floor() and not mousemode and not dodge and not is_swimming:
		horizontal_velocity = direction * 0.50
	else:
		horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)


	if Input.is_action_pressed("guard") and is_on_floor() and not mousemode and energy >= 0.125:
		energy -= 0.125
		blocking = true
	else: 
		blocking = false	
		
	if Input.is_action_pressed("crouch") and is_swimming:
		vertical_velocity += Vector3.DOWN * 15 * delta
	else: 
		pass	
	if 	Input.is_action_pressed("crouch") and not is_swimming:
		collision_torso.disabled = true
	else: 
		collision_torso.disabled = false	
		
		 
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)

	# Animation order
	if dodge and not is_swimming:
		animation.play("slide")
		weapon.visible = false

	if Input.is_action_pressed("guard") and not is_swimming and not mousemode and not is_climbing and energy >= 0.125:
		animation.play("guard", 0.1)
		weapon.visible = true
	elif is_falling and not is_climbing:
		animation.play("Rest Pose",0.15)
	elif Input.is_action_pressed("slash") and dash_count2 == 0 and not mousemode and not is_climbing and not dodge and not is_swimming:
		animation.play("slash", 0.25, 0.5 + agility * 0.50)
		weapon.visible = true	
	elif Input.is_action_pressed("reverse_slash") and dash_count2 == 0 and not mousemode and not is_climbing and not dodge and not is_swimming:
		animation.play("reverse slash", 0.25, 0.5 + agility * 0.50)
		weapon.visible = true			
	elif Input.is_action_pressed("attack") and dash_count2 == 0 and not mousemode and not is_climbing and not dodge and not is_swimming:
		animation.play("base attack", 0.1, 0.5 + agility * 0.50)
		weapon.visible = true
	elif Input.is_action_pressed("backward") and is_on_floor() and Input.is_action_pressed("aim") and not is_swimming:
		animation.play_backwards("walk")
		
	elif is_climbing and is_on_wall() and not is_swimming:
		animation.play("climb")	
		weapon.visible = false
	
	elif is_sprinting and not dodge and not is_swimming:
		animation.play("sprint", 0, agility * 0.95)
		weapon.visible = false
	
	elif is_running and not is_swimming:
		animation.play("run", 0, agility * 0.89)
		weapon.visible = false

	elif is_walking and is_on_floor() and not is_swimming:
		animation.play("walk", 0.25)
		weapon.visible = false

	elif is_swimming and Input.is_action_pressed("backward") or Input.is_action_pressed("forward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		animation.play("swim", 0.35)
	elif is_swimming: 
		animation.play("float", 0.35)	
		weapon.visible = false

	else:
		animation.play("idle", 0.2)
		weapon.visible = false

		
	# Energy rengeneration	
	if regenerateEnergy and energy < maxenergy:
		regenerationTimer += delta
		if regenerationTimer >= 2.0:  # Regenerate every 2 seconds
			regenerationTimer = 0
			energy += 1
			if energy >= maxenergy:
				energy = maxenergy
				regenerateEnergy = false	
	# Update energy bar
	$GUI/EnergyBar.value = int((energy / maxenergy) * 100)
	# Update health bar
	$GUI/HealthBar.value = int((health / maxhealth) * 100)

	# Update the UI or display a message to indicate the attribute increase
	var healthText = "Health: %.2f / %.2f" % [health, maxhealth]
	var energyText = "Energy: %.2f / %.2f" % [energy, maxenergy]

	$GUI/H.text = healthText
	$GUI/E.text = energyText	
	
		
	# Toggle mouse mode
	if Input.is_action_just_pressed("ESC"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mousemode = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mousemode = false

#saving data
func get_save_stats():
	return {
		'filename': get_filename(),
		'parent': get_parent().get_path(),
		'x_pos': global_transform.origin.x,
		'y_pos': global_transform.origin.y,
		'z_pos': global_transform.origin.z,
		'stats': {
			'health': health,
			'vitality': vitality,
			'strength': strength,
			'intelligence' : intelligence,
			'basemaxhealth': basemaxhealth,
			'accuracy': accuracy,
			'energy': energy,
			'maxhealth': maxhealth,
			'maxenergy': maxenergy,
			'attribute': attribute,
			'agility': agility
		}
	}

func load_save_stats(stats):
	global_transform.origin = Vector3(stats.x_pos, stats.y_pos, stats.z_pos)
	health = stats.stats.health
	energy = stats.stats.energy
	vitality = stats.stats.vitality
	maxhealth = stats.stats.maxhealth
	maxenergy = stats.stats.maxenergy
	strength = stats.stats.strength
	intelligence = stats.stats.intelligence
	attribute = stats.stats.attribute
	accuracy = stats.stats.accuracy
	agility = stats.stats.agility

#increasing / decreasing stats and attributes based on buttons
func _on_PlusVIT_pressed():
	if attribute > 0:
		attribute -= 1
		vitality += 0.025
func _on_MinusVIT_pressed():
	if vitality > 0.076:
		attribute += 1
		vitality -= 0.025
		health = maxhealth


func _on_PlusSTR_pressed():
	if attribute > 0:
		attribute -= 1
		strength += 0.025
func _on_MinusSTR_pressed():
	if strength > 0.076:
		attribute += 1
		strength -= 0.025

		
func _on_PlusINT_pressed():
	if attribute > 0:
		attribute -= 1
		intelligence += 0.025	
func _on_MinusINT_pressed():
	if intelligence > 0.076:
		attribute += 1
		intelligence -= 0.025
		energy = maxenergy

func _on_PlusACC_pressed():
	if attribute > 0:
		attribute -= 1
		accuracy += 0.025
func _on_MinusACC_pressed():
	if accuracy > 0.01:
		attribute += 1
		accuracy -= 0.025

func _on_PlusAGI_pressed():
	if attribute > 0:
		attribute -= 1
		agility += 0.025
func _on_MinusAGI_pressed():
	if agility > 0.11:
		attribute += 1
		agility -= 0.025


func _on_WaterDetector_area_entered(area):
	if area.is_in_group("Water"):
		is_swimming = true

func _on_WaterDetector_area_exited(area):
	if area.is_in_group("Water"):
		is_swimming = false

