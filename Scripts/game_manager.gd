extends Node2D


''' ---------- VARIABLES ---------- '''

# Scenes

var brick_scene = preload("res://Scenes/block.tscn")

# Spawning Parameters
var columns = 20
var rows = 7
var margin = 8


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_level()
	
	
''' ---------- CUSTOM FUNCTIONS ---------- '''

func setup_level():
	for r in rows:
		for c in columns:
			var new_brick = brick_scene.instantiate()
			add_child(new_brick)
			new_brick.position = Vector2(margin + (16 * c), margin + (16  * r))
