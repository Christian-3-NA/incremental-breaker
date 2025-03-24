extends Node2D


# Scenes
var block_broken_particle = preload("res://Particles/block_broken_particle.tscn")
var coin_grabbed_particle = preload("res://Particles/coin_grabbed_particle.tscn")
var block_disentigrate_particle = preload("res://Particles/block_disentigrate_particle.tscn")
var ball_shatter_particle = preload("res://Particles/ball_shatter_particle.tscn")

var blue_texture = preload("res://Assets/particles/block_broken_particle_blue.png")
var red_texture  = preload("res://Assets/particles/block_broken_particle_red.png")
var green_texture = preload("res://Assets/particles/block_broken_particle_green.png")
var grey_texture = preload("res://Assets/particles/block_broken_particle.png")


func spawn_block_broken_particle(spawn_position, frame, new_scale):
	var new_particle = block_broken_particle.instantiate()
	new_particle.position = spawn_position
	new_particle.amount = randi_range(1, 3)
	new_particle.process_material.scale = new_scale
	match frame:
		0:
			new_particle.texture = blue_texture
		1:
			new_particle.texture = red_texture
		2:
			new_particle.texture = green_texture
		3:
			new_particle.texture = grey_texture
	add_child(new_particle)


func spawn_block_disentigrate_particle(spawn_position, new_scale):
	var new_particle = block_disentigrate_particle.instantiate()
	if new_scale.x == 2:
		new_particle.process_material.emission_box_extents *= 2
		new_particle.amount *= 2
	new_particle.position = spawn_position
	add_child(new_particle)


func spawn_coin_grabbed_particle(spawn_position):
	var new_particle = coin_grabbed_particle.instantiate()
	new_particle.position = spawn_position
	add_child(new_particle)


func spawn_ball_shatter_particle(spawn_position):
	var new_particle = ball_shatter_particle.instantiate()
	new_particle.position = spawn_position
	add_child(new_particle)
