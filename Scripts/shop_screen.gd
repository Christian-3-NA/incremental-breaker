extends Control


''' ---------- VARIABLES ---------- '''

# Positioning Variables
var zoom_amount = Vector2(1.2, 1.2)
var squished = false


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.play_scene_transition(false, 1)
	
	$LeftContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$LeftContainer/VBoxContainer/MoneyLabel.text = str(Global.coins)


''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_start_button_pressed() -> void:
	Global.play_scene_transition(true, 1)
	await Global.get_node("SceneTransitionPlayer").animation_finished
	get_tree().change_scene_to_file("res://Scenes/game_manager.tscn")


func _on_return_button_pressed() -> void:
	Global.play_scene_transition(true, 1)
	await Global.get_node("SceneTransitionPlayer").animation_finished
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_drop_down_button_pressed() -> void:
	if squished:
		var tween = create_tween()
		tween.set_ease(1)
		tween.set_trans(3)
		tween.tween_property(self, "position:y", position.y + size.y, 0.4)
		squished = false
		
	else:
		var tween = create_tween()
		tween.set_ease(0)
		tween.set_trans(3)
		tween.tween_property(self, "position:y", position.y - size.y, 0.4)
		squished = true
	
