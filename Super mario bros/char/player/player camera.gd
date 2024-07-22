extends Camera2D

func _ready() -> void:
	global.camera_limit_change.connect(change)
	
func change(limit : Vector2, type : global.camera_type):
	match type:
		global.camera_type.move_horizontal:
			limit_bottom = limit.y + 120
			limit_top = limit.y - 120
			limit_right = 1000000
			limit_left = 0
		global.camera_type.single_screen:
			limit_bottom = limit.y + 120
			limit_top = limit.y - 120
			limit_right = limit.x + 128
			limit_left = limit.x - 128
