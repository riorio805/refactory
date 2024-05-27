extends Node3D

@export var distance: float = 8
@export var min_distance: float = 5.0
@export var max_distance: float = 25.0

@export var min_angle: float = -15
@export var max_angle: float = 85

@export var idle_rotation_speed: float = 60
@export var rotation_speed: float = 3 * 60
@export var movement_speed: float = 0.2 * 60

@export var mouse_sensitivity: float = 0.7
@export var dist_smoothness_mod: float = 0.12
@export var angle_smoothness_mod: float = 0.10

var real_distance
var angle = Vector2()
var real_angle
var distance_step
var angle_step

var movement = Vector2()

@onready var camera = $Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	real_distance = distance
	distance_step = (max_distance - min_distance)
	angle = Vector2((max_angle + min_angle) / 2, 0)
	real_angle = angle
	angle_step = (max_angle - min_angle)


# Camera control using mouse
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_mouse_bind"):
		var mouse_movement = event.relative * mouse_sensitivity
		if mouse_movement.length() > 1e-5:
			angle.y += mouse_movement.x
			angle.x = clampf(angle.x + mouse_movement.y, min_angle, max_angle)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance -= distance_step / 10
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance += distance_step / 10
		distance = clampf(distance, min_distance, max_distance)


func get_camera_input(delta):
	if Input.is_action_pressed("camera_rotate_left"):
		angle.y -= rotation_speed * delta
	if Input.is_action_pressed("camera_rotate_right"):
		angle.y += rotation_speed * delta
	if Input.is_action_pressed("camera_zoom_in"):
		distance -= distance_step * delta
	if Input.is_action_pressed("camera_zoom_out"):
		distance += distance_step * delta

	distance = clampf(distance, min_distance, max_distance)


func update_camera():
	camera.rotation.x = deg_to_rad(-real_angle.x)
	camera.rotation.y = deg_to_rad(-real_angle.y)

	var angle_to_camera = -camera.rotation
	var next_camera_pos = (
		Vector3(-sin(angle_to_camera.y), 0, cos(angle_to_camera.y)).normalized() * real_distance
	)
	var rotation_axis = Vector3.RIGHT.rotated(Vector3.UP, -angle_to_camera.y).normalized()
	next_camera_pos = next_camera_pos.rotated(rotation_axis, -angle_to_camera.x)
	next_camera_pos.y = max(next_camera_pos.y, 0.3)
	camera.position = next_camera_pos


func get_focus_movement():
	movement = Vector2()
	if Input.is_action_pressed("camera_move_left"):
		movement += Vector2.LEFT
	if Input.is_action_pressed("camera_move_right"):
		movement += Vector2.RIGHT
	if Input.is_action_pressed("camera_move_forwards"):
		movement += Vector2.UP
	if Input.is_action_pressed("camera_move_backwards"):
		movement += Vector2.DOWN
	movement = movement.normalized()


func move_focus(delta):
	var angle_from_camera = camera.rotation
	var distance_mod = exp(real_distance / max_distance)
	var focus_movement = Vector3(movement.x, 0, movement.y).rotated(Vector3.UP, angle_from_camera.y)
	translate(focus_movement * movement_speed * distance_mod * delta)


func update_real_values():
	real_angle += (angle - real_angle) * angle_smoothness_mod
	real_distance += (distance - real_distance) * dist_smoothness_mod

	if (angle.y > 360 and real_angle.y > 360) or (angle.y < -360 and real_angle.y < -360):
		angle.y = fmod(angle.y, 360)
		real_angle.y = fmod(real_angle.y, 360)


func _process(delta):
	get_camera_input(delta)

	if not Globals.is_paused:
		get_focus_movement()
		move_focus(delta)

	update_camera()
	update_real_values()
