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
onready var animation = $Girlz/AnimationPlayer
onready var hook = $Camroot/Camera_holder/Camera/Hook
onready var collision_torso = $CollisonTorso
onready var hitbox = $Hitbox
var velocity := Vector3()
# Allows to pick your character's mesh from the inspector
export (NodePath) var PlayerCharacterMesh
export onready var player_mesh = get_node(PlayerCharacterMesh)
# movement variables
export var gravity = 9.8
export var jump_force = 7
export var crouch_speed = 2.75
export var walk_speed = 3
export var run_speed = 6
const basesprint = 9
export var sprint_speed = 9
export var teleport_distance = 35
const basedash = 25
export var dash_power = 100
export var dodge_power = 12
export (float) var mouse_sense = 0.1
#climbing 
const base_climb_speed = 4
var climb_speed = 4
# Dodge
export var double_press_time: float = 0.4
var dash_countback: int = 0
var dash_timerback: float = 0.0
# Dodge Left
var dash_countleft: int = 0
var dash_timerleft: float = 0.0
# Dodge right 
var dash_countright: int = 0
var dash_timerright: float = 0.0
# Dodge forward
var dash_countforward: int = 0
var dash_timerforward: float = 0.0
# Dodge multidirection (not in strafe mode)
var dash_count1 : int = 0
var dash_timer1 : float = 0.0
var dash_count2 : int = 0
var dash_timer2 : float = 0.0
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
var is_attacking = bool()
var is_guarding = false
var is_climbing = false
var speaking = false
var mousemode = bool()
var staggered = false
var blocking = false
var backstep = bool()
var frontstep = bool()
var leftstep = bool()
var rightstep =bool()
var dodge = bool()
var tackle = bool()
var can_tackle = true
#combat stance 
var is_in_combat = false
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
export var defense = 0.95 #the lower, the higher the defense, 0 is 100% protection
export var barehanded_block = 0.9 #the lower, the higher the defense, 0 is 100% protection
const basedamage = 1
export var damage = 1
export var criticalDefenseChance = 0.50
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
var impact = 80
#Energy regeneration 
var regenerationRate = 0.5  # 1 point every 2 seconds
var regenerateEnergy = true
var regenerationTimer = 0
var floatingtext = preload("res://UI/floatingtext.tscn")


func _ready(): 
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/Camera_holder.global_transform.basis.get_euler().y)
func movement(delta):
	var h_rot = $Camroot/Camera_holder.global_transform.basis.get_euler().y
	movement_speed = 0
	angular_acceleration = 10
	acceleration = 15

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
		speaking = false

		# Movement States
		if Input.is_action_pressed("run") and is_walking and not is_climbing and not blocking and not is_swimming and energy >= 0:
			movement_speed = run_speed
			is_running = true
			enabled_climbing = false
			is_crouching = false
			is_in_combat = false
		elif Input.is_action_pressed("crouch") and is_walking and not is_climbing and not blocking and not is_swimming:
			movement_speed = crouch_speed
			is_running = false
			enabled_climbing = false
			is_crouching = true
			is_in_combat = false
		#Mobile
		elif runToggle and not is_climbing and not blocking and not is_swimming and energy >= 0:
			movement_speed = run_speed
			is_running = true
			is_sprinting = false
			enabled_climbing = false
			is_in_combat = false	
		#Computer	
		elif Input.is_action_pressed("sprint") and is_walking and not is_climbing and not blocking and not is_swimming and energy >= 0:
				movement_speed = sprint_speed
				is_sprinting = true
				enabled_climbing = false
				is_crouching = false	
				is_in_combat = false
		#Mobile	
		elif sprintToggle  and not is_climbing and not blocking and energy >= 0:
			movement_speed = sprint_speed
			is_sprinting = true
			is_running= false
			enabled_climbing = false	
			is_in_combat = false
			
		else:  # Walk State and speed
			movement_speed = walk_speed
			is_sprinting = false
			is_crouching = false
			enabled_climbing = true
			is_crouching = false
	else:
		is_walking = false
		is_running = false
		is_sprinting = false
		is_crouching = false
		is_crouching = false
		
	# Strafe and normal movement
	if Input.is_action_pressed("aim") and not is_running and not is_sprinting:  # Aim/Strafe input and mechanics
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/Camera_holder.rotation.y, delta * angular_acceleration)
		is_aiming = true
	else:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)
		is_aiming = false

	if Input.is_action_pressed("crouch") and is_swimming:
		vertical_velocity += Vector3.DOWN * 15 * delta
		collision_torso.disabled = true
	else: 
		collision_torso.disabled = false
	if 	Input.is_action_pressed("crouch") and not is_swimming:
		collision_torso.disabled = true
	else: 
		collision_torso.disabled = false	

	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)
func gravityAndJumping(delta):
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
func dealDamage():
	var enemies = hitbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("Enemy"):
			if randf() <= criticalChance:
				var criticalDamage = damage * criticalMultiplier
				enemy.takeDamage(criticalDamage)
			else: 	
				enemy.takeDamage(damage)
		if energy < maxenergy: 
			energy += 0.5
func takeDamage(damage):#Getting damaged
	is_in_combat = true
	if is_guarding: 
		health -= ((damage * barehanded_block) * defense)
		staggered = true
		var text = floatingtext.instance()
		text.amount = float(damage * barehanded_block)
		add_child(text)
			
	else:
		health -= (damage * defense)
		staggered = true
		var text = floatingtext.instance()
		text.amount = float(damage * defense)
		add_child(text)
func combatStanceBarehanded():#barehanded combat stace
	if  Input.is_action_just_pressed("Combat"):
		is_in_combat = !is_in_combat			
func comboPunch():#Barehanded base attack
	if is_in_combat:
		if Input.is_action_pressed("attack"):
			horizontal_velocity = direction * walk_speed/1.5
			is_attacking = true 
		else:
			is_attacking = false	
func guardingStance():#Barehanded base attack
	if is_in_combat:
		if Input.is_action_pressed("guard"):
			is_guarding = true
		else:
			is_guarding = false
func getKnockedBack(impact):#Getting knocked back
	#Calculate the angle between the player's forward direction and the camera's forward direction
	var angle_to_camera = direction.angle_to(Vector3.FORWARD)
	#Check if the player is facing the camera
	if angle_to_camera < 0.5:
		horizontal_velocity = direction.normalized() * impact
	#Check if the player is showing their back to the camera
	elif angle_to_camera > 0.51:
		horizontal_velocity = -direction.normalized() * impact
	else:
		pass
		#Horizontal_velocity = -direction.normalized() * impact
func knockback(): 
	var enemies = hitbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("Player"):
			enemy.onhitKnockback(impact)		
func _input(event):#All major mouse and button input events
	#Get mouse input for camera rotation
	if event is InputEventMouseMotion and (mousemode == false):
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(+event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-60), deg2rad(90))
func dodgeBack(delta):#Doddge when in strafe mode
	if is_aiming:
		if dash_countback > 0:
			dash_timerback += delta
		if dash_timerback >= double_press_time:
			dash_countback = 0
			dash_timerback = 0.0	
		if Input.is_action_just_pressed("backward"):
			dash_countback += 1
		if dash_countback == 2 and dash_timerback < double_press_time and energy >= 1.25:
			horizontal_velocity = direction * dash_power  
			energy -= 0.125 * delta
			backstep = true 
			collision_torso.disabled = true
			enabled_climbing = false
		else:
			collision_torso.disabled = false
			enabled_climbing = true
			backstep = false
	else:
			collision_torso.disabled = false
			enabled_climbing = true
			backstep = false
func dodgeFront(delta):#Dodge when in strafe mode
	if is_aiming:
		if dash_countforward > 0:
			dash_timerforward += delta
		if dash_timerforward >= double_press_time:
			dash_countforward = 0
			dash_timerforward = 0.0	
		if Input.is_action_just_pressed("forward"):
			dash_countforward += 1
		if dash_countforward == 2 and dash_timerforward < double_press_time and energy >= 1.25:
			horizontal_velocity = direction * dash_power *1.55
			energy -= 0.125 * delta
			frontstep = true 
			collision_torso.disabled = true
			enabled_climbing = false
		else:
			collision_torso.disabled = false
			enabled_climbing = true
			frontstep = false
	else:
			collision_torso.disabled = false
			enabled_climbing = true
			frontstep = false
func dodgeLeft(delta):#Dodge when in strafe mode
	if is_aiming: 
		if dash_countleft > 0:
			dash_timerleft += delta
		if dash_timerleft >= double_press_time:
			dash_countleft = 0
			dash_timerleft = 0.0	
		if Input.is_action_just_pressed("left"):
			dash_countleft += 1
		if dash_countleft == 2 and dash_timerleft < double_press_time and energy >= 1.25:
			horizontal_velocity = direction * dash_power 
			energy -= 0.125 * delta
			collision_torso.disabled = true
			enabled_climbing = false
			leftstep = true
		else:
			collision_torso.disabled = false
			enabled_climbing = true
			leftstep = false
	else:
			collision_torso.disabled = false
			enabled_climbing = true
			leftstep = false
func dodgeRight(delta):#Dodge when in strafe mode
	if is_aiming:	
		if dash_countright > 0:
			dash_timerright += delta
		if dash_timerright >= double_press_time:
			dash_countright = 0
			dash_timerright = 0.0	
		if Input.is_action_just_pressed("right"):
			dash_countright += 1
		if dash_countright == 2 and dash_timerright < double_press_time and energy >= 1.25:
			horizontal_velocity = direction * dash_power 
			energy -= 0.125 * delta
			collision_torso.disabled = true
			enabled_climbing = false
			rightstep = true
		else:
			collision_torso.disabled = false
			enabled_climbing = true
			rightstep = false
	else:
			collision_torso.disabled = false
			enabled_climbing = true
			rightstep = false
func slide(delta):#Slide to dodge 
	if not is_aiming:
		if dash_count1 > 0:
			dash_timer1 += delta
		if dash_timer1 >= double_press_time:
			dash_count1 = 0
			dash_timer1 = 0.0	
		if Input.is_action_just_pressed("backward") or Input.is_action_just_pressed("forward"):
			dash_count1 += 1
		if dash_count1 == 2 and dash_timer2 < double_press_time and energy >= 1.25:
			horizontal_velocity = direction * dash_power  
			energy -= 0.125 * delta
			dodge = true 
			collision_torso.disabled = true
			enabled_climbing = false
		else:
			dodge = false
			collision_torso.disabled = false

		if dash_count2 > 0:
			dash_timer2 += delta
		if dash_timer2 >= double_press_time:
			dash_count2 = 0
			dash_timer2 = 0.0	
		if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("left") :
			dash_count2 += 1
		if dash_count2 == 2 and dash_timer2 < double_press_time and energy >= 1.25:
			horizontal_velocity = direction * dash_power 
			energy -= 0.125 * delta
			collision_torso.disabled = true
			enabled_climbing = false
		else:
			dodge = false
			collision_torso.disabled = false
			enabled_climbing = true
func tackle(delta):#Jump and tackle, works as a dodge and as an attack
	if Input.is_action_pressed("tackle") and energy >= 0:
		horizontal_velocity = direction * dash_power / 5
		energy -= 0.5 * delta
		tackle = true
	else:
		tackle = false	
func teleport():
	if Input.is_action_just_pressed("blink") and energy >= 5:
		energy -= 5
		var teleport_vector = direction.normalized() * teleport_distance
		var teleport_position = translation + teleport_vector
		var collision = move_and_collide(teleport_vector)
		if collision:
			teleport_position = collision.position
			translation = teleport_position	
func climbing(delta):
	var ray_length = 1  # Adjust this value based on the desired length of the ray
	var ray_direction = direction.normalized()  # Use the same direction as the character's movement
	var ray_start = translation + Vector3(0, 0.15, 0)  # Adjust the starting position of the ray based on your character's position
	var ray_end = ray_start + ray_direction * ray_length
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
func speak():
	if !is_in_combat or !is_walking:
		if  Input.is_action_just_pressed("attack"):
			speaking = !speaking	
		if 	Input.is_action_just_pressed("guard"):
			speaking = false
func consumeEnergy(delta):
	if is_sprinting:
		energy -= 0.005
	if is_running:
		energy -= 0.001	
func regeneration(delta):
	# Energy rengeneration	
	if energy < maxenergy:
		regenerationTimer += delta
		if is_walking or is_sprinting or is_climbing or is_running or is_sprinting:	
			if regenerationTimer >= 0.2: 
				regenerationTimer = 0
				energy += 0.001
				if energy >= maxenergy:
					energy = maxenergy
					regenerateEnergy = false	
		else:		
			if regenerationTimer >= 0.2: 
				regenerationTimer = 0
				energy += 0.0025
				if energy >= maxenergy:
					energy = maxenergy
					regenerateEnergy = false	
func mouseMode():	
	# Toggle mouse mode
	if Input.is_action_just_pressed("ESC"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mousemode = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mousemode = false
func updateattributes():
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
func updateinternface():
	# Update energy bar
	$GUI/EnergyBar.value = int((energy / maxenergy) * 100)
	# Update health bar
	$GUI/HealthBar.value = int((health / maxhealth) * 100)
	# Update the UI or display a message to indicate the attribute increase
	var healthText = "Health: %.2f / %.2f" % [health, maxhealth]
	var energyText = "Energy: %.2f / %.2f" % [energy, maxenergy]
	$GUI/H.text = healthText
	$GUI/E.text = energyText	
	$GUI/FPS.text = "FPS: %d" % Engine.get_frames_per_second()
func _physics_process(delta: float):#this calls every function 	
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)
	movement(delta)
	gravityAndJumping(delta)
	comboPunch()
	guardingStance()
	tackle(delta/1.5)
	dodgeRight(delta/1.5)
	dodgeBack(delta/1.5)
	dodgeFront(delta/1.5)
	dodgeLeft(delta/1.5)
	slide(delta/1.5)
	animationOrder()
	updateattributes()
	updateinternface()
	mouseMode()
	teleport()
	climbing(delta)
	consumeEnergy(delta)
	regeneration(delta)
	combatStanceBarehanded()
	speak()
func animationOrder():#I'm human, not a robot I understand words not nodes
	if dash_count1 ==2 or dash_count2 ==2:
		animation.play("slide")
	if not is_in_combat:
		if is_sprinting and not dodge and not is_swimming:
			animation.play("sprint")
		elif is_walking and is_on_floor() and !is_aiming:
			animation.play("walk",0.2)		
		elif tackle:
			animation.play("tackle")
		elif is_aiming and Input.is_action_pressed("left") and Input.is_action_pressed("backward"):
			animation.play_backwards("strafe right front", 0.25)		
		elif is_aiming and Input.is_action_pressed("right") and Input.is_action_pressed("backward"):
			animation.play_backwards("strafe left front", 0.25)	
		elif Input.is_action_pressed("backward") and is_on_floor() and is_aiming and !is_swimming :
			animation.play_backwards("walk")
		elif Input.is_action_pressed("forward") and is_on_floor() and is_aiming and !is_swimming :
			animation.play("walk")				
		elif is_aiming and Input.is_action_pressed("right") and Input.is_action_pressed("forward") :
			animation.play("strafe right front", 0.25)
		elif is_aiming  and Input.is_action_pressed("left") and Input.is_action_pressed("forward") :
			animation.play("strafe left front", 0.25)	
		elif is_aiming  and Input.is_action_pressed("left"):
			animation.play("strafe left", 0.25)
		elif is_aiming  and Input.is_action_pressed("right"):
			animation.play("strafe right", 0.25)					
		elif backstep:
			animation.play("backstep",0.25)
		elif leftstep:
			animation.play("leftstep",0.25)	
		elif rightstep:
			animation.play_backwards("leftstep",0.25)	
		elif frontstep:
			animation.play("frontstep",0.2)	
		elif speaking:
			animation.play("speak")	
		elif Input.is_action_pressed("guard"):
			animation.play("wave")
		else:
			animation.play("idle", 0.25)

	if is_in_combat and !is_aiming:
		if dash_count2 == 2 or dash_count1 == 2: 
			animation.play("slide")				
		elif is_attacking:
			animation.play("combo punch",0.25)
		elif is_guarding and is_walking:
			animation.play_backwards("barehanded guard walk",0.3)			
		elif is_guarding:
			animation.play("guard",0.1)			
		elif is_walking:
			animation.play_backwards("combat walk", 0.25)
		elif tackle:
			animation.play("tackle",0.1)		
		else: 
			animation.play("combat idle", 0.25)
			
	if is_guarding and is_aiming:
		if  Input.is_action_pressed("forward"):
			animation.play_backwards("barehanded guard walk",0.3)
		elif  Input.is_action_pressed("backward"):
			animation.play("barehanded guard walk",0.3)
		elif Input.is_action_pressed("left"):
			animation.play_backwards("barehanded guard strafe",0.3)
		elif Input.is_action_pressed("right"):
			animation.play("barehanded guard strafe",0.3)	
		else:
			animation.play("guard",0.1)			
			
	if is_in_combat and is_aiming and !is_guarding and not Input.is_action_pressed("guard"):
		if backstep:
			animation.play("backstep",0.25)
		elif leftstep:
			animation.play("leftstep",0.25)	
		elif rightstep:
			animation.play_backwards("leftstep",0.25)	
		elif frontstep:
			animation.play("frontstep",0.2)			
		elif is_guarding:
			animation.play("guard",0.3)			
		elif is_attacking:
			animation.play("combo punch",0.25)			
		elif Input.is_action_pressed("forward"):
			animation.play_backwards("combat walk")	
		elif Input.is_action_pressed("backward"):
			animation.play("combat walk")		
		elif Input.is_action_pressed("right"):
			animation.play("combat strafe")		
		elif Input.is_action_pressed("left"):
			animation.play_backwards("combat strafe")
		else:
			animation.play("combat idle")


func get_save_stats():#saving data
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
func load_save_stats(stats):#loading saved data
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
