extends Control


''' ---------- VARIABLES ---------- '''

@onready var all_upgrade_buttons = [
	$HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade,
	$HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/FasterBallUpgrade,
	$HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/FasterBallUpgrade/MoreBallUpgrade,
	$HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/FasterBallUpgrade/BiggerPaddleUpgrade,
	$HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/HigherMoney2Upgrade,
	$HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/FasterBallUpgrade/BiggerPaddleUpgrade/LongerGameTime
]


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)
	for button in all_upgrade_buttons:
		if button.upgrade_name in Global.upgrades_bought:
			button.start_pressed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HBoxContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)


''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_manager.tscn")


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


''' ---------- UPGRADE BUTTONS ---------- '''

func _on_higher_money_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.coin_chance = 0.5

func _on_faster_ball_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/FasterBallUpgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.ball_speed = 300

func _on_more_ball_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/FasterBallUpgrade/MoreBallUpgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.ball_count = 2
		
func _on_bigger_paddle_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/FasterBallUpgrade/BiggerPaddleUpgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.paddle_size = 150

func _on_higher_money_2_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/HigherMoney2Upgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.coin_chance = 0.66

func _on_longer_game_time_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/Panel/HigherMoneyUpgrade/FasterBallUpgrade/BiggerPaddleUpgrade/LongerGameTime
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.max_game_time = 900
