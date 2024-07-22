extends Area2D
class_name Deadzone

func _on_body_entered(body: Node2D) -> void:
	global.player_die.emit()
