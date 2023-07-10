extends Button

onready var playerScript = get_parent().get_node("Player")

func _ready():
	connect("pressed", self, "_onButtonPressed")

func _onButtonPressed():
	playerScript.maxhealth += 1000
