extends Node2D

func _on_Mario_death():
	$Theme.stop()
	
func _on_Pole_course_clear():
	$Theme.stop()
	$CourseClear.play()
	
func _on_CourseClear_finished():
	if Global.level + 1 > 3:
		get_tree().change_scene_to_file("res://game_over.tscn")
	else:
		Global.level += 1
		HUD.update_hud()
		get_tree().change_scene_to_file("res://Levels/Level" + str(Global.level) + ".tscn")
