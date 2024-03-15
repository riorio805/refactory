extends Button

@export var building:Building

func _on_pressed():
	if Globals.current_building == self.building:
		Globals.current_building = null
	else:
		Globals.current_building = self.building
	Globals.update_hover = true


func _on_mouse_entered():
	var parent = get_parent().get_parent().get_parent()
	if parent.has_method("change_selected"):
		parent.change_selected(building)

func _on_mouse_exited():
	var parent = get_parent().get_parent().get_parent()
	if parent.has_method("change_selected"):
		parent.change_selected(null)

