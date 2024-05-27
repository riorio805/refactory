extends ColorRect


func _on_win_close_button_pressed():
	visible = false


func _on_win_exit_button_pressed():
	get_tree().quit()
