extends CharacterBody2D


# Scenes
var net_hit_particle = load("res://Particles/net_hit_particle.tscn")


func enable_net():
	show()
	spawn_particles(0)
	
func disable_net():
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED

func hit(source):
	get_parent().current_nets -= 1
	spawn_particles(1)
	if get_parent().current_nets <= 0:
		disable_net()

func spawn_particles(type):
	match type:
		0:
			var new_hit_particle = net_hit_particle.instantiate()
			var new_hit_particle2 = net_hit_particle.instantiate()
			new_hit_particle2.process_material.direction = Vector3(0.0, -1.0, 0.0)
			new_hit_particle.position = position
			new_hit_particle2.position = position
			$"../ParticleManager".add_child(new_hit_particle)
			$"../ParticleManager".add_child(new_hit_particle2)
		
		1:
			var new_hit_particle = net_hit_particle.instantiate()
			new_hit_particle.position = position
			$"../ParticleManager".add_child(new_hit_particle)
		
		2:
			var new_hit_particle = net_hit_particle.instantiate()
			new_hit_particle.process_material.spread = 360
			new_hit_particle.process_material.initial_velocity_min = 20.0
			new_hit_particle.process_material.initial_velocity_max = 20.0
			new_hit_particle.position = position
			$"../ParticleManager".add_child(new_hit_particle)
			
