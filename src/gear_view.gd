## The gear in the top-right corner (spec 10, game-flow spec part 5, fix 7): a quiet white gear
## with a hole, drawn in code (Open gap 2), 48 px at 40 % opacity, so that the Child does not aim at
## it. A click on it opens or closes the settings of spec 11.2.
class_name GearView
extends Control

## Emitted on a left click. The settings panel opens or closes.
signal pressed

const FILL_COLOUR := Color.WHITE
const OPACITY := 0.4
const TEETH := 8
## Radii as parts of the half size: the tip of a tooth, the body, and the hole.
const TOOTH_RADIUS := 1.0
const BODY_RADIUS := 0.74
const HOLE_RADIUS := 0.3
const HOLE_POINTS := 24


func _ready() -> void:
	# The second click closes the settings while play is paused (spec 11.2).
	process_mode = PROCESS_MODE_ALWAYS
	modulate.a = OPACITY


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


## Two halves, each a simple polygon: the teeth on the outside and the hole on the inside. The two
## halves do not overlap, so the opacity is the same everywhere.
func _draw() -> void:
	var centre := size / 2.0
	var half := minf(size.x, size.y) / 2.0
	for part in 2:
		draw_colored_polygon(_half_outline(centre, half, part), FILL_COLOUR)


## Half `part` of the gear: the teeth from part * TEETH / 2 on, then the hole back. Each half
## starts and ends in the middle of a gap between two teeth.
func _half_outline(centre: Vector2, half: float, part: int) -> PackedVector2Array:
	var step := TAU / TEETH
	var first := part * TEETH / 2
	var start := (first - 0.5) * step
	var end := start + PI
	var points := PackedVector2Array()
	points.append(centre + Vector2.from_angle(start) * BODY_RADIUS * half)
	for k in range(first, first + TEETH / 2):
		for corner: Vector2 in [
			Vector2(-0.30, BODY_RADIUS), Vector2(-0.18, TOOTH_RADIUS),
			Vector2(0.18, TOOTH_RADIUS), Vector2(0.30, BODY_RADIUS),
		]:
			points.append(centre + Vector2.from_angle((k + corner.x) * step) * corner.y * half)
	points.append(centre + Vector2.from_angle(end) * BODY_RADIUS * half)
	for i in HOLE_POINTS + 1:
		points.append(centre + Vector2.from_angle(end - PI * i / HOLE_POINTS) * HOLE_RADIUS * half)
	return points
