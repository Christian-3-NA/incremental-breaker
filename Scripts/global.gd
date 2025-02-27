extends Node

var coins = 0

# Upgrades
var coin_chance = 0.25 # %chance of out 1.0
var paddle_size = 80 # by pixels
var ball_speed = 200 
var ball_count = 1 # how many balls
var max_game_time = 60

var upgrades_bought = []

'''REMEMBER TO DELETE FULL TILES THAT GO TOO LOW IN THE OCCUPIED TILES ARRAY'''
# Pattern Dict. Every "empty tile" that creates a block pattern
var pattern_dict = {
	0: [],
	1: [],
	2: []
}

var image_pattern_ref_list = [
	load("res://Assets/block_patterns/pattern1.png")
]

# Color Constants
var C_WHITE = Color(1, 1, 1, 1)
var C_BLACK = Color(0, 0, 0, 1)


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
			if image_data.get_pixel(x, y) == C_WHITE:
				pattern_data.append([x, y])
				
	pattern_dict[index] = pattern_data
