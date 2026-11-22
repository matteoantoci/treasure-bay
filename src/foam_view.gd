## The foam of the game-flow spec part 5, fix 2: a still soft white line along each island coast, on
## the water. The line is 6 px wide at 35 % opacity, with soft edges. It starts at the coast, so
## its inner edge goes under the sand. This node is above the water and under the islands. The tile
## (0, 0) is at the node position.
class_name FoamView
extends Node2D

## The Kenney corner tiles round an island corner over one Kenney cell (IslandLook).
const CORNER_TILES := 1.0 / IslandLook.CELLS_PER_TILE
## Values in px of the prototype tile (spec 8.1).
const WIDTH_PX := 6.0
const ALPHA := 0.35
## The line centre is half the line width from the coast.
const DISTANCE_PX := WIDTH_PX / 2.0
## Pixels of the soft edge texture across the line.
const EDGE_TEXTURE_PX := 32
## Across the line, the alpha goes up from 0 to full in the outer 35 % of each half.
const SOFT_EDGE := 0.35

var lines: Array[Line2D] = []
## The coasts of the shown Labyrinth (CoastLine), in tiles.
var _outlines: Array[PackedVector2Array] = []
var _outer := PackedVector2Array()
var _tile_px := 0.0
## A 1 x EDGE_TEXTURE_PX texture with alpha_across() down its height: the line draws it across its
## width.
var _soft_edge: ImageTexture


## The foam alpha across the line, from 0 at one edge to full in the middle and 0 at the other edge.
## `v` goes from 0 to 1 across the line.
static func alpha_across(v: float) -> float:
	return smoothstep(0.0, SOFT_EDGE, v) * smoothstep(0.0, SOFT_EDGE, 1.0 - v)


func _init() -> void:
	var image := Image.create_empty(1, EDGE_TEXTURE_PX, false, Image.FORMAT_RGBA8)
	for y in EDGE_TEXTURE_PX:
		image.set_pixel(0, y, Color(1, 1, 1, alpha_across((y + 0.5) / EDGE_TEXTURE_PX)))
	_soft_edge = ImageTexture.create_from_image(image)


func show_labyrinth(labyrinth: Labyrinth) -> void:
	_outlines = CoastLine.water_outlines(labyrinth)
	_outer = CoastLine.outer_outline(labyrinth)
	_update()


func set_tile_px(tile_px: float) -> void:
	_tile_px = tile_px
	_update()


func _update() -> void:
	if _outer.is_empty() or _tile_px <= 0.0:
		return
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	var loops := CoastLine.foam_loops(_outlines, _outer, _tile_px, CORNER_TILES * _tile_px, DISTANCE_PX * s)
	while lines.size() < loops.size():
		lines.append(_new_line())
	while lines.size() > loops.size():
		lines.pop_back().queue_free()
	for i in loops.size():
		lines[i].points = loops[i]
		lines[i].width = WIDTH_PX * s


func _new_line() -> Line2D:
	var line := Line2D.new()
	line.closed = true
	line.default_color = Color(1, 1, 1, ALPHA)
	line.texture = _soft_edge
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(line)
	return line
