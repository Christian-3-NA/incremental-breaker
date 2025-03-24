extends CharacterBody2D


''' ---------- VARIABLES ---------- '''

# Signals
signal brick_destroyed

var falling = true


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2(0, -1)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += 300 * delta
	
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		var collision_target = collision_info.get_collider()
		
		if collision_target.is_in_group("blocks"):
			collision_target.hit("falling_block")
		
		if collision_target.name == "PlayerPaddle":
			collision_target.hurt()
			brick_destroyed.emit(self, "falling_block_broken")
			queue_free()
		
		if collision_target.name == "KillFloor":
			queue_free()
