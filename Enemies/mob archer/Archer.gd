extends KinematicBody

var floatingtext = preload("res://UI/floatingtext.tscn")
onready var animation = $skeleton/AnimationPlayer
onready var eyes = $Eyes
onready var ray = $RayCast
onready var hitbox = $Hitbox
var directionChangeTimer = 0.0
var directionChangeInterval = 0.0
const minChangeInterval = 3.0
const maxChangeInterval = 12.0
const turn = 32
var vertical_velocity = Vector3()
var gravity = 30
var state = "walk"
var target
# stats
var health = 100
var damage = 20
var criticalChance = 0.60
var criticalMultiplier = 2.0
var criticalDefenseChance = 0.60
var criticalDefenseMultiplier = 2
#artificial fps timer
onready var fps = $Timer

# states list
enum {
	idle,
	chase,
	walk,
	shoot,
	flee,
}

func _ready():
	state = "walk"
	directionChangeInterval = rand_range(minChangeInterval, maxChangeInterval)
	fps = Timer.new()
	add_child(fps)
	fps.wait_time = 0.078
	fps.connect("timeout", self, "_on_Timer_timeout")
	fps.start()

func _on_Timer_timeout():
	chase(get_process_delta_time())
	pc(get_process_delta_time())

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
			if enemy.energy >= 0:
				enemy.energy -= damage/10

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
			move_and_slide(getSlideVelocity())
		"chase":
			animation.play("chase", 0, 1.5)
			if target != null:
				var targetDirection = (target.global_transform.origin - global_transform.origin).normalized()
				eyes.look_at(global_transform.origin + targetDirection, Vector3.UP)
				rotate_y(deg2rad(eyes.rotation.y * turn))
				move_and_slide(targetDirection * getSlideVelocity().length())
		"flee":
			animation.play("flee shoot")
			var fleeDirection = -getSlideVelocity().normalized()
			move_and_slide(fleeDirection * getSlideVelocity().length())

func changeRandomDirection():
	var randomDirection = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1)).normalized()
	var lookRotation = randomDirection.angle_to(Vector3.FORWARD)
	rotate_y(lookRotation)

func getSlideVelocity():
	var forwardVector = -transform.basis.z
	return forwardVector * 4

func pc(delta):
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

	if not is_on_floor():
		vertical_velocity += Vector3.DOWN * gravity * 2 * delta
	else:
		vertical_velocity = -get_floor_normal() * gravity / 2.5

	move_and_slide(vertical_velocity, Vector3.UP)
