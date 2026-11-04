## A plain boat drawn in code, 54 x 86 px at a 130 px tile (spec 10). The node scale sets the
## tile size. Like boat_white_sail.png, the bow points down at rotation 0.
class_name BoatView
extends Node2D

## The prototype tile size. The boat sizes are in px of this tile (spec 8.1).
const PROTOTYPE_TILE_PX := 130.0
const SIZE := Vector2(54, 86)
const HULL_COLOUR := Color("#8a5a2b")
const SAIL_COLOUR := Color("#ffffff")


func set_tile_px(tile_px: float) -> void:
	scale = Vector2.ONE * (tile_px / PROTOTYPE_TILE_PX)


func _draw() -> void:
	var half := SIZE / 2
	var hull := PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y * 0.35),
		Vector2(0, half.y),
		Vector2(-half.x, half.y * 0.35),
	])
	draw_colored_polygon(hull, HULL_COLOUR)
	var sail := PackedVector2Array([
		Vector2(-half.x * 0.7, -half.y * 0.45),
		Vector2(half.x * 0.7, -half.y * 0.45),
		Vector2(0, half.y * 0.5),
	])
	draw_colored_polygon(sail, SAIL_COLOUR)
