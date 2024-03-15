class_name BuildingData
extends Object

var tiles:Array[GameTileData]
var connections_from:Array[WireConnection]
var connections_to:Array[WireConnection]
var center_pos:Vector2i
var building:Building
var mesh_node:Node

var iron = 0
var gold = 0
var iridium = 0
var diamond = 0

var out_iron = 0
var out_gold = 0
var out_iridium = 0
var out_diamond = 0

func _init(_center_pos:Vector2i, _building=Globals.current_building):
	self.center_pos = _center_pos
	self.building = _building
	connections_from = []
	connections_to = []

func process(delta):
	match building.type:
		Building.BuildingType.Transfer:
			process_materials(iron, gold, iridium)
		Building.BuildingType.Mine:
			var p_iron = 0
			var p_gold = 0
			var p_iridium = 0
			for tile in tiles:
				match tile.type:
					GameTileData.TileType.Iron:
						p_iron += 1 * delta
					GameTileData.TileType.Gold:
						p_gold += 1 * delta
					GameTileData.TileType.Iridium:
						p_iridium += 1 * delta
			process_materials(p_iron, p_gold, p_iridium)
		Building.BuildingType.Process:
			var need_iron = 3 * delta
			var need_gold = 2 * delta
			if iron >= need_iron and gold >= need_gold:
				iron -= need_iron
				gold -= need_gold
				out_iridium += 1 * delta
		
	var target_count = connections_to.size()
	for wire in connections_to:
		var next_tile = wire.to
		var next_build = next_tile.building
		var send_mats = [
			out_iron/target_count, 
			out_gold/target_count, 
			out_iridium/target_count
		]
		var reduce = next_build.add_materials(send_mats[0], send_mats[1], send_mats[2])
		reduce_materials(reduce[0], reduce[1], reduce[2])
		target_count -= 1


func set_tiles(_tiles:Array[GameTileData]):
	self.tiles = _tiles

func set_mesh(_mesh_node:Node):
	self.mesh_node = _mesh_node

func can_connect():
	return connections_to.size() < building.max_out_connect

func add_materials(_iron:float, _gold:float, _iridium:float):
	if building.max_iron >= 0:
		_iron = min(building.max_iron - iron, _iron)
	iron += _iron
	if building.max_gold >= 0:
		_gold = min(building.max_gold - gold, _gold)
	gold += _gold
	if building.max_iridium >= 0:
		_iridium = min(building.max_iridium - iridium, _iridium)
	iridium += _iridium
	return [_iron, _gold, _iridium]

func process_materials(_iron:float, _gold:float, _iridium:float):
	if building.max_iron >= 0:
		_iron = min(building.max_iron - out_iron, _iron)
	out_iron += _iron
	iron -= _iron
	if building.max_gold >= 0:
		_gold = min(building.max_gold - out_gold, _gold)
	out_gold += _gold
	gold -= _gold
	if building.max_iridium >= 0:
		_iridium = min(building.max_iridium - out_iridium, _iridium)
	out_iridium += _iridium
	iridium -= _iridium
	return [_iron, _gold, _iridium]

func reduce_materials(_iron:float, _gold:float, _iridium:float):
	_iron = min(out_iron, _iron)
	out_iron -= _iron
	_gold = min(out_gold, _gold)
	out_gold -= _gold
	_iridium = min(out_iridium, _iridium)
	out_iridium -= _iridium
	return [_iron, _gold, _iridium]

func cfree():
	self.mesh_node.call_deferred("free")
	while connections_from.size() != 0:
		connections_from[0].cfree()
	while connections_to.size() != 0:
		connections_to[0].cfree()
	for tile in tiles:
		tile.building = null
	call_deferred("free")
