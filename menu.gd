extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	HUD.visible = false
	Global.reset()
	HUD.update_hud()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		HUD.visible = true
		get_tree().change_scene_to_file("res://Levels/Level1.tscn")
