extends CharacterBody2D
class_name Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_cast_2d: RayCast2D = $graphic/RayCast2D
@onready var graphic: Node2D = $graphic
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $graphic/Sprite2D
@onready var player_checker = $Player_checker

@export var popup : PackedScene
@export var dead_doll : PackedScene
@export var speed := 30
@export var dir := -1:
	set(v):
		if not graphic == null:
			dir = v
			graphic.scale.x = -v

enum damage_type {
	stamp,
	fire,
	deadzone
}

signal hurt(type : damage_type)

var score_list := [
	100,
	200,
	400,
	500,
	800,
	1000,
	2000,
	4000,
	5000,
	8000,
]

var gravity := global.gravity
var dying := false

func _ready() -> void:
	set_process(false)
	hurt.connect(dealing_hurt)
	
func move_foward(delta : float):
	velocity.x = speed * dir
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if ray_cast_2d.is_colliding():
		dir *= -1
		
	move_and_slide()
		
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	set_process(true)

func dealing_hurt(type : damage_type = damage_type.fire):
	#override this function in every enemy's script to check damage source
	dealing_score(type)
	animation_player.play("die")
	collision_shape_2d.set_deferred("disabled", true)
	set_process(false)
	dying = true

func dealing_die():
	var d = dead_doll.instantiate()
	var d_sprite = d.get_node("Sprite2D")
	d_sprite.texture = sprite_2d.texture
	d_sprite.hframes = sprite_2d.hframes
	d_sprite.vframes = sprite_2d.vframes
	d_sprite.region_enabled = true
	d_sprite.region_rect = sprite_2d.region_rect
	d.global_position = global_position
	d.dir = dir
	get_parent().add_child(d)
	queue_free()

func dealing_score(type : damage_type):
	if global.multiple_stamp >= 9:
		global.extra_life.emit()
		global.life += 1
		global.point += 8000
		var p = popup.instantiate()
		p.global_position = global_position
		p.text = "1 UP"
		get_parent().add_child(p)
	else:
		match type:
			damage_type.stamp:
				global.point += score_list[global.multiple_stamp]
				var p = popup.instantiate()
				p.global_position = global_position
				p.text = str(score_list[global.multiple_stamp])
				get_parent().add_child(p)
				global.multiple_stamp += 1
			damage_type.fire:
				global.point += score_list[1]
				var p = popup.instantiate()
				p.global_position = global_position
				p.text = str(score_list[1])
				get_parent().add_child(p)
			damage_type.deadzone:
				pass

func _on_player_checker_body_entered(body: Node2D) -> void:
	if global.invincible:
		hurt.emit(damage_type.deadzone)
	elif body.is_on_floor() and not dying:
		global.player_hurt.emit()
	else:
		hurt.emit(damage_type.stamp)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	set_process(false)


func _on_dead_checker_area_entered(area: Area2D) -> void:
	hurt.emit(damage_type.deadzone)
