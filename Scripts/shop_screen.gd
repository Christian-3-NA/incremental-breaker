extends Control


''' ---------- VARIABLES ---------- '''

var all_upgrade_buttons = []


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_upgrade_buttons = $HBoxContainer/VBoxContainer2/ShopTree.get_children()
	
	$HBoxContainer/LeftContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)
	for button in all_upgrade_buttons:
		if button.upgrade_name in Global.upgrades_bought:
			button.start_pressed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HBoxContainer/LeftContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)


''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_manager.tscn")


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
