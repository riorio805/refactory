extends TextureRect

var target_pos = Vector2(-420, 180)
var out_of_view = true
var base_button_scene = load("res://scenes/base_button.tscn")
var current_selected:Building

@onready var infobox = $PanelContainer

func _ready():
	infobox.visible = false
	
	for building_path in ResourcePaths.buildings:
		var button = load(building_path)
		if button.type not in [Building.BuildingType.Base, Building.BuildingType.Test]:
			add_button(button)
	pass

func add_button(building:Building):
	assert (building != null, "Passed null building to add_button")
	
	var container = $ScrollContainer/GridContainer
	
	var button = base_button_scene.instantiate()
	button.building = building
	button.text = building.name
	button.icon = building.gui_icon
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	container.call_deferred("add_child", button)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.is_paused:
		return
	
	if Input.is_action_just_pressed("build_menu_toggle"):
		out_of_view = not out_of_view
	if out_of_view:
		target_pos = Vector2(-401, 180)
	else:
		target_pos = Vector2(0, 180)
	
	position += (target_pos - position) * 0.2
	
	var building_shown = (current_selected if current_selected
					else Globals.current_building if Globals.current_building
					else null)
	if building_shown:
		$PanelContainer/VBoxContainer/title.text = building_shown.name
		$PanelContainer/VBoxContainer/description.text = building_shown.description
		var cost_str = "Cost:\n"
		if building_shown.iron_cost > 0:
			cost_str += "🪨Iron			%d\n" % building_shown.iron_cost
		if building_shown.gold_cost > 0:
			cost_str += "[color='gold'']✨Gold[/color]			%d\n" % building_shown.gold_cost
		if building_shown.iridium_cost > 0:
			cost_str += "[color='mediumpurple']🔮Iridium[/color]		%d\n" % building_shown.iridium_cost
		if building_shown.diamond_cost > 0:
			cost_str += "[color='lightblue']💎Diamond[/color]	%d\n" % building_shown.diamond_cost
		if cost_str == "Cost:\n":
			cost_str = "Cost:\nFree?? it's true"
		$PanelContainer/VBoxContainer/cost.text = cost_str


func change_selected(building:Building):
	current_selected = building
	if current_selected != null or Globals.current_building != null:
		infobox.visible = true
	else:
		infobox.visible = false
