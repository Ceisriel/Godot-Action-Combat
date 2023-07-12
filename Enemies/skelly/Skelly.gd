extends KinematicBody

onready var bullet = preload("res://bullet.tscn")
var floatingtext = preload("res://UI/floatingtext.tscn")
onready var animation = $Archer/AnimationPlayer
onready var eyes = $Eyes
onready var ray = $RayCast
onready var hitbox = $Hitbox
var directionChangeTimer = 0.0
var directionChangeInterval = 0.0
const minChangeInterval = 3.0
const maxChangeInterval = 12.0
const turn = 32
var vertical_velocity = Vector3()
var state = "walk"
var target
# stats
var health = 400
var damage = 3
var criticalChance = 0.85
var criticalMultiplier = 3.75
var criticalDefenseChance = 0.60
var criticalDefenseMultiplier = 2
# artificial fps timer
onready var fps = $Timer
var FPS = 0.1
# Gravity strength
var gravity = Vector3(0, -9.8, 0)

# Vertical speed
var velocity = Vector3()

# Character movement speed
var speed = 5


# movement speed variables
var walkSpeed = 4.0
var chaseSpeed = 6.0
var fleeSpeed =6.00

# states list
enum {
	idle,
	chase,
	walk,
	shoot,
	flee,
}

func _ready():
	walkSpeed = walkSpeed * (FPS * 10)
	chaseSpeed = chaseSpeed * (FPS *10)
	fleeSpeed = fleeSpeed * (FPS * 10)
	state = "walk"
	directionChangeInterval = rand_range(minChangeInterval, maxChangeInterval)
	fps = Timer.new()
	add_child(fps)
	fps.wait_time = FPS
	fps.connect("timeout", self, "_on_Timer_timeout")
	fps.start()

func _on_Timer_timeout():
	chase(fps.wait_time)  # Pass the timer wait time instead of delta time
	pc(fps.wait_time)  # Pass the timer wait time instead of delta time

func onhit(damage):
	state = "shoot"
	if damage <= 0:
		return
	# Apply critical defense chance
	if randf() <= criticalDefenseChance:
		damage = damage / criticalDefenseMultiplier

	# Basic formula for damage
	health -= damage
	var text = floatingtext.instance()
	text.amount = float(damage)
	add_child(text)
	if health <= 0:
		self.queue_free()


func attack():
	var enemies = hitbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("Player"):
			if randf() <= criticalChance:
				var criticalDamage = damage * criticalMultiplier
				enemy.onhitP(criticalDamage)
			else:
				enemy.onhitP(damage)


func chase(delta):
	var players = get_tree().get_nodes_in_group("Player")
	var target = null

	if players.size() > 0:
		target = players[0]
		var minDistance = self.global_transform.origin.distance_to(target.global_transform.origin)

		for player in players:
			var distance = self.global_transform.origin.distance_to(player.global_transform.origin)
			if distance < minDistance:
				minDistance = distance
				target = player

	if target != null:
		var distanceToPlayer = self.global_transform.origin.distance_to(target.global_transform.origin)

		if distanceToPlayer > 13 and distanceToPlayer <= 15:
			state = "chase"
			target = target
		elif distanceToPlayer > 6 and distanceToPlayer <= 13:
			state = "shoot"
			target = target
		elif distanceToPlayer > 0 and distanceToPlayer <= 6:
			state = "flee"
			target = target
		else:
			state = "walk"
	else:
		state = "walk"

	match state:
		"idle":
			animation.play("idle", 0.1)
		"shoot":
			animation.play("shoot", 0.2)
			if target != null:
				eyes.look_at(target.global_transform.origin, Vector3.UP)
				rotate_y(deg2rad(eyes.rotation.y * turn))
		"walk":
			animation.play("walk", 0.2)
			directionChangeTimer += delta
			if directionChangeTimer >= directionChangeInterval:
				directionChangeTimer = 0.0
				directionChangeInterval = rand_range(minChangeInterval, maxChangeInterval)
				changeRandomDirection()
			move_and_slide(getSlideVelocity(walkSpeed))  # Pass the walk speed
		"chase":
			animation.play("chase", 0, 1.5)
			if target != null:
				var targetDirection = (target.global_transform.origin - global_transform.origin).normalized()
				eyes.look_at(global_transform.origin + targetDirection, Vector3.UP)
				rotate_y(deg2rad(eyes.rotation.y * turn))
				move_and_slide(targetDirection * getSlideVelocity(chaseSpeed).length())  # Pass the chase speed
		"flee":
			animation.play("flee shoot")
			if target != null:
				var fleeDirection = (global_transform.origin - target.global_transform.origin).normalized()
				eyes.look_at(global_transform.origin - fleeDirection, Vector3.UP)
				rotate_y(deg2rad(eyes.rotation.y * turn))
				move_and_slide(fleeDirection * getSlideVelocity(fleeSpeed).length())  # Pass the flee speed


func changeRandomDirection():
	var randomDirection = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1)).normalized()
	var lookRotation = randomDirection.angle_to(Vector3.FORWARD)
	rotate_y(lookRotation)

func getSlideVelocity(speed: float) -> Vector3:
	var forwardVector = -transform.basis.z
	return forwardVector * speed




func pc(delta):
	# Apply gravity
	velocity += gravity * delta

	# Move the character
	var movement = velocity * delta
	move_and_collide(movement)

	# Reset vertical speed if on the ground
	if is_on_floor():
		velocity.y = 0

	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var player = players[0]
		var distanceToPlayer = self.global_transform.origin.distance_to(player.global_transform.origin)
		if distanceToPlayer > 30:
			self.visible = false
			directionChangeTimer = 0.0
			directionChangeInterval = rand_range(minChangeInterval, maxChangeInterval)
		else:
			self.visible = true
	else:
		self.visible = true
