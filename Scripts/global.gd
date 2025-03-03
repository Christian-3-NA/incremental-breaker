extends Node

var coins = 100

# Upgrades. All values must be float
var coin_chance = 0.25 # %chance of out 1.0
var paddle_size = 60 # by pixels
var ball_speed = 200 
var ball_count = 1 # how many balls
var max_game_time = 60

# Equipment Upgrades. bools are 0 or 1
var laser_unlocked = 0

var upgrades_bought = []

# Pattern Dict. filled by initialize_pattern, data is [black_id, [x_coordinate, y_coordinate]]
var pattern_dict = {}

var image_pattern_ref_list = [
	load("res://Assets/block_patterns/pattern1.png"),
	load("res://Assets/block_patterns/pattern2.png"),
	load("res://Assets/block_patterns/pattern3.png"),
	load("res://Assets/block_patterns/pattern4.png"),
	load("res://Assets/block_patterns/pattern5.png")
]

# Color Constants
var C_WHITE = Color(1, 1, 1, 1)
var C_BLACK = Color(0, 0, 0, 1)
var C_GREY = Color8(127, 127, 127, 255)


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
				
	pattern_dict[index] = pattern_data
