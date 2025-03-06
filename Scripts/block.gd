extends StaticBody2D


''' ---------- VARIABLES ---------- '''

# Signals
signal brick_destroyed

# Scenes
var coin_scene = preload("res://Scenes/coin.tscn")
var powerup_scene = preload("res://Scenes/powerup.tscn")
var rng = RandomNumberGenerator.new()

# Variables
var health = 1
var child_powerup

''' ---------- CUSTOM FUNCTIONS ---------- '''

func hit():
	health -= 1
	
	if health <= 0:
		brick_destroyed.emit(self)
		if rng.randf() <= Global.coin_chance:
			var new_coin = coin_scene.instantiate()
			new_coin.position = position
			get_parent().add_child(new_coin)
		
		if child_powerup:
			child_powerup.activate_powerup()
		queue_free()
	
	else:
		$CracksSprite.show()


func spawn_with_powerup(powerup_type):
	var new_powerup = powerup_scene.instantiate()
	new_powerup.powerup_type = powerup_type
	child_powerup = new_powerup
	add_child(new_powerup)
