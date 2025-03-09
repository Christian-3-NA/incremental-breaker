extends CharacterBody2D

# Scene Loading
var on_sprite = load("res://Assets/laser.png")
var off_sprite = load("res://Assets/laser_off.png")
var laser_beam_sprite = load("res://Assets/laser_beam.png")
@onready var game_manager_ref = get_parent().get_parent()


# Variables
var energy = 3
var max_energy = 3


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	
func _physics_process(delta: float) -> void:
	# Shrink the beams
	for child in game_manager_ref.get_children():
		if child is Line2D:
			if child.texture == laser_beam_sprite:
				child.width -= 1


''' ---------- CUSTOM FUNCTIONS ---------- '''

func fire_laser(parent):
	if energy > 0:
		energy -= 1
		
		# Raycast
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, -1000))
		query.exclude = [self, parent]
		var result = space_state.intersect_ray(query)
		if result:
			if result.collider.has_method("hit"):
				result.collider.hit("laser")
			if result.collider.has_method("shatter"):
				result.collider.shatter("laser")
		
			# Draws the laser
			var new_line = Line2D.new()
			new_line.add_point(global_position - game_manager_ref.position)
			new_line.add_point(result.position - game_manager_ref.position)
			
			new_line.texture = laser_beam_sprite
			new_line.texture_repeat = 2
			new_line.texture_mode = 1
			new_line.width = 6
			
			game_manager_ref.add_child(new_line)
				
				
		if energy == 0:
			$LaserSprite.texture = off_sprite


func charge():
	energy = max_energy
	$LaserSprite.texture = on_sprite
