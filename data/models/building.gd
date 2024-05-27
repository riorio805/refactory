class_name Building
extends Resource

enum BuildingType {
	Test,
	Base,
	Mine,
	Transfer,
	Process
}

@export var build_id:int
@export var name:String
@export_multiline var description:String
@export var type:BuildingType = BuildingType.Test
@export var mesh:PackedScene
@export var size:int
@export var gui_icon:Texture2D

@export var iron_cost = 0
@export var gold_cost = 0
@export var iridium_cost = 0
@export var diamond_cost = 0

@export var max_iron:int = 0
@export var max_gold:int = 0
@export var max_iridium:int = 0
@export var max_diamond:int = 0

@export var max_out_connect:int = 1

@export var blueprint:Array[PackedInt32Array]

@export var behaviour:Script

# Blueprint specifications
# blueprint[x][z]
#
# ex size 3 blueprint
# ^ +X, > +Z
# 20 21 22
# 10 11 12
# 00 01 02
#
# even sizes will prioritize top left as the center
# ex size 2
# 2 3
# C 1
