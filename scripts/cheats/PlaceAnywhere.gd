extends HBoxContainer

@onready var button = $CheckButton

var place_anywhere = false

func _ready():
	button.button_pressed = false
	
	button.toggled.connect(
		func(value:float) -> void:
			place_anywhere = button.button_pressed
	)

func _process(_delta):
	Globals.can_place_anywhere = place_anywhere
