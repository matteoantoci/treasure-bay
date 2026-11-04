## Short motions above the HUD, in screen px: the collected Item that pops and flies to its outline
## (spec 8.4), and the bursts of splash dots, sparkles, and confetti (spec 8.4 to 8.6).
class_name EffectsView
extends Node2D


## Pops the Item at `from` (its size `px`), then flies it to `to` while it shrinks. `on_arrive` runs
## at the arrival. The Item flies on its own: it does not make the boat busy (spec 5.4).
func fly_item(texture: Texture2D, from: Vector2, px: float, to: Vector2, on_arrive: Callable) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = from
	var size_scale := Vector2.ONE * px / maxf(texture.get_width(), texture.get_height())
	sprite.scale = size_scale
	add_child(sprite)
	var tween := sprite.create_tween()
	Motion.shape(tween.tween_property(sprite, "scale", size_scale * Motion.ITEM_POP_SCALE, Motion.ITEM_POP_SECONDS), Motion.ITEM_POP_CURVE)
	Motion.shape(tween.tween_property(sprite, "position", to, Motion.ITEM_FLY_SECONDS), Motion.ITEM_FLY_CURVE)
	Motion.shape(tween.parallel().tween_property(sprite, "scale", size_scale * Motion.ITEM_FLY_SCALE, Motion.ITEM_FLY_SECONDS), Motion.ITEM_FLY_CURVE)
	tween.tween_callback(on_arrive)
	tween.tween_callback(sprite.queue_free)


## Starts `burst` at `centre`, scaled by s or h.
func burst(effect: Burst, centre: Vector2, scale_factor: float) -> void:
	effect.fire(self, centre, scale_factor)


## The Items in flight, for tests and screenshots.
func flying_items() -> Array[Sprite2D]:
	var sprites: Array[Sprite2D] = []
	for child in get_children():
		if child is Sprite2D and not child.is_queued_for_deletion():
			sprites.append(child)
	return sprites


## Stops all motion at once, for a new Labyrinth.
func clear() -> void:
	for child in get_children():
		child.queue_free()
