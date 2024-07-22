extends Enemy

enum color {
	RED,
	GREEN
}

@onready var prevent_bug_timer: Timer = $"prevent bug Timer"

func _process(delta: float) -> void:
	move_foward(delta)

func dealing_hurt(type : damage_type = damage_type.fire):
	dealing_score(type)
	match type:
		damage_type.stamp:
			if is_processing():
				set_process(false)
			else:
				if global_position.x > global.player_position.x:
					dir = 1
				else:
					dir = -1
				set_process(true)
		damage_type.fire:
			dealing_die()
		_:
			queue_free()
			
			
func _on_player_checker_body_entered(body: Node2D) -> void:
	if body.is_on_floor() and is_processing():
		global.player_hurt.emit()
	elif prevent_bug_timer.time_left == 0:
		hurt.emit(damage_type.stamp)
	prevent_bug_timer.start()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_enemy_checker_body_entered(body: Node2D) -> void:
	if body != self:
		body.emit_signal("hurt")
