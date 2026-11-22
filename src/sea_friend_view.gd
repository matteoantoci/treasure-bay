## The Sea friend of the Goal celebration (spec 8.6, game-flow spec part 6, fix 5): it flips in
## large in the middle of the Labyrinth area, wiggles, then flies to its slot in the Collection
## strip and shrinks to the strip icon size.
class_name SeaFriendView
extends Sprite2D

var _tweens := []


## Flips in at `centre` with its longer side `full_px` long. In the first half of the flip the
## horizontal scale goes from 0 to full and the size from 50 % to 108 %. In the second half the
## size settles at 100 %.
func appear(friend_texture: Texture2D, centre: Vector2, full_px: float) -> void:
	stop()
	texture = friend_texture
	position = centre
	rotation = 0.0
	var full := _scale_for(full_px)
	scale = Vector2(0.0, full.y * Motion.FRIEND_FLIP_START_SIZE)
	visible = true
	var tween := _new_tween().set_parallel()
	var peak := full * Motion.FRIEND_FLIP_PEAK_SIZE
	Motion.shape(tween.tween_property(self, "scale:x", peak.x, Motion.FRIEND_FLIP_HALF_SECONDS), Motion.FRIEND_FLIP_CURVE)
	Motion.shape(tween.tween_property(self, "scale:y", peak.y, Motion.FRIEND_FLIP_HALF_SECONDS), Motion.FRIEND_FLIP_CURVE)
	Motion.shape(tween.chain().tween_property(self, "scale", full, Motion.FRIEND_FLIP_HALF_SECONDS), Motion.FRIEND_FLIP_CURVE)


## Turns from -0.08 rad to +0.08 rad, then back to 0.
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
