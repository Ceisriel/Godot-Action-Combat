extends KinematicBody

onready var eyes = $Eyes
onready var idle_timer = $Idle
onready var direction_change_timer = $DirectionChangeTimer
var target
var originalOrientation = Quat()
var vertical_velocity = Vector3()
var gravity = Vector3(0, -50, 0)
var velocity = Vector3()
var active = true
var speed = 3.5
var is_walking = true
var ch_dir_min = 3
var ch_dir_max = 30
var id_ti_min = 0.5
var id_ti_max = 5

func _ready():
	# Reset the idle timer before starting it
	idle_timer.stop()
	idle_timer.wait_time = 0	
	originalOrientation = rotation  # Store the original orientation
	direction_change_timer.connect("timeout", self, "_change_direction")

	# Start the timer when the object is ready
	direction_change_timer.wait_time = rand_range(ch_dir_min, ch_dir_max)
	direction_change_timer.start()
	startIdleTimer()

func _on_Idle_timeout():
	is_walking = !is_walking
	
	if is_walking:
		walk()
	else:
		print ("nt mov")
		idle()
		startIdleTimer()

func idle():
	# Stop moving
	active = false
	velocity = Vector3.ZERO
	move_and_slide(velocity)
	
func startIdleTimer():
	# Start the timer with a random timeout between 1 and 2 seconds
	var timeout = rand_range(id_ti_min, id_ti_max)
	idle_timer.start(timeout)

func _on_physics_process_timeout():
	ParentCheck()
	walk()
	apply_gravity()

func ParentCheck():
	# Check if the parent is the root node of the scene or named "World" but not in the group "player"
	if get_parent() == get_tree().get_root() or (get_parent().name == "World"):
		active = true
	else:
		active = false
		resetOrientation()  # Reset orientation if not in "World" group

func walk():
	if active:
		if is_walking:
			# Walk around randomly in the direction of eyes and rotate itself to look at $Eyes
			velocity = getSlideVelocity(speed)
			move_and_slide(velocity)
		# Check if it's time to change direction
		if randf() < 0.01:  # You can adjust this probability as needed	
			_change_direction()

func getSlideVelocity(speed: float) -> Vector3:
	var forwardVector = +transform.basis.z
	return forwardVector * speed

func apply_gravity():
	if active:
		if is_on_floor():
			# If grounded, reset the Y component of velocity
			velocity.y = 0
		else:
			# Apply gravity if not grounded
			velocity += gravity 
		# Move and slide with the updated velocity
		move_and_slide(velocity, Vector3.UP)

func resetOrientation():
	# Reset the orientation to the original orientation when not in the "World" group
	rotation = originalOrientation
	# Toggle between walking and idling
	is_walking = !is_walking

func _change_direction():
	if is_walking:
	# Change the direction randomly
		rotation.y = rand_range(-360, 360)
		# Restart the timer for the next direction change
		direction_change_timer.wait_time = rand_range(ch_dir_min, ch_dir_max)
		direction_change_timer.start()
