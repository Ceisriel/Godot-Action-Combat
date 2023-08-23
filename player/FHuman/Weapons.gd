extends Node

onready var weaponManager = $"../GUI/Edit_Character/WeaponManager"



func _on_ItemDetector_body_entered(body):
	if body.is_in_group("RepeatingCrossbow"):
		if Input.is_action_pressed("E"):
			if body.get_parent() != weaponManager.weapon_attachment:  # Check against the weapon_attachment node
				print("Removing body")
				body.queue_free()
				weaponManager.pickupCrossbow()
