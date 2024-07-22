extends CharacterBody2D

signal stop_any_move

const MAX_SPEED := 120.0
const RUN_MAX_SPEED := 180.0
const ACCELERATION := 200.0
const FRICTION := 300.0
const JUMP_VELOCITY := -350.0
const KILL_JUMP_VELOCITY := -200.0
const HIGHEST_JUMP_VELOCITY := -400.0

@export var fire : PackedScene
@export var die_doll : PackedScene

@onready var graphic: Node2D = $graphic
@onready var small_sprite: Sprite2D = $graphic/small
@onready var big_sprite: Sprite2D = $graphic/big
@onready var fire_big_sprite: Sprite2D = $graphic/fire
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jump_cancel_timer: Timer = $"jump cancel Timer"
@onready var coin: AudioStreamPlayer = $coin
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var shoot_gap_timer: Timer = $"shoot gap timer"
@onready var recover_timer: Timer = $"recover timer"
@onready var invincible_timer: Timer = $"invincible timer"
@onready var coyote_timer: Timer = $"coyote timer"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = global.gravity
var on_air := false:
	set(v):
		if v == true and on_air != v:
			coyote_timer.start()
		on_air = v
var last_dir : float
var now_face = 1

func _ready() -> void:
	global.play_coin_sound.connect(play_coin_sound)
	global.power_up.connect(power_up_animation)
	global.player_hurt.connect(hurt)
	global.player_die.connect(die)
	global.get_star.connect(get_star)
	global.move_to_bonus.connect(teleport)
	stop_any_move.connect(stop)
	
	small_sprite.material.set("shader_parameter/strength", 0.0)
	big_sprite.material.set("shader_parameter/strength", 0.0)
	fire_big_sprite.material.set("shader_parameter/strength", 0.0)
	global.invincible = false
	
	global_position = global.spawn_point
	
	match global.size:
		1:
			small_sprite.visible = true
			collision_shape_2d.shape.size = Vector2(14, 14)
			collision_shape_2d.position.y = 1
		2,3:
			if global.size == 2:
				small_sprite.visible = false
				big_sprite.visible = true
				fire_big_sprite.visible = false
			else:
				small_sprite.visible = false
				big_sprite.visible = false
				fire_big_sprite.visible = true
			collision_shape_2d.shape.size = Vector2(14, 32)
			collision_shape_2d.position.y = -8
	
func hurt():
	match global.size:
		3:
			graphic.modulate.a = 0.5
			set_physics_process(false)
			animation_player.play("fire hurt")
			await get_tree().create_timer(0.2, false).timeout
			global.size = 1
			set_physics_process(true)
			global.player_hurt.disconnect(hurt)
			recover_timer.start()
		2:
			graphic.modulate.a = 0.5
			set_physics_process(false)
			animation_player.play("big hurt")
			await get_tree().create_timer(0.2, false).timeout
			global.size = 1
			set_physics_process(true)
			
			global.player_hurt.disconnect(hurt)
			recover_timer.start()
			
		1:
			die()
			
func die():
	var doll = die_doll.instantiate()
	doll.global_position = global_position
	get_parent().add_child(doll)
	set_physics_process(false)
	small_sprite.material.set("shader_parameter/strength", 0.0)
	big_sprite.material.set("shader_parameter/strength", 0.0)
	fire_big_sprite.material.set("shader_parameter/strength", 0.0)
	global.invincible = false
	collision_shape_2d.set_deferred("disabled", true)
	visible = false
	animation_player.play("RESET")
	get_tree().paused = true
	
func power_up_animation():
	set_physics_process(false)
	
	if global.size == 1:
		animation_player.play("become bigger")
		await get_tree().create_timer(0.2, false).timeout
		global.size = 2
	elif global.size == 2:
		animation_player.play("on fire")
		await get_tree().create_timer(0.2, false).timeout
		global.size = 3
		
	set_physics_process(true)

func play_coin_sound():
	coin.play()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and global.size == 3 and shoot_gap_timer.time_left == 0:
		var f = fire.instantiate()
		f.global_position = marker_2d.global_position
		f.dir = graphic.scale.x
		get_parent().add_child(f)
		shoot_gap_timer.start()
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		on_air = true
	else:
		global.multiple_stamp = 0
		on_air = false
		
	if is_on_floor() or coyote_timer.time_left > 0:
		if Input.is_action_just_pressed("jump"):
			if abs(velocity.x) > MAX_SPEED:
				velocity.y = HIGHEST_JUMP_VELOCITY
			else:
				velocity.y = JUMP_VELOCITY
			jump_cancel_timer.start()
		
	
	if Input.is_action_just_released("jump") and velocity.y < 0 and jump_cancel_timer.time_left == 0:
		velocity.y = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var dash := Input.is_action_pressed("attack")
	var crouch := Input.is_action_pressed("ui_down")
	
	if direction and not crouch:
		
		if velocity.x > 0:
			now_face = 1
		elif velocity.x < 0:
			now_face = -1
		last_dir = direction
		global.player_dir = last_dir
		
		if dash:
			velocity.x += direction * ACCELERATION * delta * 1.8
		else:
			velocity.x += direction * ACCELERATION * delta
			
		if direction != now_face:
			if is_on_floor():
				velocity.x += direction * FRICTION * delta
			else:
				velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta * 0.5)
		
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta * 2)
		elif crouch:
			velocity.x += direction * ACCELERATION * delta
			
		
		
	if dash:
		velocity.x = clamp(velocity.x , -RUN_MAX_SPEED, RUN_MAX_SPEED)
	else:
		velocity.x = clamp(velocity.x , -MAX_SPEED, MAX_SPEED)
	
	graphic_handler(velocity.x, direction, now_face, dash)
	move_and_slide()
	global.player_position = global_position
	
func get_star():
	small_sprite.material.set("shader_parameter/strength", 0.5)
	big_sprite.material.set("shader_parameter/strength", 0.5)
	fire_big_sprite.material.set("shader_parameter/strength", 0.5)
	global.invincible = true
	invincible_timer.start()
	
func graphic_handler(horizontal_velocity : float, direction : float, face_dir : int, is_dash : bool):
	if not on_air:
		if direction > 0:
			graphic.scale.x = 1
		elif direction < 0:
			graphic.scale.x = -1
		
	if on_air:
		animation_player.play("jump")
	elif horizontal_velocity != 0:
		if is_dash:
			animation_player.play("walk", -1, 2.0)
		elif direction:
			animation_player.play("walk")
		else:
			animation_player.play("walk", -1, 0.5)
		if int(direction) != face_dir and direction != 0:
			animation_player.play("turn back")
	elif not animation_player.current_animation == "shoot fire":
		animation_player.play("idle")
	
	if Input.is_action_pressed("ui_down"):
		animation_player.play("crouch")
		collision_shape_2d.shape.size = Vector2(14,14)
		collision_shape_2d.position = Vector2(0,1)
	
	if Input.is_action_just_released("ui_down") and global.size >= 2:
		collision_shape_2d.shape.size = Vector2(14,32)
		collision_shape_2d.position = Vector2(0,-8)

func _on_jump_cancel_timer_timeout() -> void:
	if not Input.is_action_pressed("jump"):
		velocity.y = 0

func _on_enemy_checker_body_entered(body: Node2D) -> void:
	if not is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity.y = HIGHEST_JUMP_VELOCITY
		else:
			velocity.y = KILL_JUMP_VELOCITY
			coyote_timer.start()


func _on_recover_timer_timeout() -> void:
	global.player_hurt.connect(hurt)
	graphic.modulate.a = 1

func stop() -> void:
	set_physics_process(false)
	set_process_input(false)
	global.play_coin_sound.disconnect(play_coin_sound)
	global.power_up.disconnect(power_up_animation)
	global.player_hurt.disconnect(hurt)
	global.player_die.disconnect(die)
	global.get_star.disconnect(get_star)
	velocity = Vector2.ZERO
	
func teleport(target : Vector2):
	global_position = target
	set_physics_process(true)
	set_process_input(true)
	global.play_coin_sound.connect(play_coin_sound)
	global.power_up.connect(power_up_animation)
	global.player_hurt.connect(hurt)
	global.player_die.connect(die)
	global.get_star.connect(get_star)

func _on_invincible_timer_timeout() -> void:
	small_sprite.material.set("shader_parameter/strength", 0.0)
	big_sprite.material.set("shader_parameter/strength", 0.0)
	fire_big_sprite.material.set("shader_parameter/strength", 0.0)
	global.invincible = false
