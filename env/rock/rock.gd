extends StaticBody

var health = 20
var maxhealth = 20
var floatingtext = preload("res://UI/floatingtext.tscn")
onready var rock = $rock
onready var collisionShape = $CollisionShape


func onhit(damage):
	if damage <= 0:
		return
	# Basic formula for damage
	health -= damage

	var text = floatingtext.instance()
	text.amount = float(damage)
	add_child(text)

	# Update the scale based on the remaining health percentage
	var scaleRatio = 1
	rock.scale *= scaleRatio
	collisionShape.scale *= scaleRatio

	if health <= 0:
		self.queue_free()

		
		
func get_save_stats():
	return {
		'filename': get_filename(),
		'parent': get_parent().get_path(),
		'x_pos': global_transform.origin.x,
		'y_pos': global_transform.origin.y,
		'z_pos': global_transform.origin.z,
		'stats': {
			'health': health,
		}
	}

func load_save_stats(stats):
	global_transform.origin = Vector3(stats.x_pos, stats.y_pos, stats.z_pos)
	health = stats.stats.health
	
	

