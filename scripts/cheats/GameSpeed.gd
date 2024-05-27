extends VBoxContainer

var game_speed = 1

@onready var slider = $Input/HSlider
@onready var display_text = $Input/Label

func _ready():
	slider.value = game_speed

	slider.value_changed.connect(func(value: float) -> void: game_speed = value)


func _process(_delta):
	Engine.time_scale = game_speed
	display_text.text = str(game_speed)
