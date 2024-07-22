extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var dir = 1
var gravity = global.gravity

func _ready() -> void:
	#play die sound here
	velocity.y = -300.0
	velocity.x = 50 * -dir

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
