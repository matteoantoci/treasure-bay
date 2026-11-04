## The fade between Labyrinths (spec 8.8): a dark rectangle over the whole screen. Above it, at the
## start of a new Area, the first Item kind of that Area grows big in the centre, stays, and fades
## out.
class_name FadeView
extends Node2D

var dark := ColorRect.new()
var area_item := Sprite2D.new()
var _tweens := []


func _init() -> void:
	dark.name = "Dark"
	area_item.name = "AreaItem"
	dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dark.color = Color(Motion.FADE_COLOUR, 0.0)
	area_item.visible = false
	add_child(dark)
	add_child(area_item)


## Covers the visible rectangle. The Area Item is in its centre.
func layout(visible_rect: Rect2) -> void:
	dark.position = visible_rect.position
	dark.size = visible_rect.size
	area_item.position = visible_rect.get_center()


## The screen is dark at once.
func set_dark() -> void:
	stop()
	dark.color.a = 1.0


## Fades the screen to dark in 500 ms.
func fade_out() -> Tween:
	return _fade_to(1.0)


## Fades the screen in from dark in 500 ms.
func fade_in() -> Tween:
	return _fade_to(0.0)


## Shows the Item `kind` in the centre: it grows from 0 to 2 times `item_px` in 400 ms, stays for
## 600 ms, then fades out in 400 ms. It does not fly and does not fill an outline.
func show_area_item(kind: String, item_px: float) -> void:
	area_item.texture = load(Area.item_texture_path(kind))
	var size_scale := Vector2.ONE * item_px / maxf(area_item.texture.get_width(), area_item.texture.get_height())
	area_item.scale = Vector2.ZERO
	area_item.modulate.a = 1.0
	area_item.visible = true
	var tween := _new_tween()
	Motion.shape(tween.tween_property(area_item, "scale", size_scale * Motion.AREA_ITEM_SCALE, Motion.AREA_ITEM_GROW_SECONDS), Motion.AREA_ITEM_GROW_CURVE)
	tween.tween_interval(Motion.AREA_ITEM_STAY_SECONDS)
	tween.tween_property(area_item, "modulate:a", 0.0, Motion.AREA_ITEM_FADE_SECONDS)
	tween.tween_callback(area_item.hide)


## Ends the fade and the Area Item at once. The screen is clear.
func stop() -> void:
	for tween in _tweens:
		tween.kill()
	_tweens.clear()
	dark.color.a = 0.0
	area_item.visible = false


func _fade_to(alpha: float) -> Tween:
	var tween := _new_tween()
	Motion.shape(tween.tween_property(dark, "color:a", alpha, Motion.FADE_SECONDS), Motion.FADE_CURVE)
	return tween


func _new_tween() -> Tween:
	_tweens = _tweens.filter(func(tween: Tween) -> bool: return tween.is_valid())
	var tween := create_tween()
	_tweens.append(tween)
	return tween
