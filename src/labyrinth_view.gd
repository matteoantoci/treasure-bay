## Draws the island tiles of a Labyrinth in plain colours. The water is the Water node below.
## The tile (0, 0) is at the node position.
class_name LabyrinthView
extends Node2D

const ISLAND_COLOUR := Color("#f1d58e")
const GOAL_ISLAND_COLOUR := Color("#4fc35a")
const GOAL_MARK_COLOUR := Color("#ffd54a")

var labyrinth: Labyrinth:
	set(value):
		labyrinth = value
		queue_redraw()

var tile_px := 0.0:
	set(value):
		tile_px = value
		queue_redraw()


func _draw() -> void:
	if labyrinth == null or tile_px <= 0.0:
		return
	var count := labyrinth.tile_count()
	var goal_island := labyrinth.goal_island_tile()
	for y in count.y:
		for x in count.x:
			var tile := Vector2i(x, y)
			if labyrinth.is_water_tile(tile):
				continue
			var colour := GOAL_ISLAND_COLOUR if tile == goal_island else ISLAND_COLOUR
			draw_rect(Rect2(Vector2(tile) * tile_px, Vector2.ONE * tile_px), colour)
	draw_circle((Vector2(goal_island) + Vector2(0.5, 0.5)) * tile_px, tile_px * 0.25, GOAL_MARK_COLOUR)
