extends TextureButton
class_name UpgradeButton


''' ---------- VARIABLES ---------- '''

# General variables
var is_selected = false

# Upgrade unique variables
@export var upgrade_cost = 0
@export var upgrade_name = ""
@export var upgrade_description = ""
@export var value_to_change = ""
@export var value_change_mode = ""
@export var new_value = 0.0
@export var unlocked_by: Array[UpgradeButton] = []
@export var unlocks: Array[UpgradeButton] = []
@export var upgrade_icon: Texture2D:
	set(new_texture):
		$UpgradeIcon.texture = new_texture
var tree_lines: Array[Line2D] = []

# Scenes
var tree_lines_dark = load("res://Assets/tree_line_dark.png")
var tree_lines_bright = load("res://Assets/tree_line_bright.png")
var tooltip_scene = load("res://Scenes/upgrade_popup.tscn")
var bought_texture = load("res://Assets/upgrade_icons/upgrade_bought.png")


''' ---------- DEFAULT FUNCTIONS ---------- '''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Disable the button if it has any parents in the tree
	if unlocked_by:
		disabled = true
		
	if upgrade_name in Global.upgrades_bought:
		start_pressed()
		
	
	# Create the lines connecting to parents
	for parent in unlocked_by:
		if parent.upgrade_name in Global.upgrades_bought:
			disabled = false
		
		var new_line = Line2D.new()
		new_line.width = 6
		new_line.texture_repeat = 2
		new_line.texture_mode = 1
		
		if is_selected == true and parent.upgrade_name in Global.upgrades_bought:
			new_line.texture = tree_lines_bright
		else:
			new_line.texture = tree_lines_dark
		
		new_line.z_index = -2
		new_line.z_as_relative = false
		new_line.add_point(parent.global_position - global_position + size/2)
		new_line.add_point(size/2)
		
		add_child(new_line)
		tree_lines.append(new_line)


func _make_custom_tooltip(for_text: String) -> Object:
	var new_tooltip = tooltip_scene.instantiate()
	
	new_tooltip.get_node("VBoxContainer/Label").text = upgrade_name + " - Cost " + str(upgrade_cost)
	new_tooltip.get_node("VBoxContainer/Label2").text = upgrade_description
	
	return new_tooltip
	

''' ---------- CUSTOM FUNCTIONS ---------- '''

func start_pressed():
	disabled = false
	texture_normal = bought_texture
	$UpgradeIcon.modulate = Color(1, 1, 1, 1)
	is_selected = true
	for child in unlocks:
		child.disabled = false
	
	$Panel.hide()


''' ---------- SIGNAL FUNCTIONS ---------- '''

func _on_pressed() -> void:
	if is_selected == false and Global.coins >= upgrade_cost:
		Global.coins -= upgrade_cost
		
		is_selected = true
		texture_normal = bought_texture
		$UpgradeIcon.modulate = Color(1, 1, 1, 1)
		for child in unlocks:
			child.disabled = false
		
		# Change value depending on value_change_mode
		match value_change_mode:
			"set":
				Global.set(value_to_change, new_value)
				
			"enable":
				Global.set(value_to_change, true)
				
			"add_float":
				var old_value = Global.get(value_to_change)
				var modified_value = old_value + new_value
				Global.set(value_to_change, modified_value)
				
			"subtract_float":
				var old_value = Global.get(value_to_change)
				var modified_value = old_value - new_value
				Global.set(value_to_change, modified_value)
		
		Global.upgrades_bought.append(upgrade_name)
		
		$Panel.hide()
		
		# Set lines between buttons
		for line_index in tree_lines.size():
			if unlocked_by[line_index].is_selected == true:
				tree_lines[line_index].texture = tree_lines_bright
		
		for children in unlocks:
			for line_index in children.tree_lines.size():
				if children.unlocked_by[line_index].is_selected == true and children.is_selected == true:
					children.tree_lines[line_index].texture = tree_lines_bright
