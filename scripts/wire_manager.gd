class_name WireManager
extends Node

var wires: Array[WireConnection] = []


func add_wire_connection(wire: WireConnection):
	wires.append(wire)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		print("wires")
		print(str(wires))


static func has_duplicate(from_tile: GameTileData, to_tile: GameTileData):
	var from_build = from_tile.building
	var to_build = to_tile.building
	for wire in from_build.connections_to:
		var b = wire.to.building
		if b == to_build:
			return true
	for wire in from_build.connections_from:
		var b = wire.from.building
		if b == to_build:
			return true
	return false


static func delete_all_connections(from_tile: GameTileData, to_tile: GameTileData):
	var from_build = from_tile.building
	var to_build = to_tile.building

	var x = from_build.connections_to.size()
	for i in range(x - 1, -1, -1):
		var wire = from_build.connections_to[i]
		var b = wire.to.building
		if b == to_build:
			wire.cfree()
	x = from_build.connections_from.size()
	for i in range(x - 1, -1, -1):
		var wire = from_build.connections_from[i]
		var b = wire.from.building
		if b == to_build:
			wire.cfree()

	x = to_build.connections_to.size()
	for i in range(x - 1, -1, -1):
		var wire = to_build.connections_to[i]
		var b = wire.to.building
		if b == from_build:
			wire.cfree()
	x = to_build.connections_from.size()
	for i in range(x - 1, -1, -1):
		var wire = to_build.connections_from[i]
		var b = wire.from.building
		if b == from_build:
			wire.cfree()
