class_name Bonustool
extends Area2D

enum action_type {
	crouch,
	walk_left,
	walk_right,
	jump,
}

@export var pose := action_type.crouch
@export var world_style := global.world_style.normal
@export var camera_style := global.camera_type.move_horizontal
@export var spawn_point : Vector2
@export var camera_target : Vector2

var player : CharacterBody2D

func _ready() -> void:
	body_entered.connect(player_in)
	body_exited.connect(player_out)
	set_process(false)
		
func player_in(body : Node2D):
	player = body
	set_process(true)
	
func player_out(body : Node2D):
	set_process(false)
	player = null

func _process(delta: float) -> void:
	match pose:
		action_type.crouch:
			if Input.is_action_pressed("ui_down"):
				animation_and_change_scene(player)
		action_type.walk_right:
			if Input.is_action_pressed("ui_right"):
				animation_and_change_scene(player)
					
func animation_and_change_scene(player : Node2D):
	player.emit_signal("stop_any_move")
	set_process(false)
	global.spawn_point = spawn_point
	global.style = world_style
	var tween = create_tween()
	match pose:
		action_type.crouch:
			tween.tween_property(player, "global_position:y", player.global_position.y + 24, 1.0)
		action_type.walk_right:
			tween.tween_property(player, "global_position:x", player.global_position.x + 24, 1.0)
	await tween.finished
	global.change_style.emit()
	global.camera_limit_change.emit(camera_target, camera_style)
	global.move_to_bonus.emit(spawn_point)
