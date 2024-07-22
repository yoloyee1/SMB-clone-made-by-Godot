extends StaticBody2D

@export var has_item := false
@export var has_life := false
@export var has_star := false
@export var store_coin := 0
@export var point := 50
@export var coin : PackedScene
@export var mushroom : PackedScene
@export var flower : PackedScene
@export var one_up : PackedScene
@export var star : PackedScene
@export var particle : PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var coin_checker: Area2D = $"coin checker"

var item_on_top : Node2D
var enemy_on_top : Enemy

func _ready() -> void:
	change()
	global.change_style.connect(change)
	if visible == false:
		collision_shape_2d.one_way_collision = true
		collision_shape_2d.rotation_degrees = 180

func change():
	match global.style:
		global.world_style.normal:
			sprite_2d.material.set_shader_parameter("onoff", 0.0)
		global.world_style.underground:
			sprite_2d.material.set_shader_parameter("onoff", 1.0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	animation_player.play("bounce")
	if enemy_on_top != null:
		enemy_on_top.emit_signal("hurt")
	if item_on_top != null:
		item_on_top.bounce.emit(self)
	if coin_checker.has_overlapping_areas():
		coin_checker.get_overlapping_areas()[0].emit_signal("bounce")
	if body.global_position.y > global_position.y + 14:
		if has_item:
			if global.size == 1:
				var m = mushroom.instantiate()
				m.global_position = global_position
				get_parent().add_child(m)
			elif global.size >= 2:
				var f = flower.instantiate()
				f.global_position = global_position
				get_parent().add_child(f)
			sprite_2d.frame = 2
			has_item = false
			area_2d.set_deferred("monitoring", false)
		elif has_life:
			var l = one_up.instantiate()
			l.global_position = global_position
			get_parent().add_child(l)
			visible = true
			sprite_2d.frame = 2
			has_life = false
			area_2d.set_deferred("monitoring", false)
			collision_shape_2d.set_deferred("one_way_collision", false)
		elif has_star:
			var s = star.instantiate()
			s.global_position = global_position
			get_parent().add_child(s)
			sprite_2d.frame = 2
			has_star = false
			area_2d.set_deferred("monitoring", false)
		elif store_coin > 0:
			store_coin -= 1
			var c = coin.instantiate()
			c.is_from_block = true
			add_child(c)
			if store_coin == 0:
				sprite_2d.frame = 2
				has_item = false
				area_2d.set_deferred("monitoring", false)
		elif global.size >= 2:
			var p = particle.instantiate()
			p.global_position = global_position
			get_parent().add_child(p)
			global.point += point
			queue_free()


func _on_item_checker_body_entered(body: Node2D) -> void:
	item_on_top = body


func _on_item_checker_body_exited(body: Node2D) -> void:
	item_on_top = null


func _on_enemy_checker_body_entered(body: Node2D) -> void:
	enemy_on_top = body


func _on_enemy_checker_body_exited(body: Node2D) -> void:
	enemy_on_top = null
