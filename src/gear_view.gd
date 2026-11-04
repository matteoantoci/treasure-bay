## The gear in the top-right corner (spec 10): a white gear with a dark outline, drawn in code
## (Open gap 2), 64 px. A click on it opens or closes the settings of spec 11.2.
class_name GearView
extends Control

## Emitted on a left click. The settings panel opens or closes.
signal pressed

const FILL_COLOUR := Color.WHITE
const OUTLINE_COLOUR := Color("#0a1428")
const TEETH := 8
## Radii as parts of the half size: the tip of a tooth, the body, and the hole.
const TOOTH_RADIUS := 0.92
const BODY_RADIUS := 0.68
const HOLE_RADIUS := 0.26
const OUTLINE_WIDTH := 4.0


func _ready() -> void:
	# The second click closes the settings while play is paused (spec 11.2).
	process_mode = PROCESS_MODE_ALWAYS


func _gui_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click != null and click.button_index == MOUSE_BUTTON_LEFT and click.pressed:
		accept_event()
		pressed.emit()


func layout(visible_size: Vector2) -> void:
	var rect := ScreenLayout.gear_rect(visible_size)
	position = rect.position
	size = rect.size
	queue_redraw()


func _draw() -> void:
	var centre := size / 2.0
	var half := minf(size.x, size.y) / 2.0 - OUTLINE_WIDTH / 2.0
	var outline := _gear_outline(centre, half)
	draw_colored_polygon(outline, FILL_COLOUR)
	outline.append(outline[0])
	draw_polyline(outline, OUTLINE_COLOUR, OUTLINE_WIDTH, true)
	draw_circle(centre, half * HOLE_RADIUS, OUTLINE_COLOUR)


## The outline of the gear: each tooth is a trapezoid on the round body.
func _gear_outline(centre: Vector2, half: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var step := TAU / TEETH
	for k in TEETH:
		var angle := k * step
		for corner: Vector2 in [
			Vector2(-0.30, BODY_RADIUS), Vector2(-0.18, TOOTH_RADIUS),
			Vector2(0.18, TOOTH_RADIUS), Vector2(0.30, BODY_RADIUS),
		]:
			var a := angle + corner.x * step
			points.append(centre + Vector2(cos(a), sin(a)) * corner.y * half)
	return points
