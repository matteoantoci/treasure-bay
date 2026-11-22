## Draws the islands of a Labyrinth with the Kenney tiles (spec 7.1): a TileMapLayer for the coasts
## and the grass, the rocks and bushes of the wall islands, and the palm and the closed chest on
## the Goal island of 2 tiles (spec 6.2, game-flow spec part 5, fix 4). The water is the Water node
## below. The tile (0, 0) is at the node position. IslandLook picks the tiles. The palm sways (spec
## 8.2). The chest has a padlock while an Item is not collected (game-flow spec Part 2). The locked
## chest shakes at a visit, and the padlock pops off at the unlock. The open chest sparkles like an
## Item, and it opens at the start of the Goal celebration (spec 8.5). The open chest hops for the
## idle hint (game-flow spec part 5, fix 10).
class_name LabyrinthView
extends Node2D

## The Kenney tiles are 128 x 128 px.
const KENNEY_TILE_PX := 128
const KENNEY_TILES_DIR := "res://assets/kenney/tiles/"
const CHEST_CLOSED := preload("res://assets/sprites/goal/chest_closed.png")
const CHEST_OPEN := preload("res://assets/sprites/goal/chest_open.png")
const PADLOCK := preload("res://assets/sprites/goal/padlock.png")
## The chest is 115 % of a tile wide (game-flow spec part 5, fix 4). Both chest pictures are wider
## than tall.
const CHEST_TILES := 1.15
## Sizes of a whole Kenney tile picture, in Labyrinth tiles. A rock or bush fills the grass top of
## its island. The palm is smaller than the chest, so it stays inside the coast of the outer tile.
const DECORATION_TILES := 0.5
const PALM_TILES := 0.6
## Centres in tiles from the top-left corner of the Goal island tile. The chest sits on the seam of
## the Goal island tile and the outer tile, fully on land. The palm sits on the outer tile, up and
## to the right of the chest, inside the coast.
const CHEST_PLACE := Vector2(1.0, 0.5)
const PALM_PLACE := Vector2(1.66, 0.32)
## The padlock is 36 % of a tile tall. It hangs from the hasp on the front of the chest, right of
## the chest centre. Its centre in tiles from the chest centre:
const PADLOCK_TILES := 0.36
const PADLOCK_OFFSET := Vector2(0.19, 0.14)
## The palm is darker than the grass, so the Child sees the Goal island.
const PALM_COLOUR := Color(0.7, 0.85, 0.7)

static var _tile_set: TileSet

var labyrinth: Labyrinth:
	set(value):
		labyrinth = value
		_show_look()

var tile_px := 0.0:
	set(value):
		tile_px = value
		_place()

## The palm, the chest, and the padlock of the Goal island.
var palm := Sprite2D.new()
var chest := Sprite2D.new()
var padlock := Sprite2D.new()
## The Item sparkle of the open chest (spec 8.2), with the Item count as its Item index.
var chest_sparkle := Polygon2D.new()
## Seconds of palm sway and chest sparkle.
var time := 0.0
## True while an Item of the Labyrinth is not collected: the padlock shows, and the chest does not
## sparkle (game-flow spec Part 2). A pop of the padlock stops.
var locked := false:
	set(value):
		locked = value
		if _padlock_pop != null:
			_padlock_pop.kill()
		padlock.visible = value
		padlock.modulate.a = 1.0
		_place_chest()
		_idle()
## The sideways offset of the chest and its padlock during the shake, in px of the 130 px tile.
var chest_shake_px := 0.0:
	set(value):
		chest_shake_px = value
		_place_chest()
## The phase of the idle hint hop of the chest, from 0 to 1 (game-flow spec part 5, fix 10). 0 is
## the rest place.
var chest_hop := 0.0:
	set(value):
		chest_hop = value
		_place_chest()

var _islands := TileMapLayer.new()
## Labyrinth tile -> the Sprite2D of its rock or bush.
var _decorations := {}
var _decoration_layer := Node2D.new()
var _shake: Tween
var _padlock_pop: Tween
var _chest_hop: Tween
## The scale of the padlock without the pop.
var _padlock_scale := Vector2.ONE


func _init() -> void:
	_islands.name = "Islands"
	_decoration_layer.name = "Decorations"
	palm.name = "Palm"
	chest.name = "Chest"
	padlock.name = "Padlock"
	chest_sparkle.name = "ChestSparkle"
	_islands.tile_set = kenney_tile_set()
	palm.texture = load(kenney_tile_path(IslandLook.PALM))
	palm.modulate = PALM_COLOUR
	chest.texture = CHEST_CLOSED
	padlock.texture = PADLOCK
	padlock.visible = false
	add_child(_islands)
	add_child(_decoration_layer)
	add_child(palm)
	add_child(chest)
	add_child(padlock)
	add_child(chest_sparkle)


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


## The chest shows chest_open.png in place of chest_closed.png, with no padlock, and it stops its
## sparkle.
func open_chest() -> void:
	chest.texture = CHEST_OPEN
	if locked:
		locked = false
	_idle()


## A visit to the locked chest: the chest and its padlock shake sideways by the offsets of
## Motion.CHEST_SHAKE_PX, linear (game-flow spec Part 2). A new shake starts from the rest place.
func shake_chest() -> Tween:
	if _shake != null:
		_shake.kill()
	chest_shake_px = Motion.CHEST_SHAKE_PX[0]
	_shake = create_tween()
	var step: float = Motion.CHEST_SHAKE_SECONDS / (Motion.CHEST_SHAKE_PX.size() - 1)
	for offset: float in Motion.CHEST_SHAKE_PX.slice(1):
		_shake.tween_property(self, "chest_shake_px", offset, step)
	return _shake


## The last Item is in its slot: the chest is open at once, so it sparkles, and the padlock grows
## to 1.3 times its size and fades out (game-flow spec Part 2).
func pop_padlock() -> Tween:
	locked = false
	padlock.visible = true
	_padlock_pop = create_tween().set_parallel()
	Motion.shape(_padlock_pop.tween_property(padlock, "scale", _padlock_scale * Motion.PADLOCK_POP_SCALE, Motion.PADLOCK_POP_SECONDS), Motion.PADLOCK_POP_CURVE)
	Motion.shape(_padlock_pop.tween_property(padlock, "modulate:a", 0.0, Motion.PADLOCK_POP_SECONDS), Motion.PADLOCK_POP_CURVE)
	_padlock_pop.chain().tween_callback(padlock.hide)
	return _padlock_pop


## The idle hint: the chest hops one time, up and back with a landing squash (game-flow spec part
## 5, fix 10). The values are in Motion. A new hop starts from the rest place.
func hop_chest() -> Tween:
	if _chest_hop != null:
		_chest_hop.kill()
	chest_hop = 0.0
	_chest_hop = create_tween()
	_chest_hop.tween_property(self, "chest_hop", 1.0, Motion.HINT_HOP_SECONDS)
	return _chest_hop


func _process(delta: float) -> void:
	time += delta
	_idle()


func _is_chest_closed() -> bool:
	return chest.texture == CHEST_CLOSED


func _idle() -> void:
	palm.rotation = Motion.palm_sway(time)
	var alpha := 0.0
	if labyrinth != null and _is_chest_closed() and not locked:
		alpha = Motion.item_sparkle_alpha(time, labyrinth.items.size())
	chest_sparkle.visible = alpha > 0.0
	chest_sparkle.color = Color(Motion.SPARKLE_COLOUR, alpha)


func _show_look() -> void:
	_islands.clear()
	chest.texture = CHEST_CLOSED
	if _shake != null:
		_shake.kill()
	chest_shake_px = 0.0
	if _chest_hop != null:
		_chest_hop.kill()
	chest_hop = 0.0
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
	_idle()


func _place() -> void:
	_islands.scale = Vector2.ONE * tile_px / IslandLook.CELLS_PER_TILE / KENNEY_TILE_PX
	if labyrinth == null:
		return
	for tile: Vector2i in _decorations:
		_fit(_decorations[tile], (Vector2(tile) + Vector2(0.5, 0.5)) * tile_px, DECORATION_TILES * tile_px)
	var goal_island := Vector2(labyrinth.goal_island_tile())
	_fit(palm, (goal_island + PALM_PLACE) * tile_px, PALM_TILES * tile_px)
	_place_chest()


## Places the chest on the seam of the Goal island, moved by the shake and the hint hop, with the
## padlock on its front and the sparkle at its corner.
func _place_chest() -> void:
	if labyrinth == null:
		return
	var s := ScreenLayout.labyrinth_scale(tile_px)
	var centre := (Vector2(labyrinth.goal_island_tile()) + CHEST_PLACE) * tile_px + Vector2(chest_shake_px * s, 0.0)
	_fit(chest, centre, CHEST_TILES * tile_px)
	IdleHint.place_hop(chest, chest.position, chest.scale, chest_hop, tile_px)
	_fit(padlock, centre + PADLOCK_OFFSET * tile_px, PADLOCK_TILES * tile_px)
	_padlock_scale = padlock.scale
	chest_sparkle.position = chest.position + Motion.SPARKLE_OFFSET_PX * s
	chest_sparkle.polygon = Burst.star_points(Vector2.ZERO, Motion.SPARKLE_RADIUS_PX * s)


func _fit(sprite: Sprite2D, centre: Vector2, px: float) -> void:
	var size := sprite.texture.get_size()
	var rect := ScreenLayout.sprite_rect(centre, size, px)
	sprite.position = rect.get_center()
	sprite.scale = rect.size / size
