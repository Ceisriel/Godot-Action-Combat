extends Node

var floatingtext_heal = preload("res://UI/Spritefloatingtextheal.tscn")
onready var sprite = $"../Takedamage/DamageView"
const HEAL_AMOUNT = 1
const HEAL_INTERVAL = 1.0
const TOTAL_HEAL_TIMES = 10
var total_heal_times_done : int = 07

func DOThealing10seconds():
	var parent = get_parent()
	var health = parent.health
	var maxhealth = parent.maxhealth
	var intelligence = parent.intelligence
	# Access the health and maxhealth variables from the parent node "Player"

	# Reset the counter if starting a new healing cycle
	if total_heal_times_done == 0:
		total_heal_times_done = 1
	else:
		total_heal_times_done += 1

	# Heal the player's health 10 times with an interval of 1 second
	for i in range(TOTAL_HEAL_TIMES):
		# Calculate the potential health after healing
		var potential_health = parent.health + HEAL_AMOUNT

		# Ensure health doesn't exceed max_health
		parent.health = min(maxhealth, potential_health)
		var text = floatingtext_heal.instance()
		text.amount = parent.round_to_two_decimals(HEAL_AMOUNT)
		sprite.add_child(text) 

		# Wait for the interval
		yield(get_tree().create_timer(HEAL_INTERVAL), "timeout")

	# Reset the counter after fully healing 10 times
	total_heal_times_done = 0

func INSThealing():
	var parent = get_parent()
	var health = parent.health
	var maxhealth = parent.maxhealth
	var intelligence = parent.intelligence
	var inst_heal = intelligence * 1.55
	
	# Consume 0.25 of parent.energy
	parent.energy -= 0.25

	# Create the healing text instance
	var text = floatingtext_heal.instance()

	if health < maxhealth:  # Check if healing is needed
		health += inst_heal
		text.amount = parent.round_to_two_decimals(inst_heal)
	else:  # For overhealing or when already at max health
		health = maxhealth  # Limit health to maxhealth if overhealing occurs
		text.amount = parent.round_to_two_decimals(inst_heal)

	# Show the healing text regardless of healing or overhealing
	sprite.add_child(text)

	# Update the player's health
	parent.health = health
