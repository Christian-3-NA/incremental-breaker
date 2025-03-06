extends Node2D


''' ---------- VARIABLES ---------- '''

# Scenes
var ball_scene = preload("res://Scenes/ball.tscn")
var ball_powerup_sprite = preload("res://Assets/power_up_icons/extra_ball_power.png")
var safety_net_powerup_sprite = preload("res://Assets/power_up_icons/safety_net_power.png")

# States
var powerup_type = ""


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match powerup_type:
		"EXTRA_BALL":
			$PowerupSprite.texture = ball_powerup_sprite

		"SAFETY_NET":
			$PowerupSprite.texture =safety_net_powerup_sprite



''' ---------- CUSTOM FUNCTIONS ---------- '''

func activate_powerup():
	match powerup_type:
		"EXTRA_BALL":
			var new_ball = ball_scene.instantiate()
			new_ball.position = get_parent().position
			get_parent().get_parent().add_child(new_ball)
			new_ball.velocity = Vector2(0, 1).normalized() * new_ball.speed
			new_ball.state = new_ball.BallState.BOUNCING
			
			get_parent().get_parent().ball_ref.append(new_ball)
			new_ball.ball_destroyed.connect(get_parent().get_parent().on_ball_destroyed)
		
		"SAFETY_NET":
			Global.safety_nets += 1
