## A button that acts only after a hold: the reset and the quit button (spec 11.2). Each button has
## its own hold time and full ring colour. A ring around the picture fills while the button is down.
## If the button comes up before the hold time, the ring goes back to empty and nothing happens.
## The ring has the cream-and-wood style (game-flow spec part 5, fix 7): a light brown ring with a
## cream disc in it.
class_name HoldButton
extends PictureButton

## Emitted when the button was down for the whole hold time.
signal held

## The ring is this big. It is 14 px thick, so the cream disc in it is 92 px.
const RING_BUTTON_PX := 120.0
const RING_WIDTH := 14.0
const RING_RADIUS := (RING_BUTTON_PX - RING_WIDTH) / 2.0
const RING_EMPTY_COLOUR := PictureButton.FACE_COLOUR
const DISC_COLOUR := SettingsPicture.KNOB_COLOUR

## The time of a full hold, in seconds. Tests set a shorter time.
var hold_seconds: float
## The colour of the filled part of the ring.
var ring_full_colour: Color
## How full the ring is, from 0 to 1.
var ring := 0.0
var _held_seconds := 0.0
var _down := false


func _init(picture_kind: SettingsPicture.Kind, hold_time: float, full_colour: Color) -> void:
	super(picture_kind)
	hold_seconds = hold_time
	ring_full_colour = full_colour
	custom_minimum_size = Vector2.ONE * RING_BUTTON_PX
	button_down.connect(_on_button_down)
	button_up.connect(release)


func _process(delta: float) -> void:
	if _down:
		advance(delta)


## Adds `seconds` to the hold while the button is down. At the full hold time the ring empties and
## the button emits `held`, one time for each hold. The frames call it; tests call it as a fake clock.
func advance(seconds: float) -> void:
	if not _down:
		return
	_held_seconds += seconds
	ring = minf(_held_seconds / hold_seconds, 1.0)
	if _held_seconds >= hold_seconds:
		_down = false
		_held_seconds = 0.0
		ring = 0.0
		held.emit()
	queue_redraw()


## Ends the hold: the ring goes back to empty.
func release() -> void:
	_down = false
	_held_seconds = 0.0
	ring = 0.0
	queue_redraw()


func _on_button_down() -> void:
	_down = true
	_held_seconds = 0.0
	ring = 0.0
	queue_redraw()


## The ring fills clockwise from the top. The picture is in the cream disc, with no face.
func _draw() -> void:
	var centre := size / 2.0
	draw_arc(centre, RING_RADIUS, 0.0, TAU, 96, RING_EMPTY_COLOUR, RING_WIDTH, true)
	if ring > 0.0:
		draw_arc(centre, RING_RADIUS, -PI / 2.0, -PI / 2.0 + TAU * ring, 96, ring_full_colour, RING_WIDTH, true)
	draw_circle(centre, RING_RADIUS - RING_WIDTH / 2.0, DISC_COLOUR, true, -1.0, true)
	var picture_size := Vector2.ONE * SettingsPicture.PICTURE_PX
	SettingsPicture.draw_picture(self, picture, Rect2(centre - picture_size / 2.0, picture_size), SettingsPicture.FILL_COLOUR)
