## The water: a full-screen node under the islands, drawn by water.gdshader in the colours of the
## Area (spec 7.1, 7.2). The wave lines are fixed to the Labyrinth and scale with its tiles. The
## waves and the light shapes move (spec 8.2).
class_name WaterView
extends ColorRect

const WATER_SHADER := preload("res://src/water.gdshader")

## Seconds of water motion.
var time := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	material = ShaderMaterial.new()
	material.shader = WATER_SHADER


func show_area(area: int) -> void:
	color = Area.deep_colour(area)
	material.set_shader_parameter("deep_colour", Area.deep_colour(area))
	material.set_shader_parameter("light_colour", Area.light_colour(area))


## Covers the visible rectangle. The wave lines start from the Labyrinth tile (0, 0).
func layout(visible: Rect2, labyrinth_rect: Rect2, tile_px: float) -> void:
	position = visible.position
	size = visible.size
	material.set_shader_parameter("labyrinth_origin", labyrinth_rect.position)
	material.set_shader_parameter("s", ScreenLayout.labyrinth_scale(tile_px))


func _process(delta: float) -> void:
	time += delta
	material.set_shader_parameter("wave_phase", Motion.wave_phase(time))
	material.set_shader_parameter("light_shift", Motion.light_shift(time))
