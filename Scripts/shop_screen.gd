extends Control


''' ---------- VARIABLES ---------- '''

@onready var all_upgrade_buttons = [
	$HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade,
	$HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/FasterBallUpgrade,
	$HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/FasterBallUpgrade/MoreBallUpgrade,
	$HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/FasterBallUpgrade/BiggerPaddleUpgrade,
	$HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/HigherMoney2Upgrade,
	$HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/FasterBallUpgrade/BiggerPaddleUpgrade/LongerGameTime,
	$HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/BuyLaserUpgrade
]


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(recursive_children($HBoxContainer/VBoxContainer2/ShopTree, []).slice(1))
	
	$HBoxContainer/LeftContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)
	for button in all_upgrade_buttons:
		if button.upgrade_name in Global.upgrades_bought:
			button.start_pressed()
	
	print(all_upgrade_buttons)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HBoxContainer/LeftContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)


''' ---------- CUSTOM FUNCTIONS ---------- '''

# Gets all children below a node, unsorted and with heirarchy
func recursive_children(node, current_array):
	current_array.append(node)
	
	for child in node.get_children():
		if child is UpgradeButton:
			recursive_children(child, current_array)
		
	return current_array


''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_manager.tscn")


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


''' ---------- UPGRADE BUTTONS ---------- '''

func _on_higher_money_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.coin_chance = 0.5
		

func _on_faster_ball_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/FasterBallUpgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.ball_speed = 300

func _on_more_ball_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/FasterBallUpgrade/MoreBallUpgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.ball_count = 2
		
func _on_bigger_paddle_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/FasterBallUpgrade/BiggerPaddleUpgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.paddle_size = 150

func _on_higher_money_2_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/HigherMoney2Upgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.coin_chance = 0.66

func _on_longer_game_time_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/FasterBallUpgrade/BiggerPaddleUpgrade/LongerGameTime
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.max_game_time = 900

func _on_buy_laser_upgrade_pressed() -> void:
	var button_ref = $HBoxContainer/VBoxContainer2/ShopTree/HigherMoneyUpgrade/BuyLaserUpgrade
	if (button_ref.is_selected == true) and (button_ref.upgrade_name not in Global.upgrades_bought):
		Global.upgrades_bought.append(button_ref.upgrade_name)
		Global.laser_unlocked = true
