extends Area2D


@onready var slowing_field_timer = $SlowingFieldTimer
@onready var animator_ref = $SlowingFieldParticle.get_node("FadeIn")


func enable_field():
	process_mode = Node.PROCESS_MODE_INHERIT
	
	slowing_field_timer.wait_time = Global.max_slowing_field_time
	slowing_field_timer.start()
	slowing_field_timer.timeout.connect(disable_field)
	
	if $SlowingFieldParticle.modulate == Color(1.0, 1.0, 1.0, 0.0):
		animator_ref.play("FadeInOut")
	elif animator_ref.get_playing_speed() < 0:
		animator_ref.pause()
		animator_ref.play("FadeInOut", -1, 1.0)


func disable_field():
	$SlowingFieldParticle.get_node("FadeIn").play_backwards("FadeInOut")
	process_mode = Node.PROCESS_MODE_DISABLED
	
