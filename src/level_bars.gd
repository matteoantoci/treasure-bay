## The level display of one volume row (spec 11.2): 4 rounded bars that grow from left to right, in
## the cream-and-wood style (game-flow spec part 5, fix 7). Step n fills the first n bars, so step
## 0 shows 4 empty bars.
class_name LevelBars
extends Control

const BARS := 4
const BAR_WIDTH := 34.0
const BAR_GAP := 10.0
const BAR_HEIGHTS: Array[float] = [24.0, 36.0, 50.0, 64.0]
const CORNER_RADIUS := 8
const FULL_COLOUR := SettingsPicture.FILL_COLOUR
const EMPTY_COLOUR := Color("#d8b98a")

var step := 0:
	set(value):
		step = value
		queue_redraw()
var _full := _bar_style(FULL_COLOUR)
var _empty := _bar_style(EMPTY_COLOUR)


func _init() -> void:
	custom_minimum_size = Vector2(BARS * BAR_WIDTH + (BARS - 1) * BAR_GAP, BAR_HEIGHTS[-1])
	mouse_filter = MOUSE_FILTER_IGNORE


func _draw() -> void:
	var left := (size.x - custom_minimum_size.x) / 2.0
	var bottom := (size.y + custom_minimum_size.y) / 2.0
	for i in BARS:
		var bar := Rect2(left + i * (BAR_WIDTH + BAR_GAP), bottom - BAR_HEIGHTS[i], BAR_WIDTH, BAR_HEIGHTS[i])
		draw_style_box(_full if i < step else _empty, bar)


static func _bar_style(colour: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = colour
	style.set_corner_radius_all(CORNER_RADIUS)
	style.anti_aliasing = true
	return style
