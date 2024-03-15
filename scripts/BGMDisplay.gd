extends RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = "[right]♫ Currently playing ♫\n" + Globals.current_bgm_name.replace(";", ":")
