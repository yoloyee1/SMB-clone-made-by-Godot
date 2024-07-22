extends Sprite2D

enum action_type {
	crouch,
	walk,
	jump,
}

@export var pose := action_type.crouch
	
func _process(delta: float) -> void:
	match pose:
		action_type.crouch:
			if global.size == 1:
				frame = 0
			elif global.size == 2:
				frame = 14
			elif global.size == 3:
				frame = 23
