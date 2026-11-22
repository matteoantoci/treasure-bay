## The dark layer and the light disc of the Sea friend reveal (game-flow spec part 6, fix 5). At the
## reveal the screen gets darker, and a soft light disc shows in the middle of the Labyrinth area.
## The Collection strip and the Sea friend are above this layer in the main scene, so the slot
## stays clear.
class_name RevealView
extends Node2D

## The texture of the light disc: a radial gradient from the light colour in the centre to 0 at
## the edge of the texture.
const LIGHT_TEXTURE_PX := 256

## The rectangle that the dark layer covers: the visible rectangle.
var dark_rect := Rect2()
var light_centre := Vector2.ZERO
var light_radius := 0.0
var _light := GradientTexture2D.new()
var _tween: Tween


func _init() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, Motion.REVEAL_LIGHT_COLOUR)
	gradient.set_color(1, Color(Motion.REVEAL_LIGHT_COLOUR, 0.0))
	_light.gradient = gradient
	_light.fill = GradientTexture2D.FILL_RADIAL
	_light.fill_from = Vector2(0.5, 0.5)
	_light.fill_to = Vector2(1.0, 0.5)
	_light.width = LIGHT_TEXTURE_PX
	_light.height = LIGHT_TEXTURE_PX
	stop()


## Covers `visible_rect`. The light disc is in the middle of `labyrinth_area`.
func layout(visible_rect: Rect2, labyrinth_area: Rect2) -> void:
	dark_rect = visible_rect
	light_centre = labyrinth_area.get_center()
	light_radius = Motion.REVEAL_LIGHT_RADIUS_SHARE * visible_rect.size.y
	queue_redraw()


## The screen gets darker in 250 ms, and the light disc shows.
func show_reveal() -> void:
	stop()
	visible = true
	_tween = create_tween()
	Motion.shape(_tween.tween_property(self, "modulate:a", 1.0, Motion.REVEAL_DARK_SECONDS), Motion.REVEAL_DARK_CURVE)


## The dark layer and the light disc fade out in `seconds` with `curve`.
func fade_out(seconds: float, curve: Motion.Easing) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	Motion.shape(_tween.tween_property(self, "modulate:a", 0.0, seconds), curve)
	_tween.tween_callback(stop)


## Ends the reveal at once. The screen is clear.
func stop() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
	modulate.a = 0.0
	visible = false


## The colour that the dark layer adds over the screen now.
func dark_colour() -> Color:
	return Color(Motion.REVEAL_DARK_COLOUR, Motion.REVEAL_DARK_COLOUR.a * _shown_alpha())


## The colour of the centre of the light disc now.
func light_colour() -> Color:
	return Color(Motion.REVEAL_LIGHT_COLOUR, Motion.REVEAL_LIGHT_COLOUR.a * _shown_alpha())


func _shown_alpha() -> float:
	return modulate.a if visible else 0.0


func _draw() -> void:
	draw_rect(dark_rect, Motion.REVEAL_DARK_COLOUR)
	var size := Vector2.ONE * 2.0 * light_radius
	draw_texture_rect(_light, Rect2(light_centre - size / 2.0, size), false)
