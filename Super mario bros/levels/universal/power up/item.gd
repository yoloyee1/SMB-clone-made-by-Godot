extends CharacterBody2D
class_name Item

enum type {
	power,
	life,
	star,
}

signal bounce(body : Node2D)

const BOUNCE_VELOCITY = -200.0
const STAR_BOUNCE = -400.0

@export var popup : PackedScene
@export var what_type_is_it : type
@export var need_moving := true
var direction := 1:
	set(v):
		scale.x = v
		direction = v
var speed := 50
var point := 1000
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var area_2d: Area2D = $Area2D
@onready var wall_checker: Area2D = $"wall checker"

func _ready() -> void:
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	set_physics_process(false)
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -16), 1.0)
	await tween.finished
	if need_moving:
		set_physics_process(true)
		bounce.connect(on_bounce)
		wall_checker.body_entered.connect(_on_wall_checker_body_entered)
	if what_type_is_it == type.star:
		set_physics_process(true)
		wall_checker.body_entered.connect(_on_wall_checker_body_entered)
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	elif what_type_is_it == type.star:
		velocity.y = STAR_BOUNCE
	velocity.x = direction * speed
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	match what_type_is_it:
		type.power:
			global.power_up.emit()
			var p = popup.instantiate()
			p.global_position = global_position
			p.text = str(point)
			get_parent().add_child(p)
		type.life:
			global.extra_life.emit()
			var p = popup.instantiate()
			p.global_position = global_position
			p.text = "1 UP"
			global.life += 1
			get_parent().add_child(p)
		type.star:
			global.get_star.emit()
			var p = popup.instantiate()
			p.global_position = global_position
			p.text = str(point)
			get_parent().add_child(p)
	global.point += point
	queue_free()


func on_bounce(body: Node2D) -> void:
	if need_moving and is_on_floor():
		if body.global_position.x < global_position.x:
			velocity.y = BOUNCE_VELOCITY
		else:
			direction *= -1
			velocity.y = BOUNCE_VELOCITY


func _on_wall_checker_body_entered(body: Node2D) -> void:
	direction *= -1
