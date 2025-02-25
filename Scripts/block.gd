extends StaticBody2D


''' ---------- VARIABLES ---------- '''

# Signals
signal brick_destroyed

# Scenes
var coin_scene = preload("res://Scenes/coin.tscn")
var rng = RandomNumberGenerator.new()


''' ---------- CUSTOM FUNCTIONS ---------- '''

func hit():
	brick_destroyed.emit(self)
	if rng.randf() <= Global.coin_chance:
		var new_coin = coin_scene.instantiate()
		new_coin.position = position
		get_parent().add_child(new_coin)
	
	queue_free()
