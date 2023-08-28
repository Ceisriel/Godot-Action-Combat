extends Control

onready var player = $".."
onready var naked = $"../FHuman/Armature/Skeleton/TorsoNaked"
onready var dress = $"../FHuman/Armature/Skeleton/TorsoDress"
onready var jute = $"../FHuman/Armature/Skeleton/TorsoJute"
onready var leather = $"../FHuman/Armature/Skeleton/TorsoLeather"
onready var semi_plate = $"../FHuman/Armature/Skeleton/TorsoSemiPlate"
var is_naked = bool()
var has_dress = bool()
var has_jute = bool()
var has_leather = bool()
var has_semi_plate = bool()
# Store the original intelligence level of the parent node
var dress_modified = false
var semip_modified = false
var leather_modified = false
var jute_modified = false

func _ready():
	switchArmors()
	Dress()

func switchArmors():
	if is_naked:
		naked.show()
		dress.hide()
		jute.hide()
		leather.hide()
		semi_plate.hide()
		has_dress = false
		has_jute = false
		has_leather = false
		has_semi_plate = false	
	elif has_dress:
		naked.hide()
		dress.show()
		jute.hide()
		leather.hide()
		semi_plate.hide()		
		is_naked = false
		has_jute = false
		has_leather = false
		has_semi_plate = false	
	elif has_jute:
		naked.hide()
		dress.hide()
		jute.show()
		leather.hide()
		semi_plate.hide()		
		is_naked = false
		has_dress = false		
		has_leather = false
		has_semi_plate = false	
	elif has_leather:
		naked.hide()
		dress.hide()
		jute.hide()
		leather.show()
		semi_plate.hide()		
		is_naked = false
		has_dress = false		
		has_jute = false
		has_semi_plate = false					
	elif has_semi_plate:
		naked.hide()
		dress.hide()
		jute.hide()
		leather.hide()
		semi_plate.show()		
		is_naked = false
		has_dress = false		
		has_jute = false
		has_leather = false
						


func _on_naked_pressed():
	is_naked = true
	has_dress = false
	has_jute = false
	has_leather = false
	has_semi_plate = false	

func _on_dress_pressed():
	has_dress = true
	is_naked = false
	has_jute = false
	has_leather = false
	has_semi_plate = false	

func _on_jute_pressed():
	has_jute = true
	is_naked = false
	has_dress = false		
	has_leather = false
	has_semi_plate = false	

func _on_Semi_Plate_pressed():
	has_semi_plate = true
	is_naked = false
	has_dress = false		
	has_jute = false
	has_leather = false
	
func _on_leater_pressed():
	has_leather = true
	is_naked = false
	has_dress = false		
	has_jute = false
	has_semi_plate = false	
func _on_Virtual_FPS_timeout():
	switchArmors()
	Dress()
	SemiPlate()
	Leather()
	Jute()
	
func JuteEffect(active: bool):
	if active and not jute_modified:
		jute_modified = true
		player.agility += 0.1  # Adjust the boost values as needed
		player.maxenergy += 0.15 # For example, adding evasion boost
	elif not active and jute_modified:
		player.agility -= 0.1
		player.maxenergy -= 0.15
		jute_modified = false

func DressEffect(active: bool):
	if active and not dress_modified:
		dress_modified = true
		player.intelligence += 0.5
		player.vitality += 0.05
		player.agility += 0.05
	elif not active and dress_modified:
		player.intelligence -= 0.5
		player.vitality -= 0.05
		player.agility -= 0.05
		dress_modified = false

func SemiPlateEffect(active: bool):
	if active and not semip_modified:
		semip_modified = true
		player.vitality += 0.105
		player.agility += 0.205
	elif not active and semip_modified:
		player.vitality -= 0.105
		player.agility -= 0.205
		semip_modified = false
		
func LeatherEffect(active: bool):
	if active and not leather_modified:
		leather_modified = true
		player.vitality += 0.08  # Adjust the boost values as needed
		player.defense += 0.1    # For example, adding defense boost
	elif not active and leather_modified:
		player.vitality -= 0.08
		player.defense -= 0.1
		leather_modified = false
func Jute():
	if has_jute:
		JuteEffect(true)
		if dress_modified:
			DressEffect(false)
		if semip_modified:
			SemiPlateEffect(false)
		if leather_modified:
			LeatherEffect(false)
	else:
		JuteEffect(false)		
func Dress():
	if has_dress:
		DressEffect(true)
		if semip_modified:
			SemiPlateEffect(false)
	else:
		DressEffect(false)

func SemiPlate():
	if has_semi_plate:
		SemiPlateEffect(true)
		if dress_modified:
			DressEffect(false)
	else:
		SemiPlateEffect(false)

func Leather():
	if has_leather:
		LeatherEffect(true)
		if dress_modified:
			DressEffect(false)
		if semip_modified:
			SemiPlateEffect(false)
	else:
		LeatherEffect(false)
