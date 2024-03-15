extends RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.current_building != null:
		text = "Selected:\n" + Globals.current_building.name
	else:
		text = "Selected:\nNone"
