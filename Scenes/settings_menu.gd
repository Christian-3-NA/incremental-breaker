extends Control



func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MENU_NEUTRAL)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
