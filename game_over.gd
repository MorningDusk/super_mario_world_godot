extends Node2D

func _on_AudioStreamPlayer_finished():
	get_tree().change_scene_to_file("res://Menu.tscn")
