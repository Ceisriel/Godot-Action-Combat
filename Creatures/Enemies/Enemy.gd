extends KinematicBody

# This is the player, defines it as a KinematicBody, it is needed for some reason
var player: KinematicBody
# Movement
var walkSpeed: float = 4.0
var runSpeed: float = 6.0
var followRange: float = 20.0
var attackRange: float = 2.0
# Physics
var gravity: float = 90
var velocity: Vector3
# Conditional states
var walking: bool
var running: bool
var idle: bool
var alert: bool
var staggered: bool = false
var alive: bool
var scared: bool
# Attributes and stats
var maxhealth = 40.0
var health = 40.0
var damage = 5.5
var defense = 0.5
# loads the floating text from another scene
var floatingtext = preload("res://UI/floatingtext.tscn")
# Animationplayer
onready var animation = $AnimationPlayer
# Hitbox for attacks
onready var hitbox = $Hitbox


func _ready() -> void:
	health = maxhealth
	update_alive_state()

# Get the player from the scene
	player = get_node("../Player") as KinematicBody

# Changes the "alive" variable based on health value
func update_alive_state() -> void:
	alive = health > 0

# Damages the entity that has this function 
func onhit(damage):
# Basic formula for damage	
	health -= (damage - defense)
# Instance a floating text to show damage done	
	var text = floatingtext.instance()
	text.amount = float(damage - defense)
	add_child(text)
# Delete the enemy if it has less than -200 health (after death enemies can still be attacked, this is done on purpose for future functions)
	if health <= -200:
		self.queue_free()
	else:
		update_alive_state()

# Attacks and does damage to the player if it collides with hurtbox
func attack() -> void:
# Creates a varaible called "players" for anything that is inside the hurtbox	
	var players = hitbox.get_overlapping_bodies()
# Checks if there are is anything in the group Player in the hurtbox
	for Player in players:
# If there is, the Player has the ability to be hurt, then call that ability		
		if Player.has_method("hurt"):
			Player.hurt()
			Player.onhit(damage)

func _physics_process(delta: float) -> void:
# Finds the player position	
	var player_position: Vector3 = player.global_transform.origin
# Finds the distance to the player position	
	var distance: float = global_transform.origin.distance_to(player_position)

# Apply gravity
	velocity.y -= gravity * delta
# If the enemy is alive, has more than 50% of it's health, it will not be scared
	if alive:
		if health >= maxhealth / 2:
			scared = false
# If the enemy is not scared and the player is in range, it will follow the player			
			if distance <= followRange and is_on_floor():
				var direction: Vector3 = (player_position - global_transform.origin).normalized()
				velocity.x = direction.x * walkSpeed 
				velocity.z = direction.z * walkSpeed 
# Rotate the enemy to face the player 
				var rotation_y = atan2(direction.x, direction.z)
				rotation.y = rotation_y  # Rotate on the Y-axis only
# Set walking to true when moving towards the player				
				walking = true  
				running = false
			else:
				velocity.x = 0
				velocity.z = 0
				walking = false  # Set walking to false when not moving towards the player
				running = false
# If health is less than 50%, set the enemy to be scared 				
		else:
			scared = true
			if distance <= followRange and is_on_floor():
# Enemy runs away from the player 				
				var direction: Vector3 = (global_transform.origin - player_position).normalized()
				velocity.x = direction.x * runSpeed
				velocity.z = direction.z * runSpeed
# Enemy is rotated with it's back towards the player
				var rotation_y = atan2(-direction.x, -direction.z) + PI
				rotation.y = rotation_y

# Enemy stays still				
			else:
				velocity.x = 0
				velocity.z = 0
				walking = false
				running = false 
				scared = false
# Enemy stays still
	else:
			velocity.x = 0
			velocity.z = 0
			walking = false
			running = false  
			scared = false
	velocity = move_and_slide(velocity, Vector3.UP)
# Animation order and logic	
	if not alive:
		death()
	elif distance <= 2 and not scared:
		baseAttack()
	elif scared:
		escape()	 	
	elif walking and not scared:
		walkcombat()
	else:
		idle()
		
# Death pose
func death() -> void:
	animation.play("dead")
# Idle animation
func idle() -> void:
	animation.play("idle", 0.1)
# Walking animation
func walk() -> void:
	animation.play("walk", 0.1)
# Combat stance animation
func alert() -> void:
	animation.play("idle greatsword", 0.1)
# Walking in combat animation
func walkcombat() -> void:
	animation.play("walk greatsword",0.1)
# Looping attack animation
func baseAttack() -> void:
	animation.play("base attack",0.2)
# Staggered animation
func staggered() -> void:
	animation.play("hurt greatsword",0.2)
# Powerup animation
func battlecry() -> void:
	animation.play("battlecry greatsword",0.2)
# Runaway animation	
func escape() -> void:
	animation.play("sprint")
