extends RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var string = "[color=pink][font_size=24]"
	for message in Globals.warnings:
		string += message[0] + "\n"
	text = string
