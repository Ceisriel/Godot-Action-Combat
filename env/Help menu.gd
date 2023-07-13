extends RichTextLabel

func _process(delta):
	if Input.is_action_just_pressed("Help"):
		self.visible = !self.visible
