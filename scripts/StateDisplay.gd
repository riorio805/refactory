extends RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.state == Globals.PlayState.Select:
		text = "Doing:\nWiring"
	if Globals.state == Globals.PlayState.Build:
		text = "Doing:\nBuilding"
	if Globals.state == Globals.PlayState.Delete:
		text = "Doing:\nDeleting"
