extends CharacterBody2D

const BOUNCE_POWER := -120
const MOVE_SPEED := 200

var gravity := global.gravity
var dir := 1

@export var explosion : PackedScene

@onready var wall_checker: RayCast2D = $"wall checker"

func _ready() -> void:
	wall_checker.target_position = Vector2(6 * dir, 0)

func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = BOUNCE_POWER
	else:
		velocity.y += gravity * delta
	if wall_checker.is_colliding():
		burst()
	velocity.x = MOVE_SPEED * dir
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	body.emit_signal("hurt")
	burst()

func burst():
	var e = explosion.instantiate()
	e.global_position = global_position
	get_parent().add_child(e)
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
