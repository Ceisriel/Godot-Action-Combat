extends Spatial

# Camera variables
var move_speed = 2.5

onready var cameraHolder = $Camera_holder/Camera


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):

	# Move camera based on UI keys
	var move_vector = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		move_vector += -cameraHolder.transform.basis.y
	if Input.is_action_pressed("ui_down"):
		move_vector += +cameraHolder.transform.basis.y
	if Input.is_action_pressed("ui_right"):
		move_vector += cameraHolder.transform.basis.z
	if Input.is_action_pressed("ui_left"):
		move_vector += -cameraHolder.transform.basis.z

		


	move_vector = move_vector.normalized() * move_speed * delta
	cameraHolder.translation += move_vector

