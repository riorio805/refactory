extends Node

enum PlayState {
	Select,
	Build,
	Delete
}

enum Orientation {
	PLUS_X,
	PLUS_Z,
	MINUS_X,
	MINUS_Z
}

var warnings = [
	["Hello", 1]
]

#cheats
var can_place_anywhere = false

var is_paused = true
var is_win = false
var generated = false

var state:PlayState = PlayState.Select

var current_building:Building = null
var current_bgm_name = "None"

var mouse_left_down = false
var hovering = false
var update_hover = false
var current_orientation = 0
var hover_shader = preload("res://assets/shaders/translucent.tres")


var tiles: Array[Array]

func init_tiles(width:int, length:int):
	for i in 2 * width + 1:
		tiles.append([])
		for j in 2 * length + 1:
			tiles[i].append(null)

func _process(delta):
	mouse_left_down = Input.is_action_just_pressed("build_action")
	if Input.is_action_just_pressed("build_rotate_cw"):
		current_orientation += 1
		current_orientation = posmod(current_orientation, 4)
		Globals.update_hover = true
	
	var x = warnings.size()
	for idx in range(x-1, -1, -1):
		var message = warnings[idx]
		message[1] -= delta
		warnings.erase(message)
	
	if tiles and tiles[0][0] and tiles[0][0].building:
		var build = tiles[0][0].building
		Player.iron += build.iron
		Player.gold += build.gold
		Player.iridium += build.iridium
		build.iron = 0
		build.gold = 0
		build.iridium = 0


func check_current_pos(build_pos:Vector2i):
	var building = Globals.current_building as Building
	if (building == null):
		return false
	
	var size = building.size
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
				return false
	
	return true


func get_max_square_size(pos:Vector2i):
	# assume max 9x9 centered at pos
	var size = 5
	var start_x = pos.x - 4
	var start_y = pos.y - 4
	for i in range(9):
		for j in range(9):
			var x = start_x + i
			var y = start_y + j
			var dist = max(abs(i - 4), abs(j - 4))
			if (not tiles[x][y] or
				tiles[x][y].type == GameTileData.TileType.Stone):
				size = min(size, dist)
	return size


func rotate_index(size:int, x:int, y:int, orient:int):
	var a = [0,0]
	match orient:
		0:
			a[0] = x
			a[1] = y
		1:
			a[0] = y
			a[1] = size - 1 - x
		2:
			a[0] = size - 1 - x
			a[1] = size - 1 - y
		3:
			a[0] = size - 1 - y
			a[1] = x
	return a

func num_to_type(n:int):
	match n:
		-1, 255:
			return GameTileData.TileType.Stone
		0:
			return GameTileData.TileType.Grass
		1:
			return GameTileData.TileType.Iron
		2:
			return GameTileData.TileType.Gold
		3:
			return GameTileData.TileType.Iridium
