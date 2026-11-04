## The Kenney boat with the white sail, 54 x 86 px at a 130 px tile (spec 7.1, 10). The node scale
## sets the tile size. The bow of boat_white_sail.png points down at rotation 0.
class_name BoatView
extends Node2D

const TEXTURE := preload("res://assets/kenney/ships/boat_white_sail.png")
## The longer side in px of the prototype tile (ScreenLayout.PROTOTYPE_TILE_PX).
const LENGTH_PX := 86.0


func set_tile_px(tile_px: float) -> void:
	scale = Vector2.ONE * ScreenLayout.labyrinth_scale(tile_px)


func _draw() -> void:
	draw_texture_rect(TEXTURE, ScreenLayout.sprite_rect(Vector2.ZERO, TEXTURE.get_size(), LENGTH_PX), false)
