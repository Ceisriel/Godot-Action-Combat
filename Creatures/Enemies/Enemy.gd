extends KinematicBody

var player: KinematicBody
var speed: float = 4.0
var followRange: float = 20.0
var gravity: float = 90
var velocity: Vector3
var is_walking: bool
var is_idle: bool
var health: int = 1000

func _ready() -> void:
	player = get_node("../Player") as KinematicBody

func _physics_process(delta: float) -> void:
	var player_position: Vector3 = player.global_transform.origin
	var distance: float = global_transform.origin.distance_to(player_position)

	velocity.y -= gravity * delta  # Apply gravity

	if health >= 50:
		if distance <= followRange and is_on_floor():
			var direction: Vector3 = (player_position - global_transform.origin).normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed

			var rotation_y = atan2(-direction.x, -direction.z)
			rotation.y = rotation_y  # Rotate on the Y-axis only
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		if distance <= followRange * 5 and is_on_floor():
			var direction: Vector3 = (global_transform.origin - player_position).normalized()
			velocity.x = direction.x * speed * 2
			velocity.z = direction.z * speed * 2

			var rotation_y = atan2(direction.x, direction.z) + PI
			rotation.y = rotation_y  # Rotate on the Y-axis only
		else:
			velocity.x = 0
			velocity.z = 0

	velocity = move_and_slide(velocity, Vector3.UP)
