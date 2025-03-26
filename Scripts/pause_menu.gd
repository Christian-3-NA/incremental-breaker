extends PanelContainer


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_menu"):
		pause()


''' ---------- CUSTOM FUNCTIONS ---------- '''
	
func pause():
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MENU_NEUTRAL)
	if get_tree().paused == true:
		get_tree().paused = false
		hide()
	else:
		get_tree().paused = true
		show()


''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_resume_button_pressed() -> void:
	pause()


func _on_return_button_pressed() -> void:
	pause()
	get_parent().end_level()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
