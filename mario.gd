extends CharacterBody2D
class_name Player

signal death
signal entered_pipe

var gravity = 30
var motion = Vector2()
var UP = Vector2(0, -1)
const MAXVELOCITY = 250
var JUMP_FORCE = -680
var jump = false
var is_alive = true
var invincible = false
var is_on_pipe = false

var winner = false
var pole_final_position = null

var current_animation_index = 0

var animations = [
	["run", "idle", "jump", "fall", "duck", "lookup", "spin", "walk"],
	["run_big", "idle_big", "jump_big", "fall_big", "duck_big", "lookup_big", "spin_big", "walk_big"]
]
const WALK_SPEED = 150.0
const RUN_SPEED = 200.0
const JUMP_VELOCITY = -350.0
const GRAVITY = 980.0
const ACCELERATION = 20.0
const FRICTION = 10.0
const SPIN_JUMP_VELOCITY = -400.0

var is_running = false
var is_crouching = false
var is_jumping = false
var is_spinning = false
var is_lookingup = false
var facing_right = true
var current_animation = "idle"
var spin_timer = 0.0
const SPIN_DURATION = 0.8

@onready var animation_player = $AnimationPlayer

func _ready():
	if Global.is_big:
		$Sprite2D.position.y -= 8
		current_animation_index = 1

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	is_lookingup = false
	
	if is_on_floor():
		is_jumping = false
		is_spinning = false
		spin_timer = 0.0
		
		if Input.is_action_pressed("ui_up") and !Input.is_action_pressed("ui_down"):
			is_lookingup = true
			velocity.x = move_toward(velocity.x, 0, FRICTION)
		
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		if Input.is_key_pressed(KEY_SHIFT):
			velocity.y = SPIN_JUMP_VELOCITY
			is_spinning = true
			spin_timer = SPIN_DURATION
			is_jumping = true
		else:
			velocity.y = JUMP_VELOCITY
			is_jumping = true
			
	if is_spinning:
		spin_timer -= delta
		if spin_timer <= 0:
			is_spinning = false
			
	var direction = Input.get_axis("ui_left", "ui_right")
	is_running = Input.is_key_pressed(KEY_SHIFT)
	var target_speed = RUN_SPEED if is_running else WALK_SPEED
	
	if !is_crouching and !is_lookingup:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * target_speed, ACCELERATION)
			facing_right = direction > 0
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION)
			
	is_crouching = Input.is_action_pressed("ui_down") and is_on_floor() and !is_lookingup
	if is_crouching:
		velocity.x = move_toward(velocity.x, 0, FRICTION * 2)
		
	$Sprite2D.flip_h = !facing_right
	
	update_animation()
	
	move_and_slide()
	
func update_animation():
	var new_animation = animations[current_animation_index][1]
	
	if !is_on_floor():
		if is_spinning:
			new_animation = animations[current_animation_index][6]
		else:
			new_animation = animations[current_animation_index][2]
	elif is_lookingup:
		new_animation = animations[current_animation_index][5]
	elif is_crouching:
		new_animation = animations[current_animation_index][4]
	elif abs(velocity.x) > 0:
		new_animation = animations[current_animation_index][2] if is_running else animations[current_animation_index][7]
	
	if current_animation != new_animation:
		current_animation = new_animation
		$Sprite2D.play(current_animation)
		
func update_spin_hitbox():
	if has_node("SpinHitBox"):
		$SpinHitBox.monitoring = is_spinning

func on_hit_area_entered(area):
	if area.is_in_group("enemies"):
		if is_spinning:
			area.queue_free()
		elif velocity.y > 0:
			velocity.y = JUMP_VELOCITY * 0.5
			area.queue_free()
		else:
			damage()

func down_pole(pole_final_position):
	winner = true
	self.pole_final_position = pole_final_position
	
func is_falling():
	return motion.y > 0
	
func grow():
	if not Global.is_big:
		$Sprite2D.position.y -= 8
		current_animation_index = 1
		Global.is_big = true
		$PowerUp.play()
		
func damage():
	if Global.is_big:
		$Sprite2D.position.y += 8
		current_animation_index = 0
		Global.is_big = false
		invincible = true
		$AnimationPlayer.play("flashing")
		$PlayerDown.play()
		$Invincibility.start()
	else:
		die()
		
func die():
	if not invincible and is_alive:
		$AnimationPlayer.play("death")
		is_alive = false
		$Death.play()
		$AfterDeath.start()
		emit_signal("death")

func _on_Invincibility_timeout():
	invincible = false
	
func pick_coin():
	Global.coins += 1
	HUD.update_hud()
	$PickCoin.play()

func break_block():
	$BreakBlock.play()
	
func stomp_enemy():
	$StompEnemy.play()
	
func _on_AfterDeath_timeout():
	Global.lifes -= 1
	HUD.update_hud()
	if Global.lifes < 0:
		Global.is_big = false
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://game_over.tscn")


func _on_death() -> void:
	pass # Replace with function body.
