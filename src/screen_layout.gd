## Layout math of spec 10. `visible` is get_viewport().get_visible_rect().size.
class_name ScreenLayout
extends RefCounted


## The top band holds the Item row and the gear.
static func top_band_height(visible: Vector2) -> int:
	return roundi(visible.y * 150.0 / 760.0)


## The bottom strip is the Collection.
static func bottom_strip_height(visible: Vector2) -> int:
	return roundi(visible.y * 70.0 / 760.0)


## The tile size in px for a Labyrinth of `tiles` tiles.
static func tile_px(visible: Vector2, tiles: Vector2i) -> int:
	var free_height := visible.y - top_band_height(visible) - bottom_strip_height(visible)
	return floori(minf(free_height / tiles.y, visible.x / tiles.x))


## The Labyrinth rectangle, in the middle of the space between the top band and the strip.
static func labyrinth_rect(visible: Vector2, tiles: Vector2i) -> Rect2:
	var size := Vector2(tiles) * tile_px(visible, tiles)
	var top := top_band_height(visible)
	var free_height := visible.y - top - bottom_strip_height(visible)
	return Rect2(Vector2((visible.x - size.x) / 2.0, top + (free_height - size.y) / 2.0), size)
