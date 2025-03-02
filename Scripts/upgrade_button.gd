extends TextureButton
class_name UpgradeButton


''' ---------- VARIABLES ---------- '''

# General variables
var is_selected = false

# Upgrade unique variables
@export var upgrade_cost = 0
@export var upgrade_name = ""
@export var value_to_change = ""
@export var new_value = 0.0
@export var unlocked_by: Array[UpgradeButton] = []
@export var unlocks: Array[UpgradeButton] = []
var tree_lines: Array[Line2D] = []


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the lines connecting to parents
	for parent in unlocked_by:
		var new_line = Line2D.new()
		new_line.width = 3
		new_line.default_color = Color8(30, 30, 30, 255)
		new_line.z_index = -2
		new_line.z_as_relative = false
		new_line.add_point(size/2)
		new_line.add_point(parent.global_position - global_position + size/2)
		
		add_child(new_line)
		tree_lines.append(new_line)


''' ---------- CUSTOM FUNCTIONS ---------- '''

func start_pressed():
	is_selected = true
	for child in unlocks:
		child.disabled = false
	
	$Panel.hide()
	for line in tree_lines:
			line.default_color = Color(1, 1, 1)


''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_pressed() -> void:
	if is_selected == false and Global.coins >= upgrade_cost:
		Global.coins -= upgrade_cost
		
		is_selected = true
		for child in unlocks:
			child.disabled = false
		
		Global.set(value_to_change, new_value)
		Global.upgrades_bought.append(upgrade_name)
		
		$Panel.hide()
		for line in tree_lines:
			line.default_color = Color(1, 1, 1)
