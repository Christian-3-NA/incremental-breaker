extends CharacterBody2D


''' ---------- VARIABLES ---------- '''

# Scenes
var rng = RandomNumberGenerator.new()
var paddle_reference = Global.player_paddle


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2(rng.randi_range(-100, 100), -100)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# If Magnet Powerup is active then get funky with it, otherwise just fall
	if paddle_reference.magnet_active:
		if global_position.distance_to(paddle_reference.global_position) < 100:
			global_position = global_position.move_toward(paddle_reference.global_position, 10)
		else:
			velocity.x += 10 * min(max(paddle_reference.global_position.x - global_position.x, -1), 1)
			velocity.y += 10 * min(max(paddle_reference.global_position.y - global_position.y, -1), 1)
			velocity.x = min(max(velocity.x, -200), 200)
			velocity.y = min(max(velocity.y, -200), 200)
	else:
		velocity.y += 300 * delta
	rotation += 1 * (velocity.x/300)
	
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		var collision_target = collision_info.get_collider()
		match collision_target.get_name():
			"PlayerPaddle":
				AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.COIN_GRAB)
				Global.coins += 1
				collision_target.get_parent().get_node("ParticleManager").spawn_coin_grabbed_particle(position)
				queue_free()
				
			"KillFloor":
				queue_free()
				
			"Walls":
				velocity = velocity.bounce(collision_info.get_normal())


''' ---------- SIGNAL FUNCTIONS ---------- '''
