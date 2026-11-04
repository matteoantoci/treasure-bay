## One Item of a Labyrinth: its square and its kind (spec 4.6). Whether the Child has collected it
## is part of the Progress, not of the Item.
class_name Item
extends RefCounted

var square: Vector2i
## The sprite name in assets/sprites/items/, for example "starfish".
var kind: String
## "x,y" with the square coordinates. The save keeps the collected Items by this ID.
var id: String


func _init(item_square: Vector2i, item_kind: String) -> void:
	square = item_square
	kind = item_kind
	id = id_of(item_square)


static func id_of(item_square: Vector2i) -> String:
	return "%d,%d" % [item_square.x, item_square.y]
