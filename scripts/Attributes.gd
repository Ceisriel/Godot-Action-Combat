extends Control

var attribute = 10
var vitality = 1
var baseHealth = 100  # Replace with the actual base health value
onready var vitalitylabel = $VIT/VIT
onready var attributelabel = $AttributePoints

var player_script

func _ready():
	player_script = get_tree().root.find_node("Player", true, false)


	
func _on_PlusVIT_pressed():
	if attribute > 0:
		attribute -= 1
		attributelabel.text = "Attribute Points: " + str(attribute)
		vitality += 0.05
		vitalitylabel.text = "Vitality: %.2f" % vitality

		if player_script:
			var maxHealth = player_script.basemaxhealth * vitality
			player_script.maxhealth = maxHealth
			
func _on_MinusVIT_pressed():
	if vitality > 0.11:
		attribute += 1
		attributelabel.text = "Attribute Points: " + str(attribute)
		vitality -= 0.05
		vitalitylabel.text = "Vitality: %.2f" % vitality

		if player_script:
			var maxHealth = player_script.basemaxhealth * vitality
			player_script.maxhealth = maxHealth
