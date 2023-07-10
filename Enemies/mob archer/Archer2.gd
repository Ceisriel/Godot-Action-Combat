extends KinematicBody

onready var animation = $Archer/AnimationPlayer
onready var eyes = $Eyes
onready var ray = $RayCast
var directionChangeTimer = 0.0
var directionChangeInterval = 0.0
const minChangeInterval = 3.0
const maxChangeInterval = 12.0
const turn = 32
var vertical_velocity = Vector3()
var gravity = 30
var state = walk
var target

#states list
enum {
	idle,
	chase,
	walk,
	shoot,
}


#as soon as the enemy spawns it will walk around randomly
func _ready():
	directionChangeInterval = rand_range(minChangeInterval, maxChangeInterval)

#if in range, the enemy will start attacking, 
#if outside of range the enemy will start chasing the player 
func _on_Sight_body_entered(body):
	if body.is_in_group("Player"):
		state = shoot
	else:
		state = idle	
func _on_Sight_body_exited(body):
	state = chase

func changeRandomDirection():
	var randomDirection = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1)).normalized()
	var lookRotation = randomDirection.angle_to(Vector3.FORWARD)
	rotate_y(lookRotation)

func getSlideVelocity():
	var forwardVector = -transform.basis.z
	return forwardVector * 4
	
func change_time(delta:float) -> bool:
	directionChangeTimer += delta
	if directionChangeTimer >= directionChangeInterval:
		directionChangeTimer = 0.0
		directionChangeInterval = rand_range(minChangeInterval, maxChangeInterval)
		return true

	return false	

#state machine logic
func _process(delta):
	match state:
		idle: 
			animation.play("idle")
		shoot:
			animation.play("shoot")
			if target != null:
				eyes.look_at(target.global_transform.origin, Vector3.UP)
				rotate_y(deg2rad(eyes.rotation.y * turn))
		walk:
			animation.play("walk")
			directionChangeTimer += delta
			if directionChangeTimer >= directionChangeInterval:
				directionChangeTimer = 0.0
				directionChangeInterval = rand_range(minChangeInterval, maxChangeInterval)
				changeRandomDirection()
			move_and_slide(getSlideVelocity())
		chase:
			animation.play("walk", 0, 1.5)
			if target != null:
				var targetDirection = (target.global_transform.origin - global_transform.origin).normalized()
				eyes.look_at(global_transform.origin + targetDirection, Vector3.UP)
				rotate_y(deg2rad(eyes.rotation.y * turn))
				move_and_slide(targetDirection * getSlideVelocity().length())

#gravity without sliding on slopes
func _physics_process(delta):
	if not is_on_floor():
		vertical_velocity += Vector3.DOWN * gravity * 2 * delta
	else:
		vertical_velocity = -get_floor_normal() * gravity / 2.5

	move_and_slide(vertical_velocity, Vector3.UP)

#if outside of chasing range the enemy will walk randomly,
#otherwise it will chase the player 
func _on_ChaseRange_body_entered(body):
	state = chase
	target = body	


func _on_ChaseRange_body_exited(body):
	state = walk
	
	
