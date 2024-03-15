extends Node3D

var has_building = false
var building:Building

func _ready():
	$hover.visible = false

func make_building(built:Building):
	if (building != null
		and not Input.is_action_pressed("build_safety_override")):
		return
	
	# for now fine, later check against prev and next
	var last = get_node_or_null("builded")
	if (last != null):
		last.name = null
		last.queue_free()

	self.building = built
	var build = self.building.mesh.instantiate()
	build.name = "builded"
	build.position.y = 0.25
	call_deferred("add_child", build)

func delete_building():
	var last = get_node_or_null("builded")
	if (last != null):
		last.queue_free()
		self.building = null

func update_state():
	if Globals.state == Globals.PlayState.Build:
		has_building = true
		make_building(Globals.current_building)
	if Globals.state == Globals.PlayState.Delete:
		has_building = false
		delete_building()

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT
			and event.is_pressed()):
			update_state()

func _on_area_3d_mouse_entered():
	if Globals.state == Globals.PlayState.Build:
		$hover.visible = true
	if Globals.state == Globals.PlayState.Delete:
		$hover.visible = true
	
	if Input.is_action_pressed("left_mouse_button"):
		update_state()

func _on_area_3d_mouse_exited():
	$hover.visible = false
