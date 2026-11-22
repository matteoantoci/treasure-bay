## The wake of the game-flow spec part 5, fix 9: while the boat moves, a soft white dot starts every
## 40 ms just behind the stern, on the move line, a little to the left and to the right in turn.
## Each dot gets smaller and fainter with age, and it lives 0.6 s. This node is above the water and
## under the islands, in the coordinates of the boat.
class_name WakeView
extends Node2D


class Dot:
	var centre: Vector2
	var age := 0.0


## Pixels on each side of the soft dot texture.
const DOT_TEXTURE_PX := 64
## The dot is full white to 50 % of its radius, then it fades out to its edge.
const DOT_SOFT_FROM := 0.5

## The boat that the dots follow.
var boat: Node2D
## While true, new dots start behind the boat.
var active := false
## The dots on the water, oldest first.
var dots: Array[Dot] = []
var _direction := Vector2.DOWN
var _tile_px := 0.0
## Dots due: one more dot starts each time this reaches 1.
var _due := 0.0
## The side of the next dot: 1 or -1.
var _side := 1.0
var _soft_dot: GradientTexture2D


func _init() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.add_point(DOT_SOFT_FROM, Color.WHITE)
	_soft_dot = GradientTexture2D.new()
	_soft_dot.gradient = gradient
	_soft_dot.fill = GradientTexture2D.FILL_RADIAL
	_soft_dot.fill_from = Vector2(0.5, 0.5)
	_soft_dot.fill_to = Vector2(1.0, 0.5)
	_soft_dot.width = DOT_TEXTURE_PX
	_soft_dot.height = DOT_TEXTURE_PX


func set_tile_px(tile_px: float) -> void:
	_tile_px = tile_px


## New dots start behind the boat while it moves in `direction`.
func start(direction: Vector2i) -> void:
	_direction = Vector2(direction)
	active = true


func stop() -> void:
	active = false
	_due = 0.0


## Removes all dots at once, for a new Labyrinth.
func clear() -> void:
	stop()
	dots.clear()
	queue_redraw()


func _process(delta: float) -> void:
	for dot in dots:
		dot.age += delta
	while not dots.is_empty() and dots[0].age >= Motion.WAKE_LIFE:
		dots.pop_front()
	if active and boat != null:
		_due += delta * Motion.WAKE_DOTS_PER_SECOND
		while _due >= 1.0:
			_due -= 1.0
			_add_dot()
	queue_redraw()


func _add_dot() -> void:
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	var dot := Dot.new()
	var side := _direction.orthogonal() * Motion.WAKE_SIDE_PX * _side
	dot.centre = boat.position + (side - _direction * Motion.WAKE_BEHIND_PX) * s
	dots.append(dot)
	_side = -_side


func _draw() -> void:
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	for dot in dots:
		var radius := Motion.wake_dot_radius(dot.age) * s
		var box := Rect2(dot.centre - Vector2.ONE * radius, Vector2.ONE * 2.0 * radius)
		draw_texture_rect(_soft_dot, box, false, Color(1, 1, 1, Motion.wake_dot_alpha(dot.age)))
