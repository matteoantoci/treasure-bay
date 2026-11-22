## A button of the settings panel that shows a picture and no words (spec 11.2, Open gap 2): a round
## face in the cream-and-wood style with a bottom edge (game-flow spec part 5, fix 7). The keys
## never press it: it takes no focus, so the arrow keys stay keys for play.
class_name PictureButton
extends Button

const BUTTON_PX := 72.0
const FACE_COLOUR := Color("#e9c98f")
const EDGE_COLOUR := Color("#b58a4a")
## The bottom edge below the face. While the button is down, the face moves down onto the edge.
const EDGE_PX := 6.0

var picture := SettingsPicture.Kind.PLUS:
	set(value):
		picture = value
		queue_redraw()


func _init(picture_kind := SettingsPicture.Kind.PLUS) -> void:
	picture = picture_kind
	flat = true
	focus_mode = FOCUS_NONE
	custom_minimum_size = Vector2(BUTTON_PX, BUTTON_PX + EDGE_PX)


func _draw() -> void:
	var down := get_draw_mode() in [DRAW_PRESSED, DRAW_HOVER_PRESSED]
	var radius := BUTTON_PX / 2.0
	var centre := Vector2(size.x / 2.0, (size.y - EDGE_PX) / 2.0)
	draw_circle(centre + Vector2(0, EDGE_PX), radius, EDGE_COLOUR, true, -1.0, true)
	if down:
		centre.y += EDGE_PX
	draw_circle(centre, radius, FACE_COLOUR, true, -1.0, true)
	var picture_size := Vector2.ONE * SettingsPicture.PICTURE_PX
	SettingsPicture.draw_picture(self, picture, Rect2(centre - picture_size / 2.0, picture_size), SettingsPicture.FILL_COLOUR)
