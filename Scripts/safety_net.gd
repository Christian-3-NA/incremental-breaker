extends CharacterBody2D


func enable_net():
	show()
	
func disable_net():
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED

func hit():
	Global.safety_nets -= 1
	if Global.safety_nets <= 0:
		disable_net()
