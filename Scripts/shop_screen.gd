extends Control


''' ---------- VARIABLES ---------- '''

# Scenes
@onready var shop_tree_ref = $HBoxContainer/ScrollBox/ShopTree
@onready var shop_tree_starting_size = shop_tree_ref.custom_minimum_size
@onready var h_scroll = $HBoxContainer/ScrollBox.get_h_scroll_bar()
@onready var v_scroll = $HBoxContainer/ScrollBox.get_v_scroll_bar()

# Positioning Variables
var zoom_amount = Vector2(1.2, 1.2)


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.play_scene_transition(false)
	
	$HBoxContainer/LeftContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)
	h_scroll.set_deferred("value", h_scroll.max_value/2 - $HBoxContainer/ScrollBox.size.x/2)
	v_scroll.set_deferred("value", v_scroll.max_value/2 - $HBoxContainer/ScrollBox.size.y/2)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HBoxContainer/LeftContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)


''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_start_button_pressed() -> void:
	Global.play_scene_transition(true)
	await Global.get_node("SceneTransitionPlayer").animation_finished
	get_tree().change_scene_to_file("res://Scenes/game_manager.tscn")


func _on_return_button_pressed() -> void:
	Global.play_scene_transition(true)
	await Global.get_node("SceneTransitionPlayer").animation_finished
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_zoom_in_button_pressed() -> void:	
	if shop_tree_ref.custom_minimum_size <= shop_tree_starting_size * Vector2(1.5, 1.5):
		shop_tree_ref.custom_minimum_size *= zoom_amount
		
		for button in shop_tree_ref.get_children():
			button.scale *= zoom_amount
			button.position *= zoom_amount
			


func _on_zoom_out_button_pressed() -> void:
	if shop_tree_ref.custom_minimum_size >= shop_tree_starting_size / Vector2(1.5, 1.5):
		shop_tree_ref.custom_minimum_size /= zoom_amount

		for button in shop_tree_ref.get_children():
			button.scale /= zoom_amount
			button.position /= zoom_amount
