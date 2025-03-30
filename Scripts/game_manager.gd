extends Node2D


''' ---------- VARIABLES ---------- '''

# Scenes
var paddle_scene = preload("res://Scenes/player_paddle.tscn")
var big_brick_sprite = preload("res://Assets/big_blocks.png")
var ghost_brick_sprite = preload("res://Assets/ghost_blocks.png")
var crumbling_brick_sprite = preload("res://Assets/crumbling_block.png")
var small_cracks_sprite = preload("res://Assets/small_cracks.png")
var brick_scene = preload("res://Scenes/block.tscn")
var all_bricks = []
var ball_ref = []
var paddle_ref

var game_timer = Global.get_node("GameTimer")
var game_time = Global.max_game_time
var rng = RandomNumberGenerator.new()
@onready var coin_magnet_timer = $CoinMagnetTimer

var pattern_list_size = Global.image_pattern_ref_list.size() - 1 # Randi_range is inclusive for some reason

# Spawning Parameters
var margin = 8
var default_block_lower_timer = 1
var spawn_wave_at_height = 0

var powerup_spawn_names = [
	Global.spawn_extra_ball_name, 
	Global.spawn_safety_net_name, 
	Global.spawm_slowing_field_name, 
	Global.spawn_coin_magnet_name
]
var powerup_spawn_weights = [
	Global.spawn_extra_ball_chance, 
	Global.spawn_safety_net_chance, 
	Global.spawm_slowing_field_chance, 
	Global.spawn_coin_magnet_chance
]

var spawn_none_chance = 1.0

# Gameplay Variables
var current_height = 0
var current_nets = Global.starting_nets


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.play_scene_transition(false, 1)
	
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
	game_timer.paused = true
	game_timer.timeout.connect(end_level)
	$LeftPanel/ManaTimeBar.max_value = Global.max_game_time
	
	# Spawn Player
	var new_paddle = paddle_scene.instantiate()
	new_paddle.position = Vector2(160, 313)
	add_child(new_paddle)
	paddle_ref = new_paddle
	Global.player_paddle = paddle_ref

	# Enable the safety net
	if current_nets > 0 and $SafetyNet.visible == false:
		$SafetyNet.process_mode = Node.PROCESS_MODE_INHERIT
		$SafetyNet.enable_net()
	# Change net strength display
	$"SafetyNet/NetPowerSprite".modulate = Color(1.0, 1.0, 1.0, min(1.0, (current_nets-1)/10))
	
	# Configure Height Bar
	$RightPanel/HeightBar.max_value = Global.goal_height
	
	#Configure Powerups	
	$LeftPanel/SlowingFieldBar.max_value = Global.max_slowing_field_time
	coin_magnet_timer.wait_time = Global.max_coin_magnet_time
	coin_magnet_timer.timeout.connect(end_coin_magnet)
	$LeftPanel/CoinMagnetBar.max_value = Global.max_coin_magnet_time
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if $BlockLowerTimer.is_stopped():
		if height_check():
			lower_bricks($BlockLowerTimer.wait_time)
			if current_height >= Global.goal_height:
				win_level()
			$BlockLowerTimer.wait_time = max(0.01, $BlockLowerTimer.wait_time * 0.7)
		else:
			$BlockLowerTimer.wait_time = default_block_lower_timer
			if game_timer.paused:
				game_timer.paused = false
		if pattern_check():
			insert_pattern(rng.randi_range(0, pattern_list_size))
	
	# Time Display
#	$LeftPanel/TimeDisplay.text = "%d:%02d" % [
#		floor(game_timer.time_left / 60),
#		int(game_timer.time_left) % 60,
#	]
	$LeftPanel/ManaTimeBar.value = game_timer.time_left
	
	# Height Display
	$RightPanel/HeightDisplay.text = str(current_height) + "m / " + str(Global.goal_height) + "m"
	$RightPanel/HeightBar.value = current_height
	
	# Powerup Displays
	$LeftPanel/SlowingFieldBar.value = $SlowingField/SlowingFieldTimer.time_left
	$LeftPanel/CoinMagnetBar.value = coin_magnet_timer.time_left
	
	# Spawn nets with powerups
	if current_nets > 0 and $SafetyNet.visible == false:
		$SafetyNet.process_mode = Node.PROCESS_MODE_INHERIT
		$SafetyNet.enable_net()
	# Change net strength display
	$"SafetyNet/NetPowerSprite".modulate = Color(1.0, 1.0, 1.0, min(1.0, (current_nets-1)/10))


''' ---------- CUSTOM FUNCTIONS ---------- '''

func end_level():
	Global.play_scene_transition(true, 0.3)
	await Global.get_node("SceneTransitionPlayer").animation_finished
	if get_tree() != null:
		get_tree().change_scene_to_file("res://Scenes/shop_tree.tscn")


func win_level():
	Global.stars += 1
	print("you win!")
	#end_level()

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
	scroll_parallax($LeftPanel/LeftParallax, time, 1)
	scroll_parallax($MidPanel/ParallaxBg, time, 0.3)
	scroll_parallax($RightPanel/RightParallax, time, 1)
	
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
				spawn_block(space[1][0], space[1][1] - pattern_height)
			2:
				spawn_big_block(space[1][0], space[1][1] - pattern_height)
			3:
				spawn_ghost_block(space[1][0], space[1][1] - pattern_height)
			4:
				spawn_crumbling_block(space[1][0], space[1][1] - pattern_height)
			5:
				spawn_fuse_primer_block(space[1][0], space[1][1] - pattern_height)
			6:
				spawn_fuse_block(space[1][0], space[1][1] - pattern_height)


func pattern_check():
	var should_spawn_pattern = true
	
	if current_height < spawn_wave_at_height:
		should_spawn_pattern = false

	return should_spawn_pattern


func modify_time(amount, multiplier):
	var old_time = game_timer.time_left
	old_time += amount * multiplier
	game_timer.stop()
	game_timer.wait_time = old_time
	game_timer.start()


func scroll_parallax(parallax_ref, time, distance_multiplier):
	var parrallax_tween = get_tree().create_tween()
	parrallax_tween.set_ease(0)
	parrallax_tween.set_trans(2)
	parrallax_tween.set_parallel(true)
	parrallax_tween.tween_property(parallax_ref, "scroll_offset", parallax_ref.scroll_offset + Vector2(0, 16 * distance_multiplier), time/1.3)


func end_coin_magnet():
	Global.player_paddle.set("magnet_active", false)


''' ---------- BLOCK FUNCTIONS ---------- '''

func spawn_block(c, r):
	var new_brick = brick_scene.instantiate()
	all_bricks.append(new_brick)
	new_brick.brick_destroyed.connect(on_brick_broken)
		
	var next_powerup_spawn = powerup_spawn_names[rng.rand_weighted(powerup_spawn_weights)]
	if next_powerup_spawn != "none":
		new_brick.spawn_with_powerup(next_powerup_spawn)
		
	new_brick.get_node("BlockSprite").frame = rng.randi_range(0, 2)
	new_brick.position = Vector2(margin + (16 * c) + (8 * (new_brick.scale.x - 1)), margin + (16 * r) - (8 * (new_brick.scale.y - 1)))
	add_child(new_brick)


func spawn_big_block(c, r):
	var new_brick = brick_scene.instantiate()
	all_bricks.append(new_brick)
	new_brick.brick_destroyed.connect(on_brick_broken)

	new_brick.health = 2
	new_brick.scale *= 2
	new_brick.get_node("BlockSprite").texture = big_brick_sprite
	new_brick.get_node("BlockSprite").scale *= 0.5
	new_brick.get_node("CracksSprite").scale *= 0.5
		
	new_brick.get_node("BlockSprite").frame = rng.randi_range(0, 2)
	new_brick.position = Vector2(margin + (16 * c) + (8 * (new_brick.scale.x - 1)), margin + (16 * r) - (8 * (new_brick.scale.y - 1)))
	add_child(new_brick)


func spawn_ghost_block(c, r):
	var new_brick = brick_scene.instantiate()
	all_bricks.append(new_brick)
	new_brick.brick_destroyed.connect(on_brick_broken)
	
	new_brick.get_node("BlockSprite").texture = ghost_brick_sprite
	new_brick.get_node("BlockCollision").set_deferred("disabled", true)
	
	new_brick.get_node("BlockSprite").frame = rng.randi_range(0, 2)
	new_brick.position = Vector2(margin + (16 * c) + (8 * (new_brick.scale.x - 1)), margin + (16 * r) - (8 * (new_brick.scale.y - 1)))
	add_child(new_brick)


func spawn_crumbling_block(c, r):
	var new_brick = brick_scene.instantiate()
	all_bricks.append(new_brick)
	new_brick.brick_destroyed.connect(on_brick_broken)
	
	new_brick.crumbling = true
	new_brick.health = 5
	new_brick.scale *= 2
	new_brick.get_node("BlockSprite").texture = crumbling_brick_sprite
	new_brick.get_node("BlockSprite").scale *= 0.5
	new_brick.get_node("CracksSprite").scale *= 0.5
	new_brick.get_node("BlockSprite").hframes = 1
	
	new_brick.position = Vector2(margin + (16 * c) + (8 * (new_brick.scale.x - 1)), margin + (16 * r) - (8 * (new_brick.scale.y - 1)))
	add_child(new_brick)


func spawn_fuse_primer_block(c, r):
	var new_brick = brick_scene.instantiate()
	all_bricks.append(new_brick)
	new_brick.brick_destroyed.connect(on_brick_broken)
	
	new_brick.primer = true
	
	new_brick.get_node("BlockSprite").frame = 3
	new_brick.position = Vector2(margin + (16 * c) + (8 * (new_brick.scale.x - 1)), margin + (16 * r) - (8 * (new_brick.scale.y - 1)))
	add_child(new_brick)


func spawn_fuse_block(c, r):
	var new_brick = brick_scene.instantiate()
	all_bricks.append(new_brick)
	new_brick.brick_destroyed.connect(on_brick_broken)
	
	new_brick.fuse = true
	new_brick.health = 3
	new_brick.get_node("CracksSprite").texture = small_cracks_sprite
	new_brick.get_node("CracksSprite").region_enabled = true
	
	new_brick.get_node("BlockSprite").frame = 4
	new_brick.position = Vector2(margin + (16 * c) + (8 * (new_brick.scale.x - 1)), margin + (16 * r) - (8 * (new_brick.scale.y - 1)))
	add_child(new_brick)


''' ---------- SIGNAL FUNCTIONS ---------- '''

func on_brick_broken(brick, source):
	match source:
		"ball":
			$ParticleManager.spawn_block_broken_particle(brick.position, brick.get_node("BlockSprite").frame, brick.scale)
		"laser":
			$ParticleManager.spawn_block_disentigrate_particle(brick.position, brick.scale)
		"crumbling":
			$ParticleManager.spawn_block_disentigrate_particle(brick.position, brick.scale)
		"falling_block":
			$ParticleManager.spawn_block_broken_particle(brick.position, brick.get_node("BlockSprite").frame, brick.scale)
		"falling_block_broken":
			$ParticleManager.spawn_block_broken_particle(brick.position, 3, Vector2(2, 2))
		"fuse":
			$ParticleManager.spawn_block_broken_particle(brick.position, 3, brick.scale)
	
	all_bricks.erase(brick)


func on_ball_destroyed(ball, source):
	match source:
		"bottom":
			pass
		"laser":
			$ParticleManager.spawn_ball_shatter_particle(ball.position)
	ball_ref.erase(ball)
	if paddle_ref.held_ball_count == 0 and ball_ref.is_empty():
		end_level()


func _on_slowing_field_body_entered(body: Node2D) -> void:
	if body in ball_ref:
		body.slow_down()
