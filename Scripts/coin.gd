extends CharacterBody2D


''' ---------- VARIABLES ---------- '''

# Scenes
var rng = RandomNumberGenerator.new()


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2(rng.randi_range(-100, 100), -100)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += 300 * delta
	rotation += 1 * (velocity.x/300)
	
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		var collision_target = collision_info.get_collider()
		match collision_target.get_name():
			"PlayerPaddle":
				Global.coins += 1
				collision_target.get_parent().get_node("ParticleManager").spawn_coin_grabbed_particle(position)
				queue_free()
				
			"KillFloor":
				queue_free()
				
			"Walls":
				velocity = velocity.bounce(collision_info.get_normal())


''' ---------- SIGNAL FUNCTIONS ---------- '''
