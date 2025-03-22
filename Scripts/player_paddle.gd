extends CharacterBody2D


''' ---------- VARIABLES ---------- '''

# Scenes
var ball_scene = preload("res://Scenes/ball.tscn")
var held_ball
var laser_scene = preload("res://Scenes/laser.tscn")
var laser_unlocked = Global.laser_unlocked
var laser_ref
@onready var coin_magnet_timer = $"../CoinMagnetTimer"
@onready var animator_ref = $CoinMagnetParticle.get_node("FadeIn")


# Player Stats
var speed = 300
var paddle_size = Global.paddle_size
var ball_count = Global.ball_count
var held_ball_count = ball_count
var magnet_active = false

# Function Variables
var accel_percent = 0
var side_collision = 0 # -1 = left, 0 = none, 1 = right


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Corrects the paddle size
	var new_hitbox = RectangleShape2D.new()
	new_hitbox.size = Vector2(paddle_size, 6)
	$PaddleCollision.set_shape(new_hitbox)
	$BackupPaddleCollision.set_shape(new_hitbox) # Makes side-bumps lenient
	$NinePatchRect.size.x = Global.paddle_size
	$NinePatchRect.position = $NinePatchRect.size * -0.5
		
	spawn_next_ball()
	
	# Spawns laser
	if laser_unlocked:
		var new_laser = laser_scene.instantiate()
		new_laser.position += Vector2(0, -6)
		add_child(new_laser)
		laser_ref = new_laser


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
	
	# Keeps paddle in the game zone, and checks which wall its hitting
	side_collision = 0
	if position.x < $PaddleCollision.shape.get_rect().size.x/2:
		side_collision = -1
		position.x = max(position.x, $PaddleCollision.shape.get_rect().size.x/2)
	if position.x > $"../MidPanel".size.x - $PaddleCollision.shape.get_rect().size.x/2:
		side_collision = 1
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
	
	# Laser. pew pew!
	if laser_ref:
		if Input.is_action_just_pressed("secondary_action"):
			laser_ref.fire_laser(self)
		
		# Move the laser along the paddle when close to walls
		if side_collision != 0:
			laser_ref.global_position = laser_ref.global_position.lerp(global_position + Vector2((paddle_size/2 - 16) * side_collision, -6), delta * 30)
		else:
			laser_ref.global_position = laser_ref.global_position.lerp(global_position + Vector2(0, -6), delta * 30)
		
	# Magnet Particles
	if coin_magnet_timer.time_left:
		if $CoinMagnetParticle.modulate == Color(1.0, 1.0, 1.0, 0.0):
			animator_ref.play("FadeInOut")
		elif animator_ref.get_playing_speed() < 0:
			animator_ref.pause()
			animator_ref.play("FadeInOut", -1, 1.0)
	elif $CoinMagnetParticle.modulate != Color(1.0, 1.0, 1.0, 0.0):
		$CoinMagnetParticle.get_node("FadeIn").play_backwards("FadeInOut")


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


func charge():
	if laser_ref:
		laser_ref.charge()


''' ---------- SIGNAL FUCNTIONS ---------- '''
