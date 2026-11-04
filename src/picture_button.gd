## A button of the settings panel that shows a picture and no words (spec 11.2, Open gap 2). The
## keys never press it: it takes no focus, so the arrow keys stay keys for play.
class_name PictureButton
extends Button

## The picture is a little darker while the button is down.
const DOWN_COLOUR := Color(0.75, 0.82, 0.92)

var picture := SettingsPicture.Kind.PLUS:
	set(value):
		picture = value
		queue_redraw()


func _init(picture_kind := SettingsPicture.Kind.PLUS) -> void:
	picture = picture_kind
	flat = true
	focus_mode = FOCUS_NONE
	custom_minimum_size = Vector2.ONE * SettingsPicture.PICTURE_PX


func _draw() -> void:
	var down := get_draw_mode() in [DRAW_PRESSED, DRAW_HOVER_PRESSED]
	var picture_size := Vector2.ONE * SettingsPicture.PICTURE_PX
	SettingsPicture.draw_picture(self, picture, Rect2((size - picture_size) / 2.0, picture_size), DOWN_COLOUR if down else SettingsPicture.FILL_COLOUR)
