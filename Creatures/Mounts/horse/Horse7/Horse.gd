extends KinematicBody

var alive = true
var idle = false
var walking = false
var running = false
var speed = 5  # Adjust the speed as needed

var walk_duration = 1.0  # Adjust the walk duration as needed
var walk_timer = 0.0

func _ready():
	# Initialize the walk timer
	walk_timer = rand_range(3, 5)
	# Start the initial walk
	Walk()

func _on_Artificial_physics_process_timeout():
	# Use this as an alternative to physics_process(delta)
	if alive and not idle:
		Walk()

func Walk():
	# Move forward in a direction
	move_and_slide(Vector3(0, 0, -1).normalized() * speed)
	# Check if the walk duration timer has elapsed
	walk_timer -= get_process_delta_time()
	if walk_timer <= 0.0:
		# Stop walking and become idle
		idle = true
		walking = false
		running = false
		# Set a new random interval for changing direction
		_on_change_direction_timeout()
	else:
		# Update the walk timer
		walk_timer -= get_process_delta_time()

func _on_change_direction_timeout():
	# At random intervals, change directions between 3 and 5 seconds
	walk_timer = rand_range(3, 5)

	# Choose a new random direction to walk
	var random_direction = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1)).normalized()

	# Set the new direction
	rotation_degrees.y = atan2(random_direction.x, random_direction.z) * 180 / PI

	# Resume walking
	idle = false
	walking = true
	running = false
