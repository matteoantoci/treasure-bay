## The level display of one volume row (spec 11.2): 4 bars that grow from left to right. Step n
## fills the first n bars, so step 0 shows 4 empty bars.
class_name LevelBars
extends Control

const BARS := 4
const BAR_WIDTH := 18.0
const BAR_GAP := 10.0
const EMPTY_COLOUR := Color(1, 1, 1, 0.25)

var step := 0:
	set(value):
		step = value
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(BARS * BAR_WIDTH + (BARS - 1) * BAR_GAP, SettingsPicture.PICTURE_PX)
	mouse_filter = MOUSE_FILTER_IGNORE


func _draw() -> void:
	var left := (size.x - custom_minimum_size.x) / 2.0
	var bottom := (size.y + SettingsPicture.PICTURE_PX) / 2.0 - SettingsPicture.OUTLINE_WIDTH
	var full_height := SettingsPicture.PICTURE_PX - 2.0 * SettingsPicture.OUTLINE_WIDTH
	for i in BARS:
		var height := full_height * (i + 1) / BARS
		var bar := Rect2(left + i * (BAR_WIDTH + BAR_GAP), bottom - height, BAR_WIDTH, height)
		draw_rect(bar.grow(SettingsPicture.OUTLINE_WIDTH), SettingsPicture.OUTLINE_COLOUR)
		draw_rect(bar, SettingsPicture.FILL_COLOUR if i < step else EMPTY_COLOUR)
