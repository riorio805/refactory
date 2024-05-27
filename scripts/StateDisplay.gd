extends RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.state == Globals.PlayState.SELECT:
		text = "Doing:\nWiring"
	if Globals.state == Globals.PlayState.BUILD:
		text = "Doing:\nBuilding"
	if Globals.state == Globals.PlayState.DELETE:
		text = "Doing:\nDeleting"
