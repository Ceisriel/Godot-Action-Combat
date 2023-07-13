extends Spatial


var health = 50
var floatingtext = preload("res://UI/floatingtext.tscn")
onready var cube = $"."
onready var collisionShape = $StaticBody/CollisionShape

const MAX_SIZE_REDUCTION_FACTOR = 0.1

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
		var scale = cube.scale
		scale *= (1.0 - reductionFactor)
		cube.scale = scale
		collisionShape.scale = scale
