extends Node2D



func _on_Button_pressed():
	get_tree().change_scene("res://SaveScreen.tscn")


func _on_Exit_Game_pressed():
	get_tree().quit()


func _on_Options_pressed():
	get_tree().change_scene("res://Resolution.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

