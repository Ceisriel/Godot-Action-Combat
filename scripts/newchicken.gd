extends KinematicBody

var health: int = 100
var hunger: int = 200
var timer: float = 0.0
var regainHungerTimer: float = 0.0
var isFeeding: bool = false
var maxHunger: int = 400
var growthFactor: float = 0.001
onready var hitbox = $Area
var damage = 1

func attack():
	var food = hitbox.get_overlapping_bodies()
	for chickenfood in food:
		if chickenfood.has_method("onhit"):
			chickenfood.onhit(damage)



func _ready():
	set_process(true)

func _process(delta: float):
	timer += delta

	# Decrease hunger by 1 every second if not feeding
	if timer >= 1.0:
		timer = 0.0
		if !isFeeding:
			hunger -= 1

		# If hunger reaches 0, start losing health
		if hunger <= 0:
			health -= 1

	print("Health:", health)
	print("Hunger:", hunger)

	# Add the logic to find and move towards the closest chicken food within the specified radius
	var chickenFood = get_tree().get_nodes_in_group("chickenfood")
	var closestFood = null
	var closestDistance = 100000.0  # A large initial distance value

	for food in chickenFood:
		var distance = food.global_transform.origin.distance_to(global_transform.origin)
		if distance < closestDistance:
			closestFood = food
			closestDistance = distance

	if closestFood:
		var direction = (closestFood.global_transform.origin - global_transform.origin).normalized()

		# Check if the chicken has reached within 0.5 meters of the food
		if closestDistance > 0.5:
			move_and_slide(direction * 100 * delta)
			isFeeding = false
		else:
			# Chicken has reached the food, stop moving and start gaining back hunger
			move_and_slide(Vector3.ZERO)

			# Increase hunger by 1 every second if not already feeding
			if !isFeeding:
				isFeeding = true
				regainHungerTimer = 0.0
			else:
				regainHungerTimer += delta
				if regainHungerTimer >= 1.0:
					regainHungerTimer = 0.0
					hunger += 1

					# Check if hunger surpasses 200 to trigger growth
					if hunger > 200:
						growInSize()
						health += 1

func growInSize():
	var growthAmount = (hunger - 200) * growthFactor
	if hunger >= maxHunger:
		growthAmount = (maxHunger - 200) * growthFactor

	# Apply growth in size to the chicken
	scale += Vector3(growthAmount, growthAmount, growthAmount)
