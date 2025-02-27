extends Node2D


''' ---------- VARIABLES ---------- '''

# Scenes
var paddle_scene = preload("res://Scenes/player_paddle.tscn")
var big_brick_sprite = preload("res://Assets/big_blocks.png")
var brick_scene = preload("res://Scenes/block.tscn")
var game_timer = Global.get_node("GameTimer")
var all_bricks = []
var rng = RandomNumberGenerator.new()
var paddle_ref
var ball_ref = []
var game_time = Global.max_game_time

# Spawning Parameters
var columns = 20
var rows = 1
var margin = 8
var occupied_spots = []

# Gameplay Variables
var minimum_brick_height = 16 * 7 - 8


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	insert_pattern()
	
	$BlockLowerTimer.start()
	setup_level()
	
	# Configure game timer
	game_timer.wait_time = Global.max_game_time
	game_timer.start()
	game_timer.timeout.connect(end_level)
	
	# Spawn Player
	var new_paddle = paddle_scene.instantiate()
	new_paddle.position = Vector2(160, 313)
	add_child(new_paddle)
	paddle_ref = new_paddle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if $BlockLowerTimer.is_stopped():
		if height_check():
			lower_bricks()
			
	$LeftPanel/TimeDisplay.text = "%d:%02d" % [
		floor(game_timer.time_left / 60),
		int(game_timer.time_left) % 60,
	]
	
	
''' ---------- CUSTOM FUNCTIONS ---------- '''

func setup_level():
	for r in rows:
		for c in columns:
			spawn_blocks(c, r)


func end_level():
	get_tree().change_scene_to_file("res://Scenes/shop_screen.tscn")


# Checks if there are any bricks on the lowest layer, if not then returns true
func height_check():
	$BlockLowerTimer.start() # Keeps all the blocks from falling instantly
	var should_lower = true
	
	for area in $HeightDetector.get_overlapping_areas():
		if area.is_in_group("block_areas"):
			should_lower = false

	return should_lower
	
	
func lower_bricks():
	for brick in all_bricks:
		brick.position.y += 16
	for brick in occupied_spots:
		brick[1] += 1
	spawn_next_row()


func spawn_next_row():
	for c in columns:
		spawn_blocks(c, 0)


func insert_pattern():
	for space in Global.pattern_dict[0]:
		occupied_spots.append([space[0], space[1]-10])


func spawn_blocks(c, r):
	if [c, r] not in occupied_spots:
		var new_brick = brick_scene.instantiate()
		all_bricks.append(new_brick)
		occupied_spots.append([c, r])
		new_brick.brick_destroyed.connect(on_brick_broken)
		
		# Make some blocks larger
		var space_for_big = false
		if ([c+1, r] not in occupied_spots) and ([c, r-1] not in occupied_spots) and ([c+1, r-1] not in occupied_spots) and (c < 19):
			space_for_big = true
		if rng.randi() % 2 == 0 and space_for_big:
			new_brick.scale *= 2
			new_brick.get_node("BlockSprite").texture = big_brick_sprite
			new_brick.get_node("BlockSprite").scale *= 0.5
			occupied_spots.append_array([[c+1, r], [c, r-1], [c+1, r-1]])
			
		new_brick.get_node("BlockSprite").frame = rng.randi_range(0, 3)
		new_brick.position = Vector2(margin + (16 * c) + (8 * (new_brick.scale.x - 1)), margin + (16 * r) - (8 * (new_brick.scale.y - 1)))
		add_child(new_brick)


''' ---------- SIGNAL FUNCTIONS ---------- '''

func on_brick_broken(brick):
	all_bricks.erase(brick)


func on_ball_destroyed(ball):
	ball_ref.erase(ball)
	if paddle_ref.held_ball_count == 0 and ball_ref.is_empty():
		end_level()
