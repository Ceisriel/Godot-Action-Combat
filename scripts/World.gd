extends Spatial

var player: PackedScene = preload("res://player/FHuman/Player.tscn")
onready var button = $Play


func instancePlayer():
	var player_instance = player.instance()
	add_child(player_instance)


func _on_Play_pressed():
	instancePlayer()
	button.queue_free()

