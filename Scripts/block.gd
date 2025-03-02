extends StaticBody2D


''' ---------- VARIABLES ---------- '''

# Signals
signal brick_destroyed

# Scenes
var coin_scene = preload("res://Scenes/coin.tscn")
var rng = RandomNumberGenerator.new()

# Variables
var health = 1

''' ---------- CUSTOM FUNCTIONS ---------- '''

func hit():
	health -= 1
	
	if health <= 0:
		brick_destroyed.emit(self)
		if rng.randf() <= Global.coin_chance:
			var new_coin = coin_scene.instantiate()
			new_coin.position = position
			get_parent().add_child(new_coin)
		
		queue_free()
	
	else:
		$CracksSprite.show()
