extends KinematicBody


onready var eyes = $Eyes
onready var IdleWalk_timer = $IdleWalk
onready var healthlabel =$Spatial2/Viewport/HealthLabel
onready var namelabel =$Spatial/Viewport/NameLabel
var floatingtext = preload("res://UI/floatingtext.tscn")
var entityname 
var health = 100
var maxhealth = 100
var target
var blocking = false 
var isWalking = true  # Initial state is walking
var alive = true
var originalOrientation = Quat()
var vertical_velocity = Vector3()
var gravity = Vector3(0, -1, 0)  # Adjust the Y component as needed
var velocity = Vector3()
var is_grounded = false
var ground_ray_length = 0.1  # Adjust the length of the ground check ray


func _ready():
	originalOrientation = rotation  # Store the original orientation
	changeRandomDirection()  # Set initial random direction
	IdleWalk_timer.connect("timeout", self, "_on_Idlewalk_timeout")
	startIdleTimer()

func startIdleTimer():
	# Start the timer with a random timeout between 1 and 2 seconds
	var timeout = rand_range(1, 2)
	IdleWalk_timer.start(timeout)

func _on_Artificial_physics_process_timeout():
	
	if not is_parent_in_player_group():
		apply_gravity()
		if isWalking:
			walk()
	else:
		resetOrientation()  # Reset orientation if not in "World" group
		startIdleTimer()  # Start the timer for the next state switch

func walk():
	# Walk around randomly in the direction of eyes and rotate itself to look at $Eyes
	var speed = 5.0  # Adjust the speed as needed
	var velocity = getSlideVelocity(speed)
	move_and_slide(velocity)

	# Check if it's time to change direction
	if randf() < 0.01:  # You can adjust this probability as needed
		changeRandomDirection()

func idle():
	# Stop moving
	var velocity = Vector3.ZERO
	move_and_slide(velocity)

	# Additional idle logic if needed

func changeRandomDirection():
	var randomDirection = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1)).normalized()
	var lookRotation = randomDirection.angle_to(Vector3.FORWARD)
	rotate_y(lookRotation)

func getSlideVelocity(speed: float) -> Vector3:
	var forwardVector = +transform.basis.z
	return forwardVector * speed

func _on_Idlewalk_timeout():
	# Toggle between walking and idling
	isWalking = !isWalking

	if isWalking:
		walk()
	else:
		idle()

	# Start the timer with a new random timeout for the next state switch
	startIdleTimer()
func is_parent_in_player_group() -> bool:
	# Check if the parent exists and is in the "Player" group
	var parent = get_parent()
	var isInPlayerGroup = parent != null and parent.is_in_group("Player")
	
	if isInPlayerGroup:
		print("Parent is in the 'Player' group.")
	
	return isInPlayerGroup
func resetOrientation():
	# Reset the orientation to the original orientation when not in the "World" group
	rotation = originalOrientation
func _on_IdleWalk_timeout():
	pass # Replace with function body.
func updatehealthlabel():
# Update health bar
	healthlabel.text = "Health: %.2f / %.2f" % [health, maxhealth]
# Update the UI or display a message to indicate the attribute increase
	var healthText = "Health: %.2f / %.2f" % [health, maxhealth]	
func takeDamage(damage):
	updatehealthlabel()
	if not is_parent_in_player_group():
		if not blocking: 
			if damage <= 0:
				return

			health -= damage
			var text = floatingtext.instance()
			text.amount = float(damage)
			add_child(text)
			if health <= 0:
				alive = false
			if health <= -200:
				self.queue_free()



func apply_gravity():
	if is_on_floor():
		# If grounded, reset the Y component of velocity
		velocity.y = 0
	else:
		# Apply gravity if not grounded
		velocity += gravity 

	# Check for ground contact
	is_grounded = is_on_floor()

	# Move and slide with the updated velocity
	move_and_slide(velocity, Vector3.UP)

	# Debug draw the ground check ray (optional)
	#debug_draw_ground_ray()
