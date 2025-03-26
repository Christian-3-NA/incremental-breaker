extends Control


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.play_scene_transition(false, 1)
	

''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_start_button_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MENU_NEUTRAL)
	Global.play_scene_transition(true, 1)
	await Global.get_node("SceneTransitionPlayer").animation_finished
	get_tree().change_scene_to_file("res://Scenes/shop_tree.tscn")


func _on_settings_button_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MENU_NEUTRAL)
	get_tree().change_scene_to_file("res://Scenes/settings_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
