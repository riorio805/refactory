extends Control

var main_game = preload("res://scenes/Main.tscn")
@onready var anim = $AnimationPlayer


func _ready():
	anim.play("Splash")


func _process(_delta):
	if not anim.is_playing():
		get_tree().root.add_child(main_game.instantiate())
		get_node("/root/Splash").free()
