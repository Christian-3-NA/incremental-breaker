extends TextureButton
class_name UpgradeButton


''' ---------- VARIABLES ---------- '''

var is_selected = false
@export var upgrade_cost = 0
@export var upgrade_name = ""


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is UpgradeButton:
		$Line2D.add_point(global_position + size/2 + Vector2(320, 0))
		$Line2D.add_point(get_parent().global_position + size/2 + Vector2(320, 0))


''' ---------- DEFAULT FUNCTIONS ---------- '''

func start_pressed():
	is_selected = true
	for child in get_children():
		if child is UpgradeButton:
			child.disabled = false
	
	$Panel.hide()
	$Line2D.default_color = Color(1, 1, 1)


''' ---------- SIGNAL FUCNTIONS ---------- '''

func _on_pressed() -> void:
	if is_selected == false and Global.coins >= upgrade_cost:
		Global.coins -= upgrade_cost
		
		is_selected = true
		for child in get_children():
			if child is UpgradeButton:
				child.disabled = false
		
		$Panel.hide()
		$Line2D.default_color = Color(1, 1, 1)



'''func _on_toggled(toggled_on: bool) -> void:
	for child in get_children():
		if child is UpgradeButton and toggled_on:
			child.disabled = false
	
	if toggled_on:
		$Panel.hide()
		$Line2D.default_color = Color(1, 1, 1)
	else:
		$Panel.show()
		$Line2D.default_color = Color(0.1, 0.1, 0.1)'''
