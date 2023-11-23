extends KinematicBody

var floatingtext = preload("res://UI/floatingtext.tscn")
onready var animation = $Spearskeleton/AnimationPlayer
onready var eyes = $Eyes
onready var ray = $RayCast
onready var hitbox = $Hitbox
onready var namelabel = $Spatial/Viewport/Label
onready var healthlabel = $Spatial2/Viewport/Label
var entityname = "Skeleton Spearman"
#timers for movement
var directionChangeTimer = 0.0
var directionChangeInterval = 0.0
const minChangeInterval = 3.0
const maxChangeInterval = 12.0
#timers for combat 
var switchTimer = Timer.new()
var switchTimeMin = 1.0
var switchTimeMax = 1.5
#movement
const turn = 32
var vertical_velocity = Vector3()
#var gravity = 30
var state = "walk"
var target
# stats
var health = 100
var maxhealth = 100
var damage = 1
var criticalChance = 0.70
var criticalMultiplier = 1.5
var criticalDefenseChance = 0.60
var criticalDefenseMultiplier = 2
var impact 
var blockdamage = 3
# artificial fps timer
onready var fps = $Timer
var FPS = 0.045
#bools
var isGrounded = false
var blocking : bool
var kick : bool
var stabbing : bool
var slashing : bool
var slash_still : bool
var trust: bool
var is_blocking : bool
#live or die
var dead = false
# movement speed variables
var walkSpeed = 12.0
var chaseSpeed = 15.0
var fleeSpeed = 15.50

# Gravity strength
var gravity = Vector3(0, -9.8, 0)
# Vertical speed
var velocity = Vector3()

# Character movement speed
var speed = 5

func onhitKnockback(impact):
	# Calculate the knockback direction
	var knockbackDirection = -global_transform.basis.z.normalized()
	# Apply the knockback force to the velocity
	velocity = knockbackDirection * impact

func takeDamage(damage):

	if not blocking: 
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
			dead = true
		if health <= -200:
			self.queue_free()
	if blocking: 
		if damage <= 0:
			return
	# Apply critical defense chance
		if randf() <= criticalDefenseChance:
			damage = damage / criticalDefenseMultiplier
		# Basic formula for damage
		health -= damage / blockdamage
		var text = floatingtext.instance()
		text.amount = float(damage)
		add_child(text)
	if health <= 0:
			dead = true	
	if health <= -200:
			self.queue_free()


func pc(delta):
	# Apply gravity
	velocity += gravity * delta
	# Move the character
	var movement = velocity * delta
	move_and_collide(movement)

	# Reset vertical speed if on the ground
	if is_on_floor():
		velocity.y = 0



