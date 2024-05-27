class_name GameTileData
extends Object

enum TileType { Stone = -1, Grass = 0, Iron = 1, Gold = 2, Iridium = 3, Diamond = 4 }

const MESH_LIB = preload("res://assets/tile/mesh_library.tres")

var building: BuildingData
var position: Vector2i
var type: TileType


func _init(_position: Vector2i, _type: TileType):
	self.position = _position
	self.type = _type


func get_mesh_item():
	match self.type:
		TileType.Grass:
			return MESH_LIB.find_item_by_name("grass")
		TileType.Stone:
			return MESH_LIB.find_item_by_name("stone")
		TileType.Iron:
			return MESH_LIB.find_item_by_name("iron")
		TileType.Gold:
			return MESH_LIB.find_item_by_name("gold")
		TileType.Iridium:
			return MESH_LIB.find_item_by_name("iridium")
