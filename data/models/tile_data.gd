class_name GameTileData
extends Object

enum TileType {
	Stone = -1,
	Grass = 0,
	Iron = 1,
	Gold = 2,
	Iridium = 3,
	Diamond = 4
}

var building:BuildingData
var position:Vector2i
var type:TileType

const mesh_lib = preload("res://assets/tile/mesh_library.tres")

func _init(_position:Vector2i, _type:TileType):
	self.position = _position
	self.type = _type

func get_mesh_item():
	match self.type:
		TileType.Grass:
			return mesh_lib.find_item_by_name("grass")
		TileType.Stone:
			return mesh_lib.find_item_by_name("stone")
		TileType.Iron:
			return mesh_lib.find_item_by_name("iron")
		TileType.Gold:
			return mesh_lib.find_item_by_name("gold")
		TileType.Iridium:
			return mesh_lib.find_item_by_name("iridium")


