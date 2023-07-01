extends Position2D
onready var label = $TextureRect/Label
onready var tween = $TextureRect/Label/Tween
var amount = 0 
func _ready():
	label.set_text(str(amount))
	tween.interpolate_property(self,'scale', scale , Vector2(1, 1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self,'scale', Vector2(1,1), Vector2(0.1,0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.25)
	tween.start()
func _on_Tween_tween_all_completed():
	self.queue_free()

