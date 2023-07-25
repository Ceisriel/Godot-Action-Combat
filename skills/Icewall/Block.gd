extends Spatial

var floatingtext = preload("res://UI/floatingtext.tscn")
var health = 100

func takeDamage(damage):#Getting damaged
	health -= damage
	var text = floatingtext.instance()
	text.amount = float(damage)
	add_child(text)
	if health <= 0:
		self.queue_free()
