extends Node2D


''' ---------- VARIABLES ---------- '''

# Scenes
var paddle_scene = preload("res://Scenes/player_paddle.tscn")
var big_brick_sprite = preload("res://Assets/big_blocks.png")
var brick_scene = preload("res://Scenes/block.tscn")
var all_bricks = []
var ball_ref = []
var paddle_ref

var game_timer = Global.get_node("GameTimer")
var game_time = Global.max_game_time
var rng = RandomNumberGenerator.new()

var pattern_list_size = Global.image_pattern_ref_list.size() - 1 # Randi_range is inclusive for some reason

# Spawning Parameters
var margin = 8
var default_block_lower_timer = 1
var spawn_wave_at_height = 0

var powerup_spawn_names = Global.all_powerup_names
var powerup_spawn_weights = Global.all_powerup_spawn_weights
var spawn_none_chance = 1.0

# Gameplay Variables
var current_height = 0
var current_nets = Global.starting_nets


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.play_scene_transition(false)
	
	# Powerup Spawning
	for chance in powerup_spawn_weights:
		spawn_none_chance -= chance
	powerup_spawn_weights.append(spawn_none_chance)
	powerup_spawn_names.append("none")
	
	$BlockLowerTimer.start()
	insert_pattern(rng.randi_range(0, pattern_list_size))
	
	# Configure game timer
	game_timer.wait_time = Global.max_game_time
	game_timer.start()
	game_timer.timeout.connect(end_level)
	
	# Spawn Player
	var new_paddle = paddle_scene.instantiate()
	new_paddle.position = Vector2(160, 313)
	add_child(new_paddle)
	paddle_ref = new_paddle

	# Enable the safety net
	current_nets = Global.starting_nets
	if current_nets > 0:
		$SafetyNet.process_mode = Node.PROCESS_MODE_INHERIT
		$SafetyNet.enable_net()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if $BlockLowerTimer.is_stopped():
		if height_check():
			lower_bricks($BlockLowerTimer.wait_time)
			$BlockLowerTimer.wait_time = max(0.01, $BlockLowerTimer.wait_time * 0.7)
		else:
			$BlockLowerTimer.wait_time = default_block_lower_timer
		if pattern_check():
			insert_pattern(rng.randi_range(0, pattern_list_size))
	
	# Time Display
	$LeftPanel/TimeDisplay.text = "%d:%02d" % [
		floor(game_timer.time_left / 60),
		int(game_timer.time_left) % 60,
	]
	
	# Height Display
	$RightPanel/HeightDisplay.text = str(current_height)
	
	# Spawn nets with powerups
	current_nets = Global.safety_nets
	if current_nets > 0:
		$SafetyNet.process_mode = Node.PROCESS_MODE_INHERIT
		$SafetyNet.enable_net()


''' ---------- CUSTOM FUNCTIONS ---------- '''

func end_level():
	Global.play_scene_transition(true)
	await Global.get_node("SceneTransitionPlayer").animation_finished
	get_tree().change_scene_to_file("res://Scenes/shop_screen.tscn")


# Checks if there are any bricks on the lowest layer, if not then returns true
func height_check():
	$BlockLowerTimer.start() # Keeps all the blocks from falling instantly
	var should_lower = true
	
	for area in $HeightDetector.get_overlapping_areas():
		if area.is_in_group("block_areas"):
			should_lower = false

	return should_lower


func lower_bricks(time):
	current_height += 1
	
	for brick in all_bricks:
		if time > 0.05:
			var tween = create_tween()
			tween.set_ease(0)
			tween.set_trans(2)
			tween.tween_property(brick, "position", Vector2(brick.position + Vector2(0, 16)), time/1.3)
		else:
			brick.position += Vector2(0, 16)


func insert_pattern(pattern_id):
	var pattern_height = Global.image_pattern_ref_list[pattern_id].get_image().get_height()
	spawn_wave_at_height += pattern_height
	
	for space in Global.pattern_dict[pattern_id]:
		match space[0]:
			0:
				pass
			1:
				spawn_block(space[1][0], space[1][1] - pattern_height, 1)
			2:
				spawn_block(space[1][0], space[1][1] - pattern_height, 2)


func pattern_check():
	var should_spawn_pattern = true
	
	if current_height < spawn_wave_at_height:
		should_spawn_pattern = false

	return should_spawn_pattern


func spawn_block(c, r, size):
	var new_brick = brick_scene.instantiate()
	all_bricks.append(new_brick)
	new_brick.brick_destroyed.connect(on_brick_broken)

	var space_for_big = false
	if size == 2:
		new_brick.health = 2
		new_brick.scale *= 2
		new_brick.get_node("BlockSprite").texture = big_brick_sprite
		new_brick.get_node("BlockSprite").scale *= 0.5
		new_brick.get_node("CracksSprite").scale *= 0.5
		
	var next_powerup_spawn = powerup_spawn_names[rng.rand_weighted(powerup_spawn_weights)]
	if next_powerup_spawn != "none":
		new_brick.spawn_with_powerup(next_powerup_spawn)
		
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
