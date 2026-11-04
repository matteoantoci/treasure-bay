## The decoration of the Area on the water (spec 7.2, 8.2, Open gap 6): wave crests, bubbles,
## droplets, or stars. They are water effects drawn in code, not sprites. This node is above the
## water and under the islands, the Items, and the boat. The tile (0, 0) is at the node position.
##
## The decoration is still: each piece shows at one moment of its life. A PRNG with seed
## `labyrinth.seed_value + 2` puts the pieces on water tiles with no Item, start, or Goal.
class_name AreaDecoration
extends Node2D

## Sizes in px of the prototype tile (spec 8.1).
const CREST_COUNT := 6
const CREST_SIZE := Vector2(24, 8)
## 1 bubble each second with a life of 3 s: 3 bubbles at a time, 6 to 12 px.
const BUBBLE_AGES: Array[float] = [0.5, 1.5, 2.5]
const BUBBLE_LIFE := 3.0
const BUBBLE_PX: Array[float] = [6.0, 12.0]
## 1 drop each second with a life of 1.5 s: 2 drops at a time.
const DROPLET_AGES: Array[float] = [0.3, 1.1]
const DROPLET_LIFE := 1.5
const DROPLET_SIZE := Vector2(6, 9)
const DROPLET_COLOUR := Color("#c8ecff")
const STAR_COUNT := 12
const STAR_PX: Array[float] = [6.0, 10.0]
const STAR_ALPHA: Array[float] = [0.2, 0.9]
const LINE_WIDTH := 2.0

var decoration := Area.Decoration.WAVES
## Each piece: its centre in tiles, and a value from 0 to 1 that sets its size or its age.
var pieces: Array[Vector3] = []
var _tile_px := 0.0


func show_labyrinth(labyrinth: Labyrinth, area: int) -> void:
	decoration = Area.decoration(area)
	pieces.clear()
	var prng := Prng.new(labyrinth.seed_value + 2)
	var tiles := _free_water_tiles(labyrinth)
	for i in _piece_count():
		var tile := tiles[prng.next() % tiles.size()]
		var jitter := Vector2(prng.next() % 1000, prng.next() % 1000) / 1000.0 - Vector2(0.5, 0.5)
		var centre := Vector2(tile) + Vector2(0.5, 0.5) + 0.5 * jitter
		pieces.append(Vector3(centre.x, centre.y, (prng.next() % 1000) / 1000.0))
	queue_redraw()


func set_tile_px(tile_px: float) -> void:
	_tile_px = tile_px
	queue_redraw()


func _piece_count() -> int:
	match decoration:
		Area.Decoration.WAVES:
			return CREST_COUNT
		Area.Decoration.BUBBLES:
			return BUBBLE_AGES.size()
		Area.Decoration.DROPLETS:
			return DROPLET_AGES.size()
	return STAR_COUNT


## Water tiles with no Item and no boat at the start, and not the Goal square.
func _free_water_tiles(labyrinth: Labyrinth) -> Array[Vector2i]:
	var taken := [Labyrinth.square_to_tile(labyrinth.start_square()), Labyrinth.square_to_tile(labyrinth.goal_square())]
	for item in labyrinth.items:
		taken.append(Labyrinth.square_to_tile(item.square))
	var tiles: Array[Vector2i] = []
	var count := labyrinth.tile_count()
	for y in count.y:
		for x in count.x:
			var tile := Vector2i(x, y)
			if labyrinth.is_water_tile(tile) and not taken.has(tile):
				tiles.append(tile)
	return tiles


func _draw() -> void:
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	for i in pieces.size():
		var centre := Vector2(pieces[i].x, pieces[i].y) * _tile_px
		var value := pieces[i].z
		match decoration:
			Area.Decoration.WAVES:
				_draw_crest(centre, CREST_SIZE * s, LINE_WIDTH * s)
			Area.Decoration.BUBBLES:
				var alpha := 1.0 - BUBBLE_AGES[i] / BUBBLE_LIFE
				var radius := lerpf(BUBBLE_PX[0], BUBBLE_PX[1], value) * s / 2.0
				draw_arc(centre, radius, 0.0, TAU, 24, Color(1, 1, 1, alpha), LINE_WIDTH * s * 0.75, true)
				draw_circle(centre + Vector2(-0.35, -0.35) * radius, radius * 0.25, Color(1, 1, 1, alpha))
			Area.Decoration.DROPLETS:
				var alpha := 1.0 - DROPLET_AGES[i] / DROPLET_LIFE
				_draw_droplet(centre, DROPLET_SIZE * s, Color(DROPLET_COLOUR, alpha))
			Area.Decoration.STARS:
				var alpha := lerpf(STAR_ALPHA[0], STAR_ALPHA[1], value)
				_draw_star(centre, lerpf(STAR_PX[0], STAR_PX[1], value) * s / 2.0, Color(1, 1, 1, alpha))


## A small white wave crest: an arch with a curl at its front tip.
func _draw_crest(centre: Vector2, size: Vector2, width: float) -> void:
	var points := PackedVector2Array()
	for k in 13:
		var u := k / 12.0
		points.append(centre + Vector2((u - 0.5) * size.x, size.y * (0.5 - sin(u * PI))))
	var tip := points[points.size() - 1]
	points.append(tip + Vector2(-0.12 * size.x, -0.35 * size.y))
	draw_polyline(points, Color(1, 1, 1, 0.85), width, true)


## A drop: round at the bottom, pointed at the top.
func _draw_droplet(centre: Vector2, size: Vector2, colour: Color) -> void:
	var radius := size.x / 2.0
	var round_centre := centre + Vector2(0, size.y / 2.0 - radius)
	var points := PackedVector2Array([centre + Vector2(0, -size.y / 2.0)])
	for k in 13:
		var angle := -PI / 6.0 + k * (PI + PI / 3.0) / 12.0
		points.append(round_centre + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, colour)


## A 4-point star.
func _draw_star(centre: Vector2, radius: float, colour: Color) -> void:
	var points := PackedVector2Array()
	for k in 8:
		var angle := k * PI / 4.0 - PI / 2.0
		var r := radius if k % 2 == 0 else radius * 0.35
		points.append(centre + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, colour)
