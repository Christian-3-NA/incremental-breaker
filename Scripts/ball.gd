extends CharacterBody2D


''' ---------- VARIABLES ---------- '''

# Player Stats
var speed = 100

# State Manager
var state = ""
var possible_states = [
	"idle",
	"caught",
	"bouncing"
]


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = possible_states[2] # Bouncing
	velocity = Vector2(speed * -1, speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		"idle":
			pass
			
		"caught":
			pass
			
		"bouncing":
			# Checks for collision and returns the KinematicCollision2D
			var collision_info = move_and_collide(velocity * delta)
			
			if collision_info: # Happens if the ball collides
				var collision_target = collision_info.get_collider() # Stores the subject of the collision
				
				velocity = velocity.bounce(collision_info.get_normal())
					
				if collision_target.has_method("hit"):
					collision_target.hit()
