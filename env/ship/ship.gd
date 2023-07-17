extends KinematicBody

var velocity = Vector3.ZERO
var acceleration = 12
var damping = 0.15
var rotation_speed = 0.01
var rotation_delay = 0.1
var rotation_timer = 0.0
var playerDistanceThreshold = 200.0

func _physics_process(delta):
	# Read input or calculate desired movement direction
	var input_direction = Vector2(
		Input.get_action_strength("shipforward") - Input.get_action_strength("shipleft"),
		Input.get_action_strength("shipback") - Input.get_action_strength("shipright")
	).normalized()
	
	# Convert the 2D input direction to a 3D movement vector
	var movement = Vector3(input_direction.x, 0, input_direction.y)
	
	# Apply acceleration to the movement vector
	movement *= acceleration
	
	# Apply damping to gradually slow down the ship
	velocity = velocity.linear_interpolate(Vector3.ZERO, damping)
	
	# Add the movement vector to the velocity
	velocity += movement * delta
	
	# Calculate rotation based on the ship's velocity
	var rotation = Vector3.ZERO
	if velocity.length_squared() > 0.0:
		rotation.y = atan2(-velocity.x, -velocity.z)
	
	# Apply delayed rotation
	rotation_timer += delta
	if rotation_timer >= rotation_delay:
		rotation_timer -= rotation_delay
		rotation = rotation.linear_interpolate(rotation, rotation_speed)
	
	# Set the ship's rotation
	rotation.x = 0
	rotation.z = 0
	global_transform.basis = Basis(rotation)
	
	# Move the KinematicBody based on the calculated velocity
	move_and_slide(velocity)
	
	# Move the players within the specified distance of the ship
	for player in get_tree().get_nodes_in_group("Player"):
		var playerPosition = player.global_transform.origin
		var shipPosition = global_transform.origin
		
		var distance = playerPosition.distance_to(shipPosition)
		
		if distance <= playerDistanceThreshold:
			player.look_at(global_transform.origin, Vector3.UP)
