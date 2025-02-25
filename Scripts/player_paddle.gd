extends CharacterBody2D


''' ---------- VARIABLES ---------- '''

# Scenes
var ball_scene = preload("res://Scenes/ball.tscn")
var held_ball

# Player Stats
var speed = 300
var paddle_size = Global.paddle_size
var ball_count = Global.ball_count
var held_ball_count = ball_count

# Function Varaibles
var accel_percent = 0


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_hitbox = RectangleShape2D.new()
	new_hitbox.size = Vector2(paddle_size, 6)
	$PaddleCollision.set_shape(new_hitbox)
	$NinePatchRect.size.x = Global.paddle_size
	$NinePatchRect.position = $NinePatchRect.size * -0.5
		
	spawn_next_ball()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_right"):
		velocity.x = 1
	if Input.is_action_just_pressed("move_left"):
		velocity.x = -1
		
	# Direction overwriting
	if Input.is_action_just_released("move_right") and velocity.x == 1:
		velocity.x = 0
		if Input.is_action_pressed("move_left"):
			velocity.x = -1
	if Input.is_action_just_released("move_left") and velocity.x == -1:
		velocity.x = 0
		if Input.is_action_pressed("move_right"):
			velocity.x = 1

	# Movement acceleration code, minimal impact intended for precision movement only
	if velocity == Vector2.ZERO:
		accel_percent -= .1
		accel_percent = max(accel_percent, 0)
	else:
		accel_percent += .1
		accel_percent = min(accel_percent, 1)
			
	position += velocity * delta * speed * accel_percent
	position = snapped(position, Vector2(1, 1))
	
	# Keeps paddle in the game zone
	position.x = max(position.x, $PaddleCollision.shape.get_rect().size.x/2)
	position.x = min(position.x, $"../MidPanel".size.x - $PaddleCollision.shape.get_rect().size.x/2)
	
	# Keeps next ball above player
	if held_ball:
		held_ball.position = position + Vector2(0, -16)
		
	if Input.is_action_just_pressed("primary_action") and held_ball_count > 0:
		held_ball.state = held_ball.BallState.BOUNCING
		held_ball.velocity = Vector2(0 + velocity.x, -1).normalized() * held_ball.speed
		held_ball.get_node("BallCollision").set_deferred("disabled", false)
		held_ball = null
		held_ball_count -= 1
		if held_ball_count > 0:
			spawn_next_ball()
	

''' ---------- CUSTOM FUNCTIONS ---------- '''

func spawn_next_ball():
	var new_ball = ball_scene.instantiate()
	new_ball.position = position + Vector2(0, -16)
	get_parent().add_child(new_ball)
	get_parent().ball_ref.append(new_ball)
	new_ball.get_node("BallCollision").set_deferred("disabled", true)
	new_ball.state = new_ball.BallState.HELD
	new_ball.ball_destroyed.connect(get_parent().on_ball_destroyed)
	held_ball = new_ball
	

''' ---------- SIGNAL FUCNTIONS ---------- '''
