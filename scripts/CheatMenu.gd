extends TextureRect

var target_pos = Vector2(1920, 0)
var out_of_view = true


func _process(_delta):
	if Globals.is_paused:
		return

	if Input.is_action_just_pressed("cheat_menu_toggle"):
		out_of_view = not out_of_view
		if out_of_view:
			target_pos = Vector2(1920, 0)
		else:
			target_pos = Vector2(1520, 0)

	position += (target_pos - position) * 0.2
