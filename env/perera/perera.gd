extends StaticBody

var health = 100
var floatingtext = preload("res://UI/floatingtext.tscn")
onready var rock = $perera
onready var collisionShape = $CollisionShape

const MAX_SIZE_REDUCTION_FACTOR = 0.01

func onhit(damage):
	if damage <= 0:
		return

	# Calculate damage percentage
	var damagePercentage = float(damage) / float(health)

	# Basic formula for damage
	health -= damage

	var text = floatingtext.instance()
	text.amount = float(damage)
	add_child(text)

	if health <= 0:
		self.queue_free()
	else:
		# Calculate the proportional reduction factor based on health and damage percentage
		var reductionFactor = MAX_SIZE_REDUCTION_FACTOR * damagePercentage

		# Scale down the rock and collision shape nodes
		var scale = rock.scale
		scale *= (1.0 - reductionFactor)
		rock.scale = scale
		collisionShape.scale = scale
