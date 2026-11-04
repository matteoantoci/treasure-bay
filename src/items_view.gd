## Draws the Items that are still on the water, one Sprite2D for each Item (spec 6.1). Each Item
## bobs, and a small white sparkle shows next to it from time to time (spec 8.2). The tile (0, 0)
## is at the node position.
class_name ItemsView
extends Node2D

## The Item size in px of the prototype tile (spec 10).
const ITEM_PX := 90.0

## Seconds of idle motion.
var time := 0.0
var _tile_px := 0.0
## Item ID -> Item, for the Items on the water, in placement order.
var _items := {}
## Item ID -> its Sprite2D.
var _sprites := {}
## Item ID -> its index in the Labyrinth: the phase of its bob and its sparkle.
var _indexes := {}
## Item ID -> the sprite centre without the bob.
var _centres := {}
var _sparkles := Node2D.new()


func _init() -> void:
	# The sparkles draw on top of the Items.
	_sparkles.name = "Sparkles"
	_sparkles.z_index = 1
	_sparkles.draw.connect(_draw_sparkles)
	add_child(_sparkles)


## Shows the Items of `labyrinth` that the Child has not collected.
func show_items(labyrinth: Labyrinth, progress: Progress) -> void:
	for sprite: Sprite2D in _sprites.values():
		sprite.queue_free()
	_items.clear()
	_sprites.clear()
	_indexes.clear()
	for i in labyrinth.items.size():
		var item := labyrinth.items[i]
		if progress.is_collected(item.id):
			continue
		var sprite := Sprite2D.new()
		sprite.texture = load(Area.item_texture_path(item.kind))
		add_child(sprite)
		_items[item.id] = item
		_sprites[item.id] = sprite
		_indexes[item.id] = i
	_place()


## The collected Item leaves the water.
func remove_item(item_id: String) -> void:
	if not _sprites.has(item_id):
		return
	_sprites[item_id].queue_free()
	_sprites.erase(item_id)
	_items.erase(item_id)
	_indexes.erase(item_id)


## The IDs of the Items on the water, in placement order.
func shown_ids() -> PackedStringArray:
	return PackedStringArray(_items.keys())


## The Item sprite on the water, or null.
func sprite_of(item_id: String) -> Sprite2D:
	return _sprites.get(item_id)


func item_px() -> float:
	return ITEM_PX * ScreenLayout.labyrinth_scale(_tile_px)


func set_tile_px(tile_px: float) -> void:
	_tile_px = tile_px
	_place()


func _process(delta: float) -> void:
	time += delta
	_bob()
	_sparkles.queue_redraw()


func _place() -> void:
	_centres.clear()
	for item_id: String in _sprites:
		var sprite: Sprite2D = _sprites[item_id]
		var centre := (Vector2(Labyrinth.square_to_tile(_items[item_id].square)) + Vector2(0.5, 0.5)) * _tile_px
		var rect := ScreenLayout.sprite_rect(centre, sprite.texture.get_size(), item_px())
		_centres[item_id] = rect.get_center()
		sprite.scale = rect.size / sprite.texture.get_size()
	_bob()


func _bob() -> void:
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	for item_id: String in _sprites:
		_sprites[item_id].position = _centres[item_id] + Vector2(0, Motion.item_bob(time, _indexes[item_id]) * s)


## A white 8-point sparkle at (+18, -18) px from each Item centre, while it shows.
func _draw_sparkles() -> void:
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	for item_id: String in _sprites:
		var alpha := Motion.item_sparkle_alpha(time, _indexes[item_id])
		if alpha <= 0.0:
			continue
		var centre: Vector2 = _sprites[item_id].position + Motion.SPARKLE_OFFSET_PX * s
		_sparkles.draw_colored_polygon(Burst.star_points(centre, Motion.SPARKLE_RADIUS_PX * s), Color(Motion.SPARKLE_COLOUR, alpha))
