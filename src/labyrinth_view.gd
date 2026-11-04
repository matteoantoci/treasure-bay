## Draws the islands of a Labyrinth with the Kenney tiles (spec 7.1): a TileMapLayer for the coasts
## and the grass, the rocks and bushes of the wall islands, and the palm and the closed chest on
## the Goal island (spec 6.2). The water is the Water node below. The tile (0, 0) is at the node
## position. IslandLook picks the tiles. The palm sways (spec 8.2), and the chest opens at the
## start of the Goal celebration (spec 8.5).
class_name LabyrinthView
extends Node2D

## The Kenney tiles are 128 x 128 px.
const KENNEY_TILE_PX := 128
const KENNEY_TILES_DIR := "res://assets/kenney/tiles/"
const CHEST_CLOSED := preload("res://assets/sprites/goal/chest_closed.png")
const CHEST_OPEN := preload("res://assets/sprites/goal/chest_open.png")
## The chest is 100 px of the prototype tile (spec 10, Open gap 3).
const CHEST_PX := 100.0
## Sizes of a whole Kenney tile picture, in Labyrinth tiles: a rock or bush fills the grass top of
## its island, and the palm crown is larger than the chest.
const DECORATION_TILES := 0.5
const PALM_TILES := 0.7
## On the Goal island tile, the chest is at the side next to the Goal square and the palm at the
## far side, on the sand (Open gap 3). Centres in tiles from the top-left corner of the tile.
const CHEST_PLACE := Vector2(0.3, 0.56)
const PALM_PLACE := Vector2(0.78, 0.42)

static var _tile_set: TileSet

var labyrinth: Labyrinth:
	set(value):
		labyrinth = value
		_show_look()

var tile_px := 0.0:
	set(value):
		tile_px = value
		_place()

## The palm and the chest of the Goal island.
var palm := Sprite2D.new()
var chest := Sprite2D.new()
## Seconds of palm sway.
var time := 0.0

var _islands := TileMapLayer.new()
## Labyrinth tile -> the Sprite2D of its rock or bush.
var _decorations := {}
var _decoration_layer := Node2D.new()


func _init() -> void:
	_islands.name = "Islands"
	_decoration_layer.name = "Decorations"
	palm.name = "Palm"
	chest.name = "Chest"
	_islands.tile_set = kenney_tile_set()
	palm.texture = load(kenney_tile_path(IslandLook.PALM))
	chest.texture = CHEST_CLOSED
	add_child(_islands)
	add_child(_decoration_layer)
	add_child(palm)
	add_child(chest)


static func kenney_tile_path(number: int) -> String:
	return KENNEY_TILES_DIR + "tile_%02d.png" % number


## One TileSet for all Labyrinths: one TileSetAtlasSource for each Kenney tile PNG, with the tile
## number as its source ID.
static func kenney_tile_set() -> TileSet:
	if _tile_set != null:
		return _tile_set
	_tile_set = TileSet.new()
	_tile_set.tile_size = Vector2i.ONE * KENNEY_TILE_PX
	for file_name in DirAccess.get_files_at(KENNEY_TILES_DIR):
		if not (file_name.begins_with("tile_") and file_name.ends_with(".png")):
			continue
		var source := TileSetAtlasSource.new()
		source.texture = load(KENNEY_TILES_DIR + file_name)
		source.texture_region_size = Vector2i.ONE * KENNEY_TILE_PX
		# One tile fills each texture, so no padding is needed against its neighbours. Without
		# padding, the tile draws the imported texture with its mipmaps.
		source.use_texture_padding = false
		source.create_tile(Vector2i.ZERO)
		_tile_set.add_source(source, file_name.trim_prefix("tile_").trim_suffix(".png").to_int())
	return _tile_set


## The Kenney tile number of a Kenney cell of the island layer, or -1 for water.
func island_tile_at(cell: Vector2i) -> int:
	return _islands.get_cell_source_id(cell)


## Labyrinth tile -> Kenney tile number of the rock or bush on it.
func decorations() -> Dictionary:
	var numbers := {}
	for tile: Vector2i in _decorations:
		numbers[tile] = _decorations[tile].get_meta("kenney_tile")
	return numbers


## The chest shows chest_open.png in place of chest_closed.png.
func open_chest() -> void:
	chest.texture = CHEST_OPEN


func _process(delta: float) -> void:
	time += delta
	palm.rotation = Motion.palm_sway(time)


func _show_look() -> void:
	_islands.clear()
	chest.texture = CHEST_CLOSED
	for sprite: Sprite2D in _decorations.values():
		sprite.queue_free()
	_decorations.clear()
	if labyrinth == null:
		return
	var look := IslandLook.build(labyrinth)
	for cell: Vector2i in look.cells:
		_islands.set_cell(cell, look.cells[cell], Vector2i.ZERO)
	for tile: Vector2i in look.decorations:
		var sprite := Sprite2D.new()
		sprite.texture = load(kenney_tile_path(look.decorations[tile]))
		sprite.set_meta("kenney_tile", look.decorations[tile])
		_decoration_layer.add_child(sprite)
		_decorations[tile] = sprite
	_place()


func _place() -> void:
	_islands.scale = Vector2.ONE * tile_px / IslandLook.CELLS_PER_TILE / KENNEY_TILE_PX
	if labyrinth == null:
		return
	for tile: Vector2i in _decorations:
		_fit(_decorations[tile], (Vector2(tile) + Vector2(0.5, 0.5)) * tile_px, DECORATION_TILES * tile_px)
	var goal_island := Vector2(labyrinth.goal_island_tile())
	_fit(chest, (goal_island + CHEST_PLACE) * tile_px, CHEST_PX * ScreenLayout.labyrinth_scale(tile_px))
	_fit(palm, (goal_island + PALM_PLACE) * tile_px, PALM_TILES * tile_px)


func _fit(sprite: Sprite2D, centre: Vector2, px: float) -> void:
	var size := sprite.texture.get_size()
	var rect := ScreenLayout.sprite_rect(centre, size, px)
	sprite.position = rect.get_center()
	sprite.scale = rect.size / size
