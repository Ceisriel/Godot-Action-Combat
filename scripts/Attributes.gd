extends Control

var attribute = 10
var vitality = 1
var baseHealth = 100  # Replace with the actual base health value
onready var vitalitylabel = $VIT/VIT
onready var attributelabel = $AttributePoints

var player_script

func _ready():
	player_script = get_tree().root.get_node("Player")
	
func _on_PlusVIT_pressed():
	if attribute > 0:
		attribute -= 1
		attributelabel.text = "Attribute Points: " + str(attribute)
		vitality += 0.1
		vitalitylabel.text = "Vitality: %.2f" % vitality

		if player_script:
			var maxHealth = baseHealth * vitality
			player_script.maxhealth = maxHealth
			
func _on_MinusVIT_pressed():
	if vitality > 0.1:
		attribute += 1
		attributelabel.text = "Attribute Points: " + str(attribute)
		vitality -= 0.1
		vitalitylabel.text = "Vitality: %.2f" % vitality

		if player_script:
			var maxHealth = baseHealth * vitality
			player_script.maxhealth = maxHealth
