extends TextureButton
class_name UpgradeButton


''' ---------- VARIABLES ---------- '''

var is_selected = false
@export var upgrade_cost = 0
@export var upgrade_name = ""
var last_position = global_position


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if get_parent() is UpgradeButton:
		$Line2D.clear_points()
		$Line2D.add_point(global_position + size/2)
		$Line2D.add_point(get_parent().global_position + size/2)

'''
func _draw():
	if get_parent() is UpgradeButton:
		var point1 = -(position) + size/2
		draw_line(point1, Vector2(0, 0) + size/2, Color(0, 0, 0, 255), 2)'''


''' ---------- CUSTOM FUNCTIONS ---------- '''

func start_pressed():
	is_selected = true
	for child in get_children():
		if child is UpgradeButton:
			child.disabled = false
	
	$Panel.hide()
	$Line2D.default_color = Color(1, 1, 1)


''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_pressed() -> void:
	if is_selected == false and Global.coins >= upgrade_cost:
		Global.coins -= upgrade_cost
		
		is_selected = true
		for child in get_children():
			if child is UpgradeButton:
				child.disabled = false
		
		$Panel.hide()
		$Line2D.default_color = Color(1, 1, 1)
