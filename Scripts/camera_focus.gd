extends Node2D


var speed = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		position.x += speed
	if Input.is_action_pressed("move_left"):
		position.x -= speed
	if Input.is_action_pressed("secondary_action"):
		position.y += speed
	if Input.is_action_pressed("primary_action"):
		position.y -= speed
		
	if Input.is_action_pressed("right_click"):
		global_position = get_global_mouse_position()


func _input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and $PhantomCamera2D.zoom < Vector2(1.4, 1.4):
			$PhantomCamera2D.zoom += Vector2(0.1, 0.1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and $PhantomCamera2D.zoom > Vector2(0.6, 0.6):
			$PhantomCamera2D.zoom -= Vector2(0.1, 0.1)
		
