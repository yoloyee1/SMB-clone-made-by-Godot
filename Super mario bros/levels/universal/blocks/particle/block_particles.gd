extends GPUParticles2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	match global.style:
		global.world_style.normal:
			pass
		global.world_style.underground:
			material.set_shader_parameter("onoff", 1.0)
			gpu_particles_2d.material.set_shader_parameter("onoff", 1.0)
		
	emitting = true
	gpu_particles_2d.emitting = true


func _on_finished() -> void:
	queue_free()
