extends Node3D

const RAY_LENGTH = 30.0

var center_tile: Vector2i
var prev_tile_select: GameTileData

var wire_scene = preload("res://scenes/wire.tscn")
var current_wire: Node3D

@onready var camera3d = $Focus/Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.is_paused:
		return

	if not Globals.is_win and Player.iridium > 100:
		$ColorRect.visible = true
		Globals.is_win = true

	if Input.is_action_just_pressed("state_change_delete"):
		Globals.state = Globals.PlayState.DELETE
		clear_wire()
	if Input.is_action_just_pressed("state_change_build"):
		Globals.state = Globals.PlayState.BUILD
		clear_wire()
	if Input.is_action_just_pressed("state_change_select"):
		Globals.state = Globals.PlayState.SELECT
		clear_wire()

	$GridMap.set_point_pos(process_mouse_point())

	var pointed_pos = $GridMap.pointed_pos
	center_tile = Vector2i(pointed_pos.x, pointed_pos.z)

	if current_wire:
		var wire_pos = Vector2(current_wire.position.x, current_wire.position.z)
		current_wire.set_end(Vector2(center_tile) - wire_pos)
		current_wire.visible = current_wire.get_len() <= 8

	if Input.is_action_just_pressed("build_action"):
		match Globals.state:
			Globals.PlayState.SELECT:
				process_select_action()
			Globals.PlayState.BUILD:
				$Buildings.create_building(center_tile)
			Globals.PlayState.DELETE:
				$Buildings.delete_building(center_tile)

	if Input.is_action_just_pressed("debug"):
		print("current_wire")
		print(current_wire)


func process_mouse_point():
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera3d.project_ray_origin(mouse_pos)
	var to = from + camera3d.project_ray_normal(mouse_pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(from, to, 0b1010)
	query.collide_with_areas = true
	var intersection = space_state.intersect_ray(query)
	return intersection.get("position")


func process_select_action():
	if Globals.tiles[center_tile.x][center_tile.y]:
		var next_tile_select = Globals.tiles[center_tile.x][center_tile.y]
		print(next_tile_select.building)
		if (
			prev_tile_select
			and next_tile_select.building
			and next_tile_select.building != prev_tile_select.building
		):
			print("o")
			if current_wire.get_len() <= 8:
				print(
					(
						"connect from "
						+ str(prev_tile_select.position)
						+ " to "
						+ str(next_tile_select.position)
					)
				)
				var status = create_wire(prev_tile_select, next_tile_select)
				if status:
					prev_tile_select = null
					current_wire = null
		elif (
			next_tile_select.building
			and next_tile_select.building.building.type != Building.BuildingType.Base
			and (
				next_tile_select.building.can_connect()
				or Input.is_action_pressed("build_safety_override")
			)
		):
			clear_wire()
			while not next_tile_select.building.can_connect():
				next_tile_select.building.connections_to[0].cfree()
			prev_tile_select = next_tile_select
			current_wire = wire_scene.instantiate()
			$Wires.call_deferred("add_child", current_wire)
			current_wire.position = Vector3(center_tile.x, 1, center_tile.y)
		else:
			print(center_tile)
			print(next_tile_select.type)
		if next_tile_select.building:
			var b = next_tile_select.building
			print([b.iron, b.gold, b.iridium])


func create_wire(from: GameTileData, to: GameTileData):
	if WireManager.has_duplicate(from, to):
		if Input.is_action_pressed("build_safety_override"):
			WireManager.delete_all_connections(from, to)
		else:
			return false
	var wc = WireConnection.new(from, to, current_wire)
	$Wires.add_wire_connection(wc)
	from.building.connections_to.append(wc)
	to.building.connections_from.append(wc)
	return true


func clear_wire():
	prev_tile_select = null
	if current_wire:
		current_wire.call_deferred("free")
		current_wire = null


func _on_main_menu_pause():
	Globals.is_paused = not Globals.is_paused
	$MainMenu.visible = Globals.is_paused
	$MainGUI.visible = not Globals.is_paused
