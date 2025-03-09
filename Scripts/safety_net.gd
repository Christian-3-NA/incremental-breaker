extends CharacterBody2D


func enable_net():
	show()
	
func disable_net():
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED

func hit(source):
	get_parent().current_nets -= 1
	if get_parent().current_nets <= 0:
		disable_net()
