extends Node

var building_list:Array[BuildingData]

func _ready():
	building_list = []
#
func _process(delta):
	if Input.is_action_just_pressed("debug"):
		print("buildings")
		print(building_list)
	
	for building in building_list:
		if is_instance_valid(building):
			building.process(delta)

func create_building(build_pos:Vector2i):
	if not Globals.hovering:
		return
	
	var building = Globals.current_building as Building
	if (building == null):
		return
	
	if (Player.iron < building.iron_cost
	or Player.gold < building.gold_cost
	or Player.iridium < building.iridium_cost):
		return
	
	var built = BuildingData.new(build_pos, building)
	var size = building.size
	var tiles:Array[GameTileData]
	tiles = []
	var tl = build_pos + Vector2i(-size/2, -size/2)
	for i in range(size ** 2):
		var x = i/size
		var z = i%size
		var tile_bits = building.blueprint[x][z]
		
		match Globals.current_orientation:
			Globals.Orientation.PLUS_X:
				x = i/size
				z = i%size
			Globals.Orientation.PLUS_Z:
				x = i%size
				z = size - 1 - i/size
			Globals.Orientation.MINUS_X:
				x = size - 1 - i/size
				z = size - 1 - i%size
			Globals.Orientation.MINUS_Z:
				x = size - 1 - i%size
				z = i/size
		var offset = Vector2i(x, z)
		var pos = tl + offset
		if (tile_bits and 0b001 != 0):
			var tile = Globals.tiles[pos.x][pos.y] as GameTileData
			if (tile == null
				or tile.building != null
				or (tile.type == GameTileData.TileType.Stone and not Globals.can_place_anywhere)):
				built.free()
				return
			
			tile.building = built
			tiles.append(tile)
	
	built.set_tiles(tiles)
	# mesh
	var mesh = building.mesh.instantiate()
	mesh.position = Vector3(
		build_pos.x,
		0.25,
		build_pos.y
	)
	mesh.rotation.y = Globals.current_orientation * deg_to_rad(90)
	call_deferred("add_child", mesh)
	built.set_mesh(mesh)
	
	building_list.append(built)
	
	Player.iron -= building.iron_cost
	Player.gold -= building.gold_cost
	Player.iridium -= building.iridium_cost

func delete_building(build_pos:Vector2i):
	if not Globals.hovering:
		return
	var center_tile = Globals.tiles[build_pos.x][build_pos.y]
	if (center_tile == null or center_tile.building == null):
		return
	if center_tile.building.building.type == Building.BuildingType.Base:
		return
	
	var built = center_tile.building
	var building = built.building
	built.cfree()

	Player.iron += building.iron_cost
	Player.gold += building.gold_cost
	Player.iridium += building.iridium_cost
	Player.diamond += building.diamond_cost
