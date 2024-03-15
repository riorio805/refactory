extends RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = "Orientation:\n" + str(Globals.current_orientation)
