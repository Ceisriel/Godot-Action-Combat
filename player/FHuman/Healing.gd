extends Node

const HEAL_AMOUNT = 1
const HEAL_INTERVAL = 1.0
const TOTAL_HEAL_TIMES = 10

var total_heal_times_done : int = 0

func healing():
	# Access the health and maxhealth variables from the parent node "Player"
	var player = get_parent()
	var max_health = player.maxhealth

	# Reset the counter if starting a new healing cycle
	if total_heal_times_done == 0:
		total_heal_times_done = 1
	else:
		total_heal_times_done += 1

	# Heal the player's health 10 times with an interval of 1 second
	for i in range(TOTAL_HEAL_TIMES):
		# Calculate the potential health after healing
		var potential_health = player.health + HEAL_AMOUNT

		# Ensure health doesn't exceed max_health
		player.health = min(max_health, potential_health)

		# Wait for the interval
		yield(get_tree().create_timer(HEAL_INTERVAL), "timeout")

	# Reset the counter after fully healing 10 times
	total_heal_times_done = 0
