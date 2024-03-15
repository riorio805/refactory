extends Node3D

var end_pos = Vector2()
var start_y = 1
var end_y = 1

@onready var wire = $CurveMesh3D


func _ready():
	var start_curve = Curve3D.new()
	start_curve.add_point(
		Vector3(0,0,0),
		Vector3(0,0,0),
		Vector3(0,-0.2,0),
	)
	start_curve.add_point(
		Vector3(1,-0.01,0),
		Vector3(0,-0.2,0),
		Vector3(0,0,0),
	)
	self.wire.curve = start_curve

func set_end(arg:Vector2):
	end_pos = arg

func get_len():
	return end_pos.length()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.rotation.y = -Vector2().angle_to_point(end_pos)
	self.wire.curve.set_point_position(1, Vector3(end_pos.length(), -0.01, 0))
