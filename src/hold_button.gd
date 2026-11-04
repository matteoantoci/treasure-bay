## A button that acts only after a hold of 3 s: the reset and the quit button (spec 11.2). A ring
## around the picture fills while the button is down. If the button comes up before 3 s, the ring
## goes back to empty and nothing happens.
class_name HoldButton
extends PictureButton

## Emitted when the button was down for the whole hold time.
signal held

const HOLD_SECONDS := 3.0
## The button is this big, so the ring fits around the 64 px picture.
const BUTTON_PX := 112.0
const RING_RADIUS := 48.0
const RING_WIDTH := 8.0
const RING_EMPTY_COLOUR := Color(1, 1, 1, 0.25)
const RING_FULL_COLOUR := Color("#ffd447")

## The time of a full hold. Tests set a shorter time.
var hold_seconds := HOLD_SECONDS
## How full the ring is, from 0 to 1.
var ring := 0.0
var _held_seconds := 0.0
var _down := false


func _init(picture_kind := SettingsPicture.Kind.RESET) -> void:
	super(picture_kind)
	custom_minimum_size = Vector2.ONE * BUTTON_PX
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


func _draw() -> void:
	var centre := size / 2.0
	draw_arc(centre, RING_RADIUS, 0.0, TAU, 64, SettingsPicture.OUTLINE_COLOUR, RING_WIDTH + 2.0 * SettingsPicture.OUTLINE_WIDTH, true)
	draw_arc(centre, RING_RADIUS, 0.0, TAU, 64, RING_EMPTY_COLOUR, RING_WIDTH, true)
	if ring > 0.0:
		draw_arc(centre, RING_RADIUS, -PI / 2.0, -PI / 2.0 + TAU * ring, 64, RING_FULL_COLOUR, RING_WIDTH, true)
	super()
