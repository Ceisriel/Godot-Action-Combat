extends Control

onready var healthLabel = $healthLabel
var player

func _ready():
	player = load("res://scripts/Action combat.gd").new()  # Instantiate the player object
	updateHealthLabel()

func updateHealthLabel():
	if player != null and player.has_method("maxHealth"):
		var maxhealth = player.maxhealth
		healthLabel.text = "Max Health: " + str(maxhealth)
	else:
		healthLabel.text = "Player object not found or missing maxHealth method"
