## Layout math of spec 10. `visible` is get_viewport().get_visible_rect().size.
class_name ScreenLayout
extends RefCounted

## The prototype tile size. The sizes in the Labyrinth are px of this tile (spec 8.1).
const PROTOTYPE_TILE_PX := 130.0
## The gear size in px (spec 10).
const GEAR_PX := 64.0


## The factor s of spec 8.1 for a Labyrinth value in prototype px.
static func labyrinth_scale(tile_px: float) -> float:
	return tile_px / PROTOTYPE_TILE_PX


## The rectangle of a sprite of `texture_size`, centred on `centre`, with its longer side `px` long.
static func sprite_rect(centre: Vector2, texture_size: Vector2, px: float) -> Rect2:
	var size := texture_size * (px / maxf(texture_size.x, texture_size.y))
	return Rect2(centre - size / 2.0, size)


## The top band holds the Item row and the gear.
static func top_band_height(visible: Vector2) -> int:
	return roundi(visible.y * 150.0 / 760.0)


## The bottom strip is the Collection.
static func bottom_strip_height(visible: Vector2) -> int:
	return roundi(visible.y * 70.0 / 760.0)


## The Labyrinth area: the space between the top band and the strip, the full width of the screen.
## The Labyrinth sits in its middle, and the Sea friend reveal too (game-flow spec part 6, fix 5).
static func labyrinth_area(visible: Vector2) -> Rect2:
	var top := top_band_height(visible)
	return Rect2(0, top, visible.x, visible.y - top - bottom_strip_height(visible))


## The tile size in px for a Labyrinth of `tiles` tiles.
static func tile_px(visible: Vector2, tiles: Vector2i) -> int:
	var area := labyrinth_area(visible).size
	return floori(minf(area.y / tiles.y, area.x / tiles.x))


## The Labyrinth rectangle, in the middle of the Labyrinth area.
static func labyrinth_rect(visible: Vector2, tiles: Vector2i) -> Rect2:
	var size := Vector2(tiles) * tile_px(visible, tiles)
	return Rect2(labyrinth_area(visible).get_center() - size / 2.0, size)


## The HUD values are prototype px at a height of 760 px. Multiply them by this (spec 8.1).
static func hud_scale(visible: Vector2) -> float:
	return visible.y / 760.0


## The centres of `count` Item outlines: a row at y = 60 h, 90 h apart, centred left to right.
static func item_outline_centres(visible: Vector2, count: int) -> PackedVector2Array:
	var h := hud_scale(visible)
	var centres := PackedVector2Array()
	for i in count:
		centres.append(Vector2(visible.x / 2.0 + (i - (count - 1) / 2.0) * 90.0 * h, 60.0 * h))
	return centres


static func item_outline_px(visible: Vector2) -> float:
	return 56.0 * hud_scale(visible)


## The gear is in the top-right corner. Its centre is at the height of the Item row and the same
## distance from the right edge.
static func gear_rect(visible: Vector2) -> Rect2:
	var row_y := 60.0 * hud_scale(visible)
	var centre := Vector2(visible.x - row_y, row_y)
	return Rect2(centre - Vector2.ONE * GEAR_PX / 2.0, Vector2.ONE * GEAR_PX)


## The total Item count sits at the left end of the strip, in an area 2 strip heights wide.
static func collection_count_rect(visible: Vector2) -> Rect2:
	var strip := bottom_strip_height(visible)
	return Rect2(0, visible.y - strip, 2 * strip, strip)


## The Godot default font at 64 px at a height of 1200 px.
static func collection_count_font_size(visible: Vector2) -> int:
	return roundi(64.0 * visible.y / 1200.0)


## The centres of the 20 Collection slots. They share the strip right of the count area, with the
## same distance between their centres.
static func collection_slot_centres(visible: Vector2) -> PackedVector2Array:
	var count_area := collection_count_rect(visible)
	var distance := (visible.x - count_area.end.x) / SeaFriends.IDS.size()
	var centres := PackedVector2Array()
	for i in SeaFriends.IDS.size():
		centres.append(Vector2(count_area.end.x + (i + 0.5) * distance, count_area.get_center().y))
	return centres


static func collection_icon_px(visible: Vector2) -> float:
	return 44.0 * hud_scale(visible)
