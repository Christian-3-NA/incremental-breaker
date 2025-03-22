extends Node2D


''' ---------- VARIABLES ---------- '''

var speed = 10
var is_dragging = false
var drag_start_mouse_position 
var drag_start_focus_position
@onready var move_bounds_ref = $"../ShopBounds/ShopBoundsCollision"


''' ---------- DEFAULT FUNCTIONS ---------- '''

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
		
	if !is_dragging and Input.is_action_just_pressed("right_click"):
		drag_start_mouse_position = get_viewport().get_mouse_position()
		drag_start_focus_position = position
		is_dragging = true
		
	if is_dragging and Input.is_action_just_released("right_click"):
		is_dragging = false
		
	if is_dragging:
		var move_vector = get_viewport().get_mouse_position() - drag_start_mouse_position
		position = drag_start_focus_position - move_vector * 1/$PhantomCamera2D.zoom.x
		
	global_position = global_position.clamp(move_bounds_ref.global_position - move_bounds_ref.shape.size/2, move_bounds_ref.global_position + move_bounds_ref.shape.size/2)


func _input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and $PhantomCamera2D.zoom < Vector2(1.4, 1.4):
			$PhantomCamera2D.zoom += Vector2(0.1, 0.1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and $PhantomCamera2D.zoom > Vector2(0.6, 0.6):
			$PhantomCamera2D.zoom -= Vector2(0.1, 0.1)
