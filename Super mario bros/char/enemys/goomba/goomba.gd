extends Enemy

func _process(delta: float) -> void:
	move_foward(delta)

func dealing_hurt(type : damage_type = damage_type.fire):
	dealing_score(type)
	match type:
		damage_type.stamp:
			animation_player.play("die")
			collision_shape_2d.set_deferred("disabled", true)
			player_checker.set_deferred("monitoring", false)
			set_process(false)
			dying = true
		damage_type.fire:
			dealing_die()
			queue_free()
		_:
			queue_free()
