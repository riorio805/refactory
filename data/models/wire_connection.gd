class_name WireConnection
extends Object

var from: GameTileData
var to: GameTileData
var node: Node3D


# Called when the node enters the scene tree for the first time.
func _init(_from: GameTileData, _to: GameTileData, _node: Node3D):
	from = _from
	to = _to
	node = _node


func cfree():
	var from_building = from.building
	var to_building = to.building
	to_building.connections_from.erase(self)
	from_building.connections_to.erase(self)
	node.call_deferred("queue_free")
	call_deferred("free")
