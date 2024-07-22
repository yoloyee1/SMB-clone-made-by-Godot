extends Label

func _ready() -> void:
	position.x -= 8
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2.UP * 40, 0.3)
	await tween.finished
	queue_free()
