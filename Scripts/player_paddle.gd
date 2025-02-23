extends CharacterBody2D


''' ---------- VARIABLES ---------- '''

# Player Stats
var speed = 150


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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

	position += velocity * delta * speed


''' ---------- CUSTOM FUNCTIONS ---------- '''


''' ---------- SIGNAL FUCNTIONS ---------- '''
