extends Area2D

@export var popup : PackedScene

signal bounce

var is_from_block := false
var point := 200

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if is_from_block:
		bouncing()
	else:
		bounce.connect(bouncing)
		
func bouncing():
	global.play_coin_sound.emit()
	global.coin += 1
	global.point += point
	animated_sprite_2d.speed_scale = 10
	animation_player.play("get")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var p = popup.instantiate()
	p.global_position = global_position
	p.text = str(point)
	get_tree().get_root().add_child(p)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	global.play_coin_sound.emit()
	global.coin += 1
	global.point += point
	var p = popup.instantiate()
	p.global_position = global_position
	p.text = str(point)
	get_parent().add_child(p)
	queue_free()
