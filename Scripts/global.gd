extends Node


var coins = 1000
var stars = 0

# Upgrades. All values must be float
var coin_chance = 0.2 # %chance of out 1.0
var paddle_size = 60.0 # by pixels
var ball_speed = 200.0
var ball_count = 1.0 # how many balls
var max_game_time = 45.0
var starting_nets = 0.0
var max_slowing_field_time = 15.0
var max_coin_magnet_time = 15.0
var do_combo_time = false
var do_speed_explosion = false
var altitude_money_multiplier = 0.0

# Powerup spawn chances and names
var spawn_extra_ball_name = "EXTRA_BALL"
var spawn_extra_ball_chance = 0.0
var spawn_safety_net_name = "SAFETY_NET"
var spawn_safety_net_chance = 0.0
var spawm_slowing_field_name = "SLOWING_FIELD"
var spawm_slowing_field_chance = 0.0
var spawn_coin_magnet_name = "COIN_MAGNET"
var spawn_coin_magnet_chance = 0.0

# Equipment Upgrades. bools are 0 or 1
var laser_unlocked = 0

# Upgrade list
var upgrades_bought = []

# Pattern Dict. filled by initialize_pattern, data is [black_id, [x_coordinate, y_coordinate]]
var pattern_dict = {}

var image_pattern_ref_list = [
	load("res://Assets/block_patterns/pattern1.png"),
	load("res://Assets/block_patterns/pattern2.png"),
	load("res://Assets/block_patterns/pattern3.png"),
	load("res://Assets/block_patterns/pattern4.png"),
	load("res://Assets/block_patterns/pattern5.png"),
	load("res://Assets/block_patterns/pattern6.png"),
	load("res://Assets/block_patterns/pattern7.png"),
	load("res://Assets/block_patterns/pattern8.png")
]

# Gameplay Variables
var player_paddle
var goal_height = 50

# Color Constants
var C_WHITE = Color(1, 1, 1, 1)
var C_BLACK = Color(0, 0, 0, 1)
var C_GREY = Color8(127, 127, 127, 255)
var C_CYAN = Color8(0, 127, 127, 255)
var C_MAROON = Color8(127, 0, 0, 255)
var C_PINK = Color8(200, 0, 200, 255)
var C_DARK_PINK = Color8(127, 0, 127, 255)

var rng = RandomNumberGenerator.new()


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in image_pattern_ref_list.size():
		initialize_pattern(image_pattern_ref_list[i], i)


''' ---------- CUSTOM FUNCTIONS ---------- '''

func initialize_pattern(image, index):
	var image_data = image.get_image()
	var pattern_data = []
	
	for x in image_data.get_width():
		for y in image_data.get_height():
			match image_data.get_pixel(x, y):
				C_WHITE:
					pattern_data.append([0, [x, y]]) # EMPTY
				C_BLACK:
					pattern_data.append([1, [x, y]]) # BASIC BLOCK
				C_GREY:
					pattern_data.append([2, [x, y]]) # LARGE BLOCK
				C_CYAN:
					pattern_data.append([3, [x, y]]) # GHOST BLOCK
				C_MAROON:
					pattern_data.append([4, [x, y]]) # CRUMBLING BLOCK
				C_PINK:
					pattern_data.append([5, [x, y]]) # FUSE PRIMER BLOCK
				C_DARK_PINK:
					pattern_data.append([6, [x, y]]) # FUSE BLOCK
				
	pattern_dict[index] = pattern_data


# Plays the animation when changing scenes. direction_bool = true is forward, false is backward
func play_scene_transition(direction_bool, speed_scale):
	$SceneTransitionPlayer.set_speed_scale(speed_scale)
	if direction_bool:
		if rng.randi_range(1, 100) == 1:
			$CanvasLayer/SceneTransitionScreen/Amogus.show()
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MENU_WOOSH_IN)
		$CanvasLayer/SceneTransitionScreen.show()
		$SceneTransitionPlayer.play("scene_transition")
	else:
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MENU_WOOSH_OUT)
		$SceneTransitionPlayer.play("scene_transition_2")
		await $SceneTransitionPlayer.animation_finished
		$CanvasLayer/SceneTransitionScreen.hide()
		$CanvasLayer/SceneTransitionScreen/Amogus.hide()
	
