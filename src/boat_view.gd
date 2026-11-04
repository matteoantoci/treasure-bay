## The Kenney boat with the white sail, 54 x 86 px at a 130 px tile (spec 7.1, 10). The node scale
## sets the tile size, and the node rotation the boat direction. The bow of boat_white_sail.png
## points down at rotation 0.
##
## While the boat does not move, it rocks and bobs (spec 8.2). At the Goal it hops: its height
## grows and comes back (spec 8.5).
class_name BoatView
extends Node2D

const TEXTURE := preload("res://assets/kenney/ships/boat_white_sail.png")
## The longer side in px of the prototype tile (ScreenLayout.PROTOTYPE_TILE_PX).
const LENGTH_PX := 86.0

## True while the boat does not move: it rocks and bobs.
var idle := true
## Seconds of idle motion.
var time := 0.0
## The boat height: 1, and more during a hop.
var hop_scale := 1.0


func set_tile_px(tile_px: float) -> void:
	scale = Vector2.ONE * ScreenLayout.labyrinth_scale(tile_px)


## One hop: the height grows to 1.25 in 150 ms, then comes back to 1 in 250 ms.
func hop() -> void:
	var tween := create_tween()
	Motion.shape(tween.tween_property(self, "hop_scale", Motion.HOP_SCALE, Motion.HOP_UP_SECONDS), Motion.HOP_UP_CURVE)
	Motion.shape(tween.tween_property(self, "hop_scale", 1.0, Motion.HOP_DOWN_SECONDS), Motion.HOP_DOWN_CURVE)


## The rock angle now, in rad.
func rock() -> float:
	return Motion.boat_rock(time) if idle else 0.0


## The bob now, in px of the prototype tile, down on the screen.
func bob() -> float:
	return Motion.boat_bob(time) if idle else 0.0


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	# The bob goes down on the screen, whatever the boat direction.
	draw_set_transform(Vector2(0, bob()).rotated(-rotation), rock(), Vector2(1, hop_scale))
	draw_texture_rect(TEXTURE, ScreenLayout.sprite_rect(Vector2.ZERO, TEXTURE.get_size(), LENGTH_PX), false)
