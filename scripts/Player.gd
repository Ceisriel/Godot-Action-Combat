extends KinematicBody
#imports
var floatingtext_damage = preload("res://UI/Spritefloatingtext.tscn")
var floatingtext_heal = preload("res://UI/Spritefloatingtextheal.tscn")
#var potion = preload("res://test2/potion.fbx")
var potion_instance = null
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
onready var animation = $FHuman/AnimationPlayer
onready var collision_torso = $CollisonTorso
onready var hitbox = $Hitbox
onready var takedamagesprite = $Takedamage/DamageView
onready var warlocktorso = $FHuman/Armature/Skeleton/TorsoSemiPlate
onready var nakedtorso = $FHuman/Armature/Skeleton/TorsoNaked

var velocity := Vector3()
# Allows to pick your character's mesh from the inspector
export (NodePath) var PlayerCharacterMesh
export onready var player_mesh = get_node(PlayerCharacterMesh)
# movement variables
export var gravity = 9.8
export var jump_force = 5
export var crouch_speed = 1
export var walk_speed = 7
export var run_speed = 9
const basesprint = 9
export var sprint_speed = 14
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
var exercise = bool()
var Usquat = bool()
var squat = bool()
var pressing = bool()
var situp = bool()
var dance1 = bool()
var dance2 = bool()
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
var inventorymode = bool()
var alive = true
var has_Rcrossbow = bool()
var has_Spear = bool()
var has_Sword = bool()
var has_Sword_Off = bool()
var has_Shield = bool()
var agilityModifierApplied0 = bool()
var agilityModifierApplied1 = bool()
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
const basemaxhealth = 100
export var maxhealth = 100.0
export var health = 100
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
#player attributes but stored, must have to update attributes with weapons and armors
var original_agility = agility  # Store the original agility value
var original_walk_speed = walk_speed  # Store the original walk speed value
#Energy regeneration
var regenerationRate = 0.5  # 1 point every 2 seconds
var regenerateEnergy = true
var regenerationTimer = 0

#Potions
var potion_ammount = 0
var is_drinking = false
var drinking_timer = 0.0
var drinking_duration = 3.0  # Duration in seconds


func _ready():

	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/Camera_holder.global_transform.basis.get_euler().y)
	$Timer.connect("timeout", self, "_on_drinking_timer_timeout")

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
			is_aiming = false
		elif Input.is_action_pressed("crouch") and is_walking and !is_climbing and !is_swimming:
			movement_speed = crouch_speed
			is_running = false
			enabled_climbing = false
			is_crouching = true
			is_in_combat = false
			is_aiming = false

		#Mobile
		elif runToggle and not is_climbing and not blocking and not is_swimming and energy >= 0:
			movement_speed = run_speed
			is_running = true
			is_sprinting = false
			enabled_climbing = false
			is_in_combat = false
			is_aiming = false
		#Computer
		elif Input.is_action_pressed("sprint") and is_walking and not is_climbing and not blocking and not is_swimming and energy >= 0:
				movement_speed = sprint_speed
				is_sprinting = true
				enabled_climbing = false
				is_crouching = false
				is_in_combat = false
				is_aiming = false
		#Mobile
		elif sprintToggle  and not is_climbing and not blocking and energy >= 0:
			movement_speed = sprint_speed
			is_sprinting = true
			is_running= false
			enabled_climbing = false
			is_in_combat = false
			is_aiming = false

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
	if is_aiming and !is_running and !is_sprinting:  # Aim/Strafe input and mechanics
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/Camera_holder.rotation.y, delta * angular_acceleration)
	else:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)


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
func takeDamage(damage):
	# Getting damaged
	is_in_combat = true

	if is_guarding:
		health -= ((damage * barehanded_block) * defense)
		staggered = true
		var text = floatingtext_damage.instance()
		text.amount = round_to_two_decimals(damage * barehanded_block)
		takedamagesprite.add_child(text)

	else:
		health -= (damage * defense)
		staggered = true
		var text = floatingtext_damage.instance()
		text.amount = round_to_two_decimals(damage * defense)
		takedamagesprite.add_child(text)
func healing():
	if health < maxhealth:  # Check if healing is needed
		health += intelligence * 1.5
		var text = floatingtext_heal.instance()
		text.amount = round_to_two_decimals(intelligence * 1.5)
		takedamagesprite.add_child(text)
		if health > maxhealth:  # Check for overhealing
			health = maxhealth  # Limit health to maxhealth if overhealing occurs
			text.amount = round_to_two_decimals(intelligence * 1.5)
			takedamagesprite.add_child(text)
func combatStanceBarehanded():#barehanded combat stace
	if  Input.is_action_just_pressed("Combat"):
		is_in_combat = !is_in_combat
func comboPunch():#Barehanded base attack
	if is_in_combat:
		if Input.is_action_pressed("attack"):
			is_attacking = true
		else:
			is_attacking = false
func guardingStance():#Barehanded base attack
	if is_in_combat:
		if Input.is_action_pressed("guard"):
			is_guarding = true
		else:
			is_guarding = false
#func getKnockedBack(impact):#Getting knocked back
	#Calculate the angle between the player's forward direction and the camera's forward direction
	#var angle_to_camera = direction.angle_to(Vector3.FORWARD)
	#Check if the player is facing the camera
	#if angle_to_camera < 0.5:
	#	horizontal_velocity = direction.normalized() * impact
	#Check if the player is showing their back to the camera
	#elif angle_to_camera > 0.51:
	#	horizontal_velocity = -direction.normalized() * impact
	#else:
	#	pass
		#Horizontal_velocity = -direction.normalized() * impact
func knockback():
	var enemies = hitbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("Player"):
			enemy.onhitKnockback(impact)
func _input(event):#All major mouse and button input events
	#Get mouse input for camera rotation
	if alive:
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
	if is_on_wall() or is_on_ceiling() or ray_cast:
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
	if Input.is_action_just_pressed("aim"):
		is_aiming = !is_aiming
	# Toggle mouse mode
	if Input.is_action_just_pressed("ESC"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mousemode = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mousemode = false
	if 	Input.is_action_just_pressed("exercise"):
		if !is_in_combat:
			exercise = !exercise
	if exercise:
		if 	Input.is_action_just_pressed("guard"):
			squat = !squat
			situp = false
			pressing = false
			dance1 = false
			dance2 = false
			Usquat = false
		elif Input.is_action_just_pressed("attack"):
			pressing = !pressing
			Usquat = false
			dance1 = false
			dance2 = false
			situp = false
			squat = false
		elif Input.is_action_just_pressed("jump"):
			squat = false
			pressing = false
			dance1 = false
			dance2 = false
			Usquat = false
			situp = !situp
		elif Input.is_action_just_pressed("Q"):
			squat = false
			pressing = false
			situp = false
			dance1 = false
			dance2 = false
			Usquat = !Usquat
		elif Input.is_action_just_pressed("1"):
			squat = false
			pressing = false
			situp = false
			Usquat = false
			dance1 = !dance1
		elif Input.is_action_just_pressed("2"):
			squat = false
			pressing = false
			situp = false
			Usquat = false
			dance1 = false
			dance2 = !dance2

func round_to_two_decimals(number):
	return round(number * 100.0) / 100.0
func updateattributes():
	

		
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
	if Input.is_action_just_pressed("Q"):
		has_Rcrossbow = true
	if Input.is_action_just_pressed("reset"):
		has_Spear = true
	if Input.is_action_just_pressed("tackle"):
		has_Sword = true	
	
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)
	if !inventorymode:
		if alive:
			if !exercise:
				movement(delta)
				teleport()
				tackle(delta/1.5)
				dodgeRight(delta/1.5)
				dodgeBack(delta/1.5)
				dodgeFront(delta/1.5)
				dodgeLeft(delta/1.5)
				slide(delta/1.5)
				comboPunch()
				guardingStance()
				if !is_swimming:
					drinkPotion()
			combatStanceBarehanded()
		animations()
	updateAliveOrDead()
	updateattributes()
	updateinternface()
	mouseMode()
	climbing(delta)
	consumeEnergy(delta)
	regeneration(delta)

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
func animations():
	if alive:
		if !exercise:
			if !is_swimming:
				if is_climbing:
					if Input.is_action_pressed("jump"):
						animationOrderClimbing()
					else:
						if !is_on_floor():
							animation.play("idle")
				if !is_aiming:
					if !is_in_combat:
						animationOrderOutOfCombat()
						speak()
					elif is_in_combat:
						animatiOnorderInCombat()
					elif is_crouching:
						animationOrderCrouch()
				elif is_aiming:
					if is_in_combat:
						animationOrderCombatStrafe()
					elif !is_in_combat:
						animationOrderStrafe()
			elif is_swimming:
				animationOrderInWater()
		else:
			animationOrderExercise()
	else:
		animation.play("dead",0.85)
func animationOrderExercise():
	if squat:
		animation.play("squat",0.25,0.95)
	elif pressing:
		animation.play("push up",0.45)
	elif situp:
		animation.play("sit up",0.75)
	elif Usquat:
		animation.play("unilateral squat",0.75)
	elif dance1:
		animation.play("dance uprock",0.75)
	elif dance2:
		animation.play("dance bellydance",0.75)
	else:
		animation.play("warm up",0.25)
func animationOrderOutOfCombat(): #normal
	if dash_count1 ==2 or dash_count2 ==2:
		animation.play("slide",0.05)
#out of combat normal movement
	if !is_in_combat and !is_swimming and is_on_floor() and !is_aiming:
		if is_sprinting:
			animation.play("sprint cycle")
		elif is_running:
			animation.play("run cycle")
		elif is_walking and Input.is_action_pressed("crouch"):
			animation.play("crouch walk cycle",0.25)
		elif is_walking:
			animation.play("walk cycle",0.2)
		elif tackle:
			animation.play("tackle")
		elif speaking:
			animation.play("speak")
		elif Input.is_action_pressed("guard"):
			animation.play("wave")
		elif Input.is_action_pressed("crouch"):
			animation.play("crouch idle",0.45)
		elif is_drinking:
			animation.play("drink potion",0.25, 0.29)
		else:
			animation.play("idle", 0.25)
func animationOrderStrafe(): #strafe
	#dodge section is prioritized
		if dash_countback ==2:
			animation.play("backstep",0.25)
		elif dash_countleft ==2:
			animation.play("leftstep",0.25)
		elif dash_countright ==2:
			animation.play_backwards("leftstep",0.25)
		elif dash_countforward ==2:
			animation.play("frontstep",0.2)


		elif Input.is_action_pressed("forward") and Input.is_action_pressed("left"):
			animation.play("strafe left front",0.25)
		elif Input.is_action_pressed("backward") and Input.is_action_pressed("left"):
			animation.play_backwards("strafe right front",0.25)
		elif Input.is_action_pressed("backward") and Input.is_action_pressed("right"):
			animation.play_backwards("strafe left front",0.25)
		elif Input.is_action_pressed("forward") and Input.is_action_pressed("right"):
			animation.play("strafe right front",0.25)
		elif Input.is_action_pressed("backward"):
			animation.play_backwards("walk cycle",0.25)
		elif Input.is_action_pressed("left"):
			animation.play("strafe left",0.25)
		elif Input.is_action_pressed("right"):
			animation.play("strafe right",0.25)
		elif Input.is_action_pressed("forward"):
			animation.play("walk cycle",0.25)
	#crouching section
		elif Input.is_action_pressed("crouch"):
			if Input.is_action_pressed("forward"):
				animation.play("crouch walk cycle",0.25)
			elif Input.is_action_pressed("backward"):
				animation.play_backwards("crouch walk cycle",0.25)
			elif Input.is_action_pressed("left"):
				animation.play_backwards("crouch walk cycle",0.25)
			elif Input.is_action_pressed("right"):
				animation.play_backwards("crouch walk cycle",0.25)
			else:
				animation.play("crouch",0.25)
	#input section
		elif tackle:
			animation.play("tackle")
		elif Input.is_action_pressed("attack"):
			animation.play("speak")
		elif Input.is_action_pressed("guard"):
			animation.play("wave")
		else:
			animation.play("idle",0.25)
func animatiOnorderInCombat(): #barehanded combat stance
		if dash_count1 ==2 or dash_count2 ==2:
			animation.play("slide",0.05)
		elif is_on_floor():
			if is_guarding and is_walking and !is_aiming:
				animation.play("barehanded guard walk cycle",0.2)

			elif is_attacking and is_walking:
				animation.play("barehanded base attack walking cycle",0.2,1.42)
			elif is_guarding and !is_walking:
				animation.play("barehanded guard idle",0.3)
			elif is_attacking and !is_walking:
				animation.play("barehanded base attack still",0.2)
			elif is_walking:
				animation.play("barehanded walk cycle",0.2)
			elif tackle:
				animation.play("tackle",0.15)
			elif Input.is_action_pressed("E"):
				animation.play("kick")
			elif Input.is_action_pressed("Q"):
				animation.play("fake kick",0.15)
			elif Input.is_action_pressed("1"):
				animation.play("heal",0.75)
			elif Input.is_action_pressed("2"):
				animation.play("heal light",0.75)
			else:
				animation.play("barehanded idle",0.2)
func animationOrderCombatStrafe(): #barehanded combat stance strafe
	#dodge section is prioritized
		if dash_countback ==2:
			animation.play("backstep",0.25)
		elif dash_countleft ==2:
			animation.play("leftstep",0.25)
		elif dash_countright ==2:
			animation.play_backwards("leftstep",0.25)
		elif dash_countforward ==2:
			animation.play("frontstep",0.2)
	#everything else
		elif is_guarding and Input.is_action_pressed("forward"):
			animation.play("barehanded guard walk cycle",0.2)
		elif is_guarding and Input.is_action_pressed("backward"):
			animation.play_backwards("barehanded guard walk cycle",0.2)
		elif is_guarding and Input.is_action_pressed("left"):
			animation.play_backwards("barehanded guard strafe cycle",0.2)
		elif is_guarding and Input.is_action_pressed("right"):
			animation.play("barehanded guard strafe cycle",0.2)
		elif is_guarding:
			animation.play("barehanded guard idle",0.2)
		elif is_attacking and Input.is_action_pressed("forward"):
				animation.play("barehanded base attack walking cycle",0.2,1.42)
		elif is_attacking and Input.is_action_pressed("backward"):
			animation.play("barehanded base attack backpedal cycle",0.2,1.42)
		elif is_attacking and Input.is_action_pressed("left"):
			animation.play("barehanded base attack left cycle",0.2)
		elif is_attacking and Input.is_action_pressed("right"):
			animation.play("barehanded base attack right cycle",0.2)
		elif is_attacking:
			animation.play("barehanded base attack still",0.2)
		elif Input.is_action_pressed("forward"):
			animation.play("barehanded walk cycle",0.2)
		elif Input.is_action_pressed("backward"):
			animation.play_backwards("barehanded walk cycle",0.2)#fix the name of this
		elif Input.is_action_pressed("right"):
			animation.play("barehanded strafe",0.2)
		elif Input.is_action_pressed("left"):
			animation.play_backwards("barehanded strafe",0.2)
		elif tackle:
			animation.play("tackle",0.15)
		elif Input.is_action_pressed("E"):
			animation.play("kick",0.15)
		elif Input.is_action_pressed("Q"):
			animation.play("fake kick",0.15)
		elif Input.is_action_pressed("1"):
			animation.play("heal",0.75)
		elif Input.is_action_pressed("2"):
			animation.play("heal light",0.75)
		else:
			animation.play("barehanded idle",0.2)
func animationOrderCrouch():
	if is_walking:
		animation.play("crouch walk cycle",0.25)
	else:
		animation.play("crouch idle",0.25)
func animationOrderInWater():
	if is_walking:
		animation.play("swim cycle",0.25)
	else:
		animation.play("treading water cycle",0.25)
func animationOrderClimbing():
	if is_on_wall():
		if is_climbing:
			animation.play("climb cycle",0.2)
func updateAliveOrDead():
	if health <= 0:
		alive = false

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
func _on_LineEdit_mouse_entered():
	inventorymode = true
func _on_LineEdit_mouse_exited():
	inventorymode = false


func drinkPotion():
	if potion_ammount > 0:
		if Input.is_action_just_pressed("Drink"):
			potion_ammount -= 1
			energy += 100
			health += 100
			is_drinking = true
			drinking_timer = 0.0

			# Start the coroutine
			start_drinking_timer()
			# Check if potion_instance exists before freeing
	else:
		pass
func _on_drinking_timer_timeout():
	is_drinking = false
	energy += 100
	health += 100
func start_drinking_timer():
	yield(get_tree().create_timer(drinking_duration), "timeout")
	_on_drinking_timer_timeout()
	if potion_instance:
		potion_instance.queue_free()
		potion_instance = null  # Reset potion_instance
