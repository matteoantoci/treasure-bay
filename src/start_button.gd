## The wide start button of the opening screen (game-flow spec part 3): a green pill with a white
## border, a darker bottom edge, and a white play triangle. It pulses gently until a press. A left
## click emits `clicked`. The main scene decides if the click starts the game.
class_name StartButton
extends Control

## Emitted on a left click on the button.
signal clicked

## The size at a visible height of 1200 px.
const SIZE := Vector2(560, 160)
const FILL_COLOUR := Color("#5ccf6a")
const BORDER_COLOUR := Color.WHITE
const BORDER_PX := 8
const EDGE_COLOUR := Color("#2f8f3c")
## The bottom edge shows below the face: 7 % of the button height.
const EDGE_PART := 0.07
const SHADOW_COLOUR := Color(0, 0, 0, 0.3)
const SHADOW_PX := 24
const SHADOW_OFFSET := Vector2(0, 18)
## The play triangle, in parts of the button height: its half height, its width, and its shift to
## the right of the centre.
const TRIANGLE_HALF_HEIGHT := 0.22
const TRIANGLE_WIDTH := 0.34
const TRIANGLE_SHIFT := 0.04
const TRIANGLE_COLOUR := Color.WHITE
## The pulse: the scale goes from 1.0 to 1.06 and back in 1.6 s.
const PULSE_SCALE := 1.06
const PULSE_SECONDS := 1.6
## The press: the scale goes to 0.86 and back in 140 ms.
const PRESS_SCALE := 0.86
const PRESS_SECONDS := 0.14

## Seconds of the pulse.
var time := 0.0
var _press: Tween
var _edge := StyleBoxFlat.new()
var _face := StyleBoxFlat.new()


func _init() -> void:
	size = SIZE
	pivot_offset = SIZE / 2.0
	var radius := int(SIZE.y / 2.0)
	_edge.bg_color = EDGE_COLOUR
	_edge.set_corner_radius_all(radius)
	_edge.shadow_color = SHADOW_COLOUR
	_edge.shadow_size = SHADOW_PX
	_edge.shadow_offset = SHADOW_OFFSET
	_face.bg_color = FILL_COLOUR
	_face.border_color = BORDER_COLOUR
	_face.set_border_width_all(BORDER_PX)
	_face.set_corner_radius_all(radius)


func _process(delta: float) -> void:
	if is_pressed():
		return
	time += delta
	scale = Vector2.ONE * pulse_scale(time)


## The scale of the pulse at `t` seconds: 1.0 at the start, 1.06 at the half of the period.
static func pulse_scale(t: float) -> float:
	return 1.0 + (PULSE_SCALE - 1.0) * (1.0 - cos(TAU * t / PULSE_SECONDS)) / 2.0


func is_pressed() -> bool:
	return _press != null


## The press motion: the pulse stops, and the button scales to 0.86 and back in 140 ms.
func press() -> void:
	if _press != null:
		_press.kill()
	_press = create_tween()
	_press.tween_property(self, "scale", Vector2.ONE * PRESS_SCALE, PRESS_SECONDS / 2.0)
	_press.tween_property(self, "scale", Vector2.ONE, PRESS_SECONDS / 2.0)


## The button is ready for a new press, and the pulse starts again.
func reset() -> void:
	if _press != null:
		_press.kill()
	_press = null
	time = 0.0
	scale = Vector2.ONE


func _gui_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click != null and click.button_index == MOUSE_BUTTON_LEFT and click.pressed:
		accept_event()
		clicked.emit()


func _draw() -> void:
	draw_style_box(_edge, Rect2(Vector2(0, size.y * EDGE_PART), size))
	draw_style_box(_face, Rect2(Vector2.ZERO, size))
	var centre := size / 2.0 + Vector2(size.y * TRIANGLE_SHIFT, 0)
	var half_width := size.y * TRIANGLE_WIDTH / 2.0
	var half_height := size.y * TRIANGLE_HALF_HEIGHT
	draw_colored_polygon(PackedVector2Array([
		centre + Vector2(-half_width, -half_height),
		centre + Vector2(half_width, 0),
		centre + Vector2(-half_width, half_height),
	]), TRIANGLE_COLOUR)
