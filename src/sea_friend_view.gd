## The Sea friend of the Goal celebration (spec 8.6): it grows next to the Goal island, wiggles,
## then flies to its slot in the Collection strip and shrinks to the strip icon size.
class_name SeaFriendView
extends Sprite2D

var _tweens := []


## Grows from 0 to 1.3 times 110 px at (+60, +60) px from the Goal island centre, at the far side
## from the chest (Motion.FRIEND_START_PX), and moves up to 30 px above the island centre. `s` is
## the Labyrinth scale of spec 8.1.
func appear(friend_texture: Texture2D, island_centre: Vector2, s: float) -> void:
	stop()
	texture = friend_texture
	position = island_centre + Motion.FRIEND_START_PX * s
	rotation = 0.0
	scale = Vector2.ZERO
	visible = true
	var tween := _new_tween().set_parallel()
	Motion.shape(tween.tween_property(self, "scale", _scale_for(Motion.FRIEND_PX * s) * Motion.FRIEND_SCALE, Motion.FRIEND_GROW_SECONDS), Motion.FRIEND_GROW_CURVE)
	Motion.shape(tween.tween_property(self, "position:y", island_centre.y - Motion.FRIEND_RISE_PX * s, Motion.FRIEND_GROW_SECONDS), Motion.FRIEND_GROW_CURVE)


## Turns from -0.15 rad to +0.15 rad, then back to 0.
func wiggle() -> void:
	rotation = -Motion.FRIEND_WIGGLE_RAD
	var tween := _new_tween()
	Motion.shape(tween.tween_property(self, "rotation", Motion.FRIEND_WIGGLE_RAD, Motion.FRIEND_WIGGLE_SECONDS), Motion.FRIEND_WIGGLE_CURVE)
	Motion.shape(tween.tween_property(self, "rotation", 0.0, Motion.FRIEND_WIGGLE_SECONDS), Motion.FRIEND_WIGGLE_CURVE)


## Flies to the strip slot centre and shrinks to `icon_px`.
func fly_to(slot_centre: Vector2, icon_px: float) -> void:
	var tween := _new_tween().set_parallel()
	Motion.shape(tween.tween_property(self, "position", slot_centre, Motion.FRIEND_FLY_SECONDS), Motion.FRIEND_FLY_CURVE)
	Motion.shape(tween.tween_property(self, "scale", _scale_for(icon_px), Motion.FRIEND_FLY_SECONDS), Motion.FRIEND_FLY_CURVE)


## Ends the motion and hides the Sea friend.
func stop() -> void:
	for tween in _tweens:
		tween.kill()
	_tweens.clear()
	visible = false


## The scale that gives the longer side of the texture `px`.
func _scale_for(px: float) -> Vector2:
	return Vector2.ONE * px / maxf(texture.get_width(), texture.get_height())


func _new_tween() -> Tween:
	_tweens = _tweens.filter(func(tween: Tween) -> bool: return tween.is_valid())
	var tween := create_tween()
	_tweens.append(tween)
	return tween
