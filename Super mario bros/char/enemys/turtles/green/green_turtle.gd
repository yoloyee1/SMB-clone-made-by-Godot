extends Enemy

@export var shell : PackedScene

func _process(delta: float) -> void:
	move_foward(delta)

func dealing_hurt(type : damage_type = damage_type.fire):
	dealing_score(type)
	match type:
		damage_type.stamp:
			var s = shell.instantiate()
			s.global_position = global_position
			s.dir = dir
			get_parent().add_child(s)
			queue_free()
		damage_type.fire:
			dealing_die()
		_:
			queue_free()
