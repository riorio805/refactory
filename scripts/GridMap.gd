extends GridMap

@export var hover_mesh_transparency = 0.4
@export var hover_mesh_move_mod = 0.6
var hover_tile:GameTileData
var pointed_pos:Vector3i
var hover_shadow_real_pos:Vector3

const hover_on_states = [
	Globals.PlayState.Select,
	Globals.PlayState.Delete
]

# Called when the node enters the scene tree for the first time.
func _ready():
	$HoverBox.visible = false
	update_hover_mesh()

func _process(_delta):
	if Globals.is_paused:
		return
	
	var shadow = find_child("HoverShadow", true, false)
	
	if Globals.update_hover:
		Globals.update_hover = false
		update_hover_mesh()
	
	var center_tile = Vector2i(pointed_pos.x, pointed_pos.z)
	if Globals.state == Globals.PlayState.Build:
		Globals.hovering = Globals.check_current_pos(center_tile)
	elif Globals.state == Globals.PlayState.Delete:
		var tile = Globals.tiles[center_tile.x][center_tile.y] as GameTileData
		if (tile == null
			or tile.building == null
			or tile.type == GameTileData.TileType.Stone):
			Globals.hovering = false
		else:
			Globals.hovering = true
		$HoverBox.scale = Vector3(1,1,1)
	
	match Globals.state:
		Globals.PlayState.Build:
			if shadow:
				if Globals.check_current_pos(center_tile):
					shadow.visible = true
				else:
					shadow.visible = false
		_:
			if shadow:
				shadow.visible = false
	
	if (Globals.hovering and
		Globals.state in hover_on_states):
		$HoverBox.visible = true
	else:
		$HoverBox.visible = false
		#shadow.visible = false
	
	if Globals.hovering:
		$HoverBox.position.x = pointed_pos.x
		$HoverBox.position.z = pointed_pos.z
	
	if shadow:
		hover_shadow_real_pos = Vector3(pointed_pos) + Vector3(0,0.25,0)
		shadow.position += (hover_shadow_real_pos - shadow.position) * hover_mesh_move_mod
	
	#print("shadow is " + str(shadow.visible) + " at " + str(shadow.position))

func set_point_pos(mouse_pos):
	if mouse_pos == null:
		Globals.hovering = false
	elif abs(mouse_pos.x) <= 2.5 and abs(mouse_pos.z) <= 2.5:
		pointed_pos = Vector3i(0,0,0)
		Globals.hovering = true
	else:
		pointed_pos = local_to_map(to_local(mouse_pos) + Vector3(0.5, 0, 0.5))
		Globals.hovering = true
	#print(pointed_pos)

func update_hover_mesh():
	var prev_pos = Vector3()
	if find_child("HoverShadow", true, false):
		var prev = find_child("HoverShadow", true, false)
		prev_pos = prev.position
		prev.queue_free()
		await get_tree().process_frame
	
	var building = Globals.current_building
	if not building:
		return
	var building_mesh = building.mesh.instantiate()
	if building_mesh is CSGCombiner3D:
		building_mesh.transparency = hover_mesh_transparency
		#print(building_mesh.transparency)
	for mesh in building_mesh.find_children("*", "MeshInstance3D", true, false):
		mesh.transparency = hover_mesh_transparency
		#print(mesh.transparency)
	building_mesh.name = "HoverShadow"
	building_mesh.rotation.y = Globals.current_orientation * deg_to_rad(90)
	building_mesh.position = prev_pos
	# $HoverBox.scale = Vector3(building.size, building.size, building.size)
	call_deferred("add_child", building_mesh)
	await get_tree().process_frame
	if building_mesh:
		for anim in building_mesh.find_children("*", "AnimationPlayer", true, false):
			print("aaa")
			anim.stop()
