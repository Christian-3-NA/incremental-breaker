extends CharacterBody2D


''' ---------- VARIABLES ---------- '''

# Signals
signal ball_destroyed

# Player Stats
var speed = Global.ball_speed
var time_since_hit = 0
var going_fast = false

# State Manager
@onready var state = BallState.IDLE
enum BallState {
	IDLE,
	HELD,
	BOUNCING
}


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
			if time_since_hit % 200 == 0 and not time_since_hit == 200:
				velocity *= 1.3
				going_fast = true
			
			# Particles
			if going_fast:
				$GPUParticles2D.emitting = true
			else:
				$GPUParticles2D.emitting = false
			
			# Checks for collision and returns the KinematicCollision2D
			var collision_info = move_and_collide(velocity * delta)
			
			if collision_info: # Happens if the ball collides
				var collision_target = collision_info.get_collider() # Stores the subject of the collision
				
				match collision_target.get_name():
					"PlayerPaddle":
						# Biased toward redirecting the ball upward so it doesn't bounce left and right forever
						velocity = ( (position - collision_target.position) * Vector2(1, 2) ).normalized()
						velocity = velocity * speed
						if position.y >= collision_target.position.y:
							velocity.y *= -1
						time_since_hit = 0
						going_fast = false
						
						# Charge Equipment
						collision_target.charge()
						
					"KillFloor":
						shatter()
						
					_:
						if collision_info.get_normal().dot(velocity.normalized()) <= 0.0:
							velocity = velocity.bounce(collision_info.get_normal())
						
						if collision_target.has_method("hit"):
							collision_target.hit()


''' ---------- DEFAULT FUNCTIONS ---------- '''

func shatter():
	ball_destroyed.emit(self)
	queue_free()
