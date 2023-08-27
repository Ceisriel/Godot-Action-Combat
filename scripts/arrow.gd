extends RigidBody

onready var own = $"."
var damage = 12
const speed = 10

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	var camera = get_viewport().get_camera()
	if camera:
		var direction = -camera.global_transform.basis.z.normalized()
		apply_impulse(-direction, direction * speed)

func _on_Area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.takeDamage(damage)
		queue_free()


func _on_Timer_timeout():
	queue_free()




func _on_TimerDamageREduction_timeout():
	damage -= 0.05
