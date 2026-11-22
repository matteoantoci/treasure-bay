## Layout math of spec 10 and of the game-flow spec part 5. `visible` is
## get_viewport().get_visible_rect().size.
##
## No top band: the Item column is at the left, the Collection strip at the bottom, and the
## Labyrinth fills the rest. The HUD values use the HUD scale h = visible height / 760. The values
## in px are px at a visible height of 1200 px, and they scale with the visible height too.
class_name ScreenLayout
extends RefCounted

## The prototype tile size. The sizes in the Labyrinth are px of this tile (spec 8.1).
const PROTOTYPE_TILE_PX := 130.0
## The px values below are px at this visible height.
const REFERENCE_HEIGHT := 1200.0
## In h.
const ITEM_COLUMN_H := 100.0
const MARGIN_H := 12.0
const STRIP_H := 70.0
## The tile cap is the Area 1 tile: so small Labyrinths keep their size.
const TILE_CAP_PX := 121.0
const ITEM_SLOT_MAX_PX := 120.0
const ITEM_SLOT_GAP_PX := 16.0
## The total count and its shell icon sit in this width at the left end of the strip.
const COUNT_AREA_PX := 300.0
const SHELL_PX := 58.0
## The gap between the shell icon and the count.
const SHELL_GAP_PX := 12.0
const COLLECTION_SLOT_MAX_PX := 68.0
const COLLECTION_SLOT_GAP_PX := 12.0
## The distance of the last Collection slot and of the shell icon from the screen edges.
const COLLECTION_EDGE_PX := 24.0
## The Sea friend in its slot, as a part of the slot diameter.
const COLLECTION_ICON_SHARE := 0.9
## The Godot default font size of the count.
const COUNT_FONT_PX := 64.0
const GEAR_PX := 48.0
## The distance of the gear centre from the top and the right edges.
const GEAR_INSET_PX := 40.0


## The factor s of spec 8.1 for a Labyrinth value in prototype px.
static func labyrinth_scale(tile_px: float) -> float:
	return tile_px / PROTOTYPE_TILE_PX


## The rectangle of a sprite of `texture_size`, centred on `centre`, with its longer side `px` long.
static func sprite_rect(centre: Vector2, texture_size: Vector2, px: float) -> Rect2:
	var size := texture_size * (px / maxf(texture_size.x, texture_size.y))
	return Rect2(centre - size / 2.0, size)


## The HUD values are prototype px at a height of 760 px. Multiply them by this (spec 8.1).
static func hud_scale(visible: Vector2) -> float:
	return visible.y / 760.0


## A value in px at a visible height of 1200 px, in px of this screen.
static func scaled_px(visible: Vector2, px_at_1200: float) -> float:
	return px_at_1200 * visible.y / REFERENCE_HEIGHT


## The bottom strip is the Collection.
static func bottom_strip_height(visible: Vector2) -> int:
	return roundi(STRIP_H * hud_scale(visible))


## The Item column is at the left, from the top edge to the strip.
static func item_column_width(visible: Vector2) -> float:
	return ITEM_COLUMN_H * hud_scale(visible)


## The Labyrinth area: the space right of the Item column and above the strip, less the margin on
## each side. The Labyrinth sits in its middle, and the Sea friend reveal too (game-flow spec part 6,
## fix 5).
static func labyrinth_area(visible: Vector2) -> Rect2:
	var margin := MARGIN_H * hud_scale(visible)
	var left := item_column_width(visible) + margin
	return Rect2(left, margin, visible.x - left - margin, visible.y - bottom_strip_height(visible) - 2.0 * margin)


## The tile size in px for a Labyrinth of `tiles` tiles: the largest that fits, with a cap. The width
## counts one tile more for the outer Goal island tile.
static func tile_px(visible: Vector2, tiles: Vector2i) -> int:
	var area := labyrinth_area(visible).size
	return floori(minf(minf(area.y / tiles.y, area.x / (tiles.x + 1)), scaled_px(visible, TILE_CAP_PX)))


## The rectangle of the Labyrinth tiles, on whole px. The Labyrinth and the outer Goal island tile
## at its right are centred in the Labyrinth area.
static func labyrinth_rect(visible: Vector2, tiles: Vector2i) -> Rect2:
	var tile := tile_px(visible, tiles)
	var size := Vector2(tiles) * tile
	var with_island := size + Vector2(tile, 0)
	return Rect2((labyrinth_area(visible).get_center() - with_island / 2.0).round(), size)


## The diameter of the Item slots for `count` Items: min(120 px, (free height - (count - 1) x 16 px)
## / count). The free height is the height of the Labyrinth area.
static func item_slot_px(visible: Vector2, count: int) -> float:
	var free := labyrinth_area(visible).size.y
	var fit := (free - (count - 1) * scaled_px(visible, ITEM_SLOT_GAP_PX)) / maxi(count, 1)
	return minf(scaled_px(visible, ITEM_SLOT_MAX_PX), fit)


## The centres of `count` Item slots: a column in the middle of the Item column, 16 px apart,
## centred as a group in the free height.
static func item_slot_centres(visible: Vector2, count: int) -> PackedVector2Array:
	var area := labyrinth_area(visible)
	var diameter := item_slot_px(visible, count)
	var distance := diameter + scaled_px(visible, ITEM_SLOT_GAP_PX)
	var x := item_column_width(visible) / 2.0
	var centres := PackedVector2Array()
	for i in count:
		centres.append(Vector2(x, area.get_center().y + (i - (count - 1) / 2.0) * distance))
	return centres


## The gear is in the top-right corner, its centre 40 px from the top and the right edges.
static func gear_rect(visible: Vector2) -> Rect2:
	var inset := scaled_px(visible, GEAR_INSET_PX)
	var size := Vector2.ONE * scaled_px(visible, GEAR_PX)
	return Rect2(Vector2(visible.x - inset, inset) - size / 2.0, size)


## The total Item count: right of the shell icon, in the count area at the left end of the strip.
static func collection_count_rect(visible: Vector2) -> Rect2:
	var strip := bottom_strip_height(visible)
	var shell := collection_shell_rect(visible)
	var left := shell.end.x + scaled_px(visible, SHELL_GAP_PX)
	return Rect2(left, visible.y - strip, scaled_px(visible, COUNT_AREA_PX - SHELL_GAP_PX) - left, strip)


## The spiral shell icon left of the count, 24 px from the left edge.
static func collection_shell_rect(visible: Vector2) -> Rect2:
	var size := scaled_px(visible, SHELL_PX)
	var middle := visible.y - bottom_strip_height(visible) / 2.0
	return Rect2(scaled_px(visible, COLLECTION_EDGE_PX), middle - size / 2.0, size, size)


## The rounded font at 64 px at a height of 1200 px.
static func collection_count_font_size(visible: Vector2) -> int:
	return roundi(scaled_px(visible, COUNT_FONT_PX))


## The diameter of the 20 Collection slots: they share the strip right of the count area, less
## 24 px at the right edge, with gaps of 12 px or more.
static func collection_slot_px(visible: Vector2) -> float:
	var count := SeaFriends.IDS.size()
	var fit := (_collection_slots_width(visible) - (count - 1) * scaled_px(visible, COLLECTION_SLOT_GAP_PX)) / count
	return minf(scaled_px(visible, COLLECTION_SLOT_MAX_PX), fit)


## The centres of the 20 Collection slots, from the count area to 24 px from the right edge, the
## same distance apart.
static func collection_slot_centres(visible: Vector2) -> PackedVector2Array:
	var count := SeaFriends.IDS.size()
	var diameter := collection_slot_px(visible)
	var distance := (_collection_slots_width(visible) - diameter) / (count - 1)
	var y := visible.y - bottom_strip_height(visible) / 2.0
	var centres := PackedVector2Array()
	for i in count:
		centres.append(Vector2(scaled_px(visible, COUNT_AREA_PX) + diameter / 2.0 + i * distance, y))
	return centres


## The size of a Sea friend in its Collection slot.
static func collection_icon_px(visible: Vector2) -> float:
	return COLLECTION_ICON_SHARE * collection_slot_px(visible)


static func _collection_slots_width(visible: Vector2) -> float:
	return visible.x - scaled_px(visible, COUNT_AREA_PX + COLLECTION_EDGE_PX)
