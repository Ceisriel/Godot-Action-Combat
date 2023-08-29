extends KinematicBody

var floatingtext = preload("res://UI/floatingtext.tscn")
onready var namelabel = $Spatial/Viewport/Label
onready var healthlabel = $Spatial2/Viewport/Label
var entityname = "DPS dummy"
# stats
var health = 10000000000
var maxhealth = 10000000000
var damage = 1
var criticalMultiplier = 1.5
var criticalDefenseChance = 0.60
var criticalDefenseMultiplier = 2

# artificial fps timer
onready var fps = $Timer
var FPS = 0.083

func _ready():
	namelabel.text = entityname

func takeDamage(damage):
	updatehealthlabel()

	if damage <= 0:
		return

	# Apply critical defense chance
	if randf() <= criticalDefenseChance:
		damage = damage / criticalDefenseMultiplier
	
	# Basic formula for damage
	health -= damage
	var text = floatingtext.instance()
	text.amount = float(damage)
	add_child(text)

func updatehealthlabel():
	# Update health bar
	healthlabel.text = "Health: %.2f / %.2f" % [health, maxhealth]
	# Update the UI or display a message to indicate the attribute increase
	var healthText = "Health: %.2f / %.2f" % [health, maxhealth]

func _on_Timer_timeout():
	updatehealthlabel()
	if health < maxhealth:  # Check if health is less than maxhealth
		health += 10000
		if health > maxhealth:  # Cap health to maxhealth
			health = maxhealth


