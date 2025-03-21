extends StaticBody2D


''' ---------- VARIABLES ---------- '''

# Signals
signal brick_destroyed

# Scenes
var coin_scene = preload("res://Scenes/coin.tscn")
var powerup_scene = preload("res://Scenes/powerup.tscn")
var brick_sprite = preload("res://Assets/small_blocks.png")
var rng = RandomNumberGenerator.new()

# Variables
var health = 1
var child_powerup

''' ---------- CUSTOM FUNCTIONS ---------- '''

func hit(source):
	health -= 1
	
	if health <= 0:
		brick_destroyed.emit(self, source)
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


func _on_height_collider_body_exited(body: Node2D) -> void:
	if get_node("BlockCollision").disabled == true and body.is_in_group("balls"):
		get_node("BlockSprite").texture = brick_sprite
		get_node("BlockCollision").set_deferred("disabled", false)
