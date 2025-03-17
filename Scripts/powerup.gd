extends Node2D


''' ---------- VARIABLES ---------- '''

# Scenes
var ball_scene = preload("res://Scenes/ball.tscn")
var ball_powerup_sprite = preload("res://Assets/power_up_icons/extra_ball_power.png")
var safety_net_powerup_sprite = preload("res://Assets/power_up_icons/safety_net_power.png")
var slowing_field_powerup_sprite = preload("res://Assets/power_up_icons/slowing_field_power.png")
var coin_magnet_powerup_sprite = preload("res://Assets/power_up_icons/coin_magnet_power.png")
@onready var game_manager_ref = get_parent().get_parent()

# States
var powerup_type = ""


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match powerup_type:
		"EXTRA_BALL":
			$PowerupSprite.texture = ball_powerup_sprite

		"SAFETY_NET":
			$PowerupSprite.texture = safety_net_powerup_sprite

		"SLOWING_FIELD":
			$PowerupSprite.texture = slowing_field_powerup_sprite

		"COIN_MAGNET":
			$PowerupSprite.texture = coin_magnet_powerup_sprite



''' ---------- CUSTOM FUNCTIONS ---------- '''

func activate_powerup():
	match powerup_type:
		"EXTRA_BALL":
			var new_ball = ball_scene.instantiate()
			new_ball.position = get_parent().position
			game_manager_ref.add_child(new_ball)
			new_ball.velocity = Vector2(0, 1).normalized() * new_ball.speed
			new_ball.state = new_ball.BallState.BOUNCING
			
			game_manager_ref.ball_ref.append(new_ball)
			new_ball.ball_destroyed.connect(game_manager_ref.on_ball_destroyed)
			
		"SAFETY_NET":
			game_manager_ref.current_nets += 1
			
		"SLOWING_FIELD":
			game_manager_ref.get_node("SlowingField").enable_field()
			
		"COIN_MAGNET":
			Global.player_paddle.magnet_active = true
			game_manager_ref.get_node("CoinMagnetTimer").start()
