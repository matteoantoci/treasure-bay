## The foam of spec 8.2: a dashed white line along each island coast, on the water. The dashes move
## along the coast, and the line distance from the coast goes in and out. This node is above the
## water and under the islands. The tile (0, 0) is at the node position.
class_name FoamView
extends Node2D

const FOAM_SHADER := preload("res://src/foam.gdshader")
## The Kenney corner tiles round an island corner over one Kenney cell (IslandLook).
const CORNER_TILES := 1.0 / IslandLook.CELLS_PER_TILE

## Seconds of foam motion.
var time := 0.0
var lines: Array[Line2D] = []
## The coasts of the shown Labyrinth (CoastLine.water_outlines), in tiles, and its tile count.
var _outlines: Array[PackedVector2Array] = []
var _tile_count := Vector2i.ZERO
var _tile_px := 0.0
var _material := ShaderMaterial.new()
## A 1 x 1 white texture: the line gets UVs along its length (foam.gdshader).
var _white: ImageTexture


func _init() -> void:
	var image := Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	_white = ImageTexture.create_from_image(image)
	_material.shader = FOAM_SHADER
	_material.set_shader_parameter("dash_widths", Motion.FOAM_DASH_PX / Motion.FOAM_WIDTH_PX)
	_material.set_shader_parameter("period_widths", (Motion.FOAM_DASH_PX + Motion.FOAM_GAP_PX) / Motion.FOAM_WIDTH_PX)


func show_labyrinth(labyrinth: Labyrinth) -> void:
	_outlines = CoastLine.water_outlines(labyrinth)
	_tile_count = labyrinth.tile_count()
	_update()


func set_tile_px(tile_px: float) -> void:
	_tile_px = tile_px
	_update()


func _process(delta: float) -> void:
	time += delta
	_update()


func _update() -> void:
	if _tile_count == Vector2i.ZERO or _tile_px <= 0.0:
		return
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	var loops := CoastLine.foam_loops(_outlines, _tile_count, _tile_px, CORNER_TILES * _tile_px, Motion.foam_distance(time) * s)
	while lines.size() < loops.size():
		lines.append(_new_line())
	while lines.size() > loops.size():
		lines.pop_back().queue_free()
	for i in loops.size():
		lines[i].points = loops[i]
		lines[i].width = Motion.FOAM_WIDTH_PX * s
	_material.set_shader_parameter("shift_widths", Motion.foam_shift(time) / Motion.FOAM_WIDTH_PX)


func _new_line() -> Line2D:
	var line := Line2D.new()
	line.closed = true
	line.default_color = Color(1, 1, 1, Motion.FOAM_ALPHA)
	line.texture = _white
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.material = _material
	add_child(line)
	return line
