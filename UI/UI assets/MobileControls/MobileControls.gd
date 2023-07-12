extends CanvasLayer


func _physics_process(delta):
	if Input.is_action_just_pressed("HideMobileControls"):
		self.visible = !self.visible
