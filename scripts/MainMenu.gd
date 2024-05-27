extends Control

signal generate_world
signal pause


func _process(_delta):
	if Input.is_action_just_pressed("game_menu") and Globals.generated:
		emit_signal("pause")


func _on_play_button_pressed():
	if not Globals.generated:
		emit_signal("generate_world")
		$VBoxContainer2/HBoxContainer/LineEdit.editable = false
	emit_signal("pause")


func _on_exit_button_pressed():
	get_tree().quit()


func _on_credits_pressed():
	$Credits.visible = not $Credits.visible
