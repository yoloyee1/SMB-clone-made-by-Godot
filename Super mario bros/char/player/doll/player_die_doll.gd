extends CharacterBody2D

var gravity = global.gravity
var start := false

func _process(delta: float) -> void:
	if not start:
		velocity.y = -300.0
		start = true
	else:
		velocity.y += gravity * delta
	move_and_slide()


func _on_timer_timeout() -> void:
	global.restart()
