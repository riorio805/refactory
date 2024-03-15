extends Node

var width = 100
var length = 100
var gen_seed = "IndividualGameJam2024"

var noise:FastNoiseLite
var rng = RandomNumberGenerator.new()
@onready var gridmap = get_parent().find_child("GridMap")

var block_presets:Array[Array] = [[], [], [], [], [], []]

# Called when the node enters the scene tree for the first time.
func generate_world():
	if Globals.generated:
		return
	
	gen_seed = hash(gen_seed)
	rng.seed = gen_seed
	get_noise()
	
	for file in ResourcePaths.block_presets:
		var preset = load(file)
		if preset is BlockPreset:
			block_presets[preset.size].append(preset)
	
	Globals.init_tiles(width, length)
	# pass 1: set placeable tiles
	for x in range(-width, width+1):
		for z in range(-length, length+1):
			if (-2 <= x and x <= 2 
				and -2 <= z and z <= 2):
				continue
			
			var type = GameTileData.TileType.Grass
			
			var val = noise.get_noise_2d(x, z)+0.5
			if val < 0.4:
				type = GameTileData.TileType.Stone
			
			var map_pos = Vector3i(x, 0, z)
			var twod_pos = Vector2i(x, z)
			var tile_data = GameTileData.new(twod_pos, type)
			Globals.tiles[x][z] = tile_data
			var rot_basis = Basis(Vector3.UP, deg_to_rad(90) * rng.randi_range(0,3))
			var rot_index = gridmap.get_orthogonal_index_from_basis(rot_basis)
			var mesh_item = tile_data.get_mesh_item()
			gridmap.set_cell_item(map_pos, mesh_item, rot_index)
	
	var once = false
	# pass 2: ores and stuff
	for x in range(-width, width+1):
		for z in range(-length, length+1):
			if (-2 <= x and x <= 2 
				and -2 <= z and z <= 2 ):
				continue
			if Globals.tiles[x][z].type == GameTileData.TileType.Stone:
				continue
			
			var pos = Vector2i(x, z)
			var max_size = Globals.get_max_square_size(pos)
			var chance = ore_spawn_chance(pos) * 0.4
			if rng.randf() > chance:
				continue
			
			var size = min(rng.randi_range(1, max_size), 3)
			var idx = rng.randi_range(0, len(block_presets[size])-1)
			var preset = block_presets[size][idx]
			var orient = rng.randi_range(0, 3)
			var width = 2*size - 1
			var tl = pos - Vector2i(size-1, size-1)
			for px in range(width):
				for pz in range(width):
					var a = Globals.rotate_index(width, px, pz, orient)
					var rpx = a[0]
					var rpz = a[1]
					var ppos = tl + Vector2i(px, pz)
					var tile = Globals.tiles[ppos.x][ppos.y]
					tile.type = Globals.num_to_type(preset.blueprint[rpx][rpz])
					var rot_basis = Basis(Vector3.UP, deg_to_rad(90) * rng.randi_range(0,3))
					var rot_index = gridmap.get_orthogonal_index_from_basis(rot_basis)
					var mesh_item = tile.get_mesh_item()
					var map_pos = Vector3i(ppos.x, 0, ppos.y)
					gridmap.set_cell_item(map_pos, mesh_item, rot_index)

	
	# post: setup base tile
	var base_building = load("res://data/base/base_data.tres")
	var base_tiledata = GameTileData.new(Vector2i(0,0), GameTileData.TileType.Grass)
	var building_data = BuildingData.new(Vector2i(0,0), base_building)
	building_data.set_tiles([base_tiledata])
	base_tiledata.building = building_data
	Globals.tiles[0][0] = base_tiledata
	
	Globals.generated = true


func get_noise():
	noise = FastNoiseLite.new()
	noise.seed = gen_seed
	noise.frequency = 0.03
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX


func ore_spawn_chance(pos:Vector2i):
	var dist = pos.length()
	var mod = 0.15 * pow(2, -dist/16)
	return clampf(mod, 0.001, 1)


func _on_main_menu_generate_world():
	generate_world()
