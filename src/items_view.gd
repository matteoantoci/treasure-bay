## Draws the Items that are still on the water, one Sprite2D for each Item (spec 6.1). The tile
## (0, 0) is at the node position.
class_name ItemsView
extends Node2D

## The Item size in px of the prototype tile (spec 10).
const ITEM_PX := 60.0

var _tile_px := 0.0
## Item ID -> Item, for the Items on the water, in placement order.
var _items := {}
## Item ID -> its Sprite2D.
var _sprites := {}


## Shows the Items of `labyrinth` that the Child has not collected.
func show_items(labyrinth: Labyrinth, progress: Progress) -> void:
	for sprite: Sprite2D in _sprites.values():
		sprite.queue_free()
	_items.clear()
	_sprites.clear()
	for item in labyrinth.items:
		if progress.is_collected(item.id):
			continue
		var sprite := Sprite2D.new()
		sprite.texture = load(Area.item_texture_path(item.kind))
		add_child(sprite)
		_items[item.id] = item
		_sprites[item.id] = sprite
	_place()


## The collected Item leaves the water.
func remove_item(item_id: String) -> void:
	if not _sprites.has(item_id):
		return
	_sprites[item_id].queue_free()
	_sprites.erase(item_id)
	_items.erase(item_id)


## The IDs of the Items on the water, in placement order.
func shown_ids() -> PackedStringArray:
	return PackedStringArray(_items.keys())


func set_tile_px(tile_px: float) -> void:
	_tile_px = tile_px
	_place()


func _place() -> void:
	var px := ITEM_PX * ScreenLayout.labyrinth_scale(_tile_px)
	for item_id: String in _sprites:
		var sprite: Sprite2D = _sprites[item_id]
		var centre := (Vector2(Labyrinth.square_to_tile(_items[item_id].square)) + Vector2(0.5, 0.5)) * _tile_px
		var rect := ScreenLayout.sprite_rect(centre, sprite.texture.get_size(), px)
		sprite.position = rect.get_center()
		sprite.scale = rect.size / sprite.texture.get_size()
