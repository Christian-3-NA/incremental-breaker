extends CharacterBody2D


''' ---------- VARIABLES ---------- '''

# Signals
signal ball_destroyed

# Player Stats
var speed = Global.ball_speed
var time_since_hit = 0
var going_fast = false
var going_slow = false
var combo = 0
var stored_explosions = 0
var speed_up_time = 200

# State Manager
@onready var state = BallState.IDLE
enum BallState {
	IDLE,
	HELD,
	BOUNCING
}

# Scenes
var popup_scene = preload("res://Scenes/number_popup.tscn")
var explosion_scene = preload("res://Scenes/explosion.tscn")
var last_collision


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		BallState.IDLE:
			pass
			
		BallState.HELD:
			pass
			
		BallState.BOUNCING:
			# Speeds the ball up if it hasn't been hit by the paddle in a long time
			time_since_hit += 1
			if time_since_hit % speed_up_time == 0 and not time_since_hit == speed_up_time:
				AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BALL_SPEED_UP, min(0.0, float(time_since_hit/speed_up_time)/10 - 0.6))
				velocity *= 1.3
				going_fast = true
				if Global.do_speed_explosion:
					stored_explosions += 1
			
			# Going slow is currently only if slowing field is active
			if velocity.y <= 0 and going_slow: 
				velocity = velocity.normalized() * speed
				going_slow = false
			if going_slow:
				var next_velocity = (velocity.normalized() * speed/2)
				if abs(next_velocity) > abs(velocity * 0.9):
					velocity = next_velocity
				else:
					velocity *= 0.9
			
			# Particles
			if going_fast:
				$GPUParticles2D.emitting = true
			else:
				$GPUParticles2D.emitting = false
			
			# Checks for collision and returns the KinematicCollision2D
			var collision_info = move_and_collide(velocity * delta)
			
			if collision_info: # Happens if the ball collides
				var collision_target = collision_info.get_collider() # Stores the subject of the collision
				last_collision = collision_target
				
				match collision_target.get_name():
					"PlayerPaddle":
						# Biased toward redirecting the ball upward so it doesn't bounce left and right forever
						velocity = ( (position - collision_target.position) * Vector2(1, 2) ).normalized()
						velocity = velocity * speed
						if position.y >= collision_target.position.y:
							velocity.y *= -1
						time_since_hit = 0
						going_fast = false
						going_slow = false
						stored_explosions = 0
						
						# Charge Equipment
						collision_target.charge()
						
						# Lose bounce combo
						if Global.do_combo_time:
							collision_target.get_parent().modify_time(combo/3, 1)
						combo = 0
						
						AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BALL_PADDLE_BOUNCE)
						
					"KillFloor":
						shatter("bottom")
						
					_:
						if collision_target.has_method("shatter"):
							AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BALL_BALL_BOUNCE)
							collision_target.velocity = (collision_target.velocity.normalized() + (collision_target.global_position - global_position).normalized()).normalized() * collision_target.speed
							velocity = (velocity.normalized() + (global_position - collision_target.global_position).normalized()).normalized() * speed
							for i in range(1, floor(time_since_hit/speed_up_time)):
								velocity *= 1.3
						
						elif collision_info.get_normal().dot(velocity.normalized()) <= 0.0:
							velocity = velocity.bounce(collision_info.get_normal())
						
						if collision_target.has_method("hit"):
							# Sound here for blocks and barrier
							AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BALL_BLOCK_BOUNCE)
							collision_target.hit("ball")
							
						if collision_target.is_in_group("blocks"):
							if stored_explosions > 0:
								spawn_explosion(2) # Placeholder for explosion scaling
								stored_explosions -= 1
							combo += 1
							if combo % 5 == 0:
								combo_popup(combo)
						
						if collision_target.get_name() == "Walls":
							AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BALL_WALL_BOUNCE)


''' ---------- CUSTOM FUNCTIONS ---------- '''

func shatter(source):
	match source:
		"bottom":
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BALL_FALL)
		"laser":
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BALL_EXPLOSION)
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.CRUMBLING_BLOCK_CRASH)
	ball_destroyed.emit(self, source)
	queue_free()


func combo_popup(value):
	var new_popup = popup_scene.instantiate()
	new_popup.text = str(value)
	new_popup.position = position - new_popup.size/2
	get_parent().add_child(new_popup)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(new_popup, "position:y", new_popup.position.y - 24, 1)


func spawn_explosion(size):
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BALL_EXPLOSION)
	var new_explosion = explosion_scene.instantiate()
	new_explosion.scale = Vector2(0, 0)
	new_explosion.position = position
	new_explosion.expand(size)
	get_parent().add_child(new_explosion)


func slow_down():
	time_since_hit = 0
	going_fast = false
	going_slow = true
