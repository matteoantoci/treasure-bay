## The Item row at the top: one outline for each Item of this Labyrinth, in placement order
## (spec 6.1, 10). An empty outline is the Item sprite at 35 % opacity. A collected Item fills its
## outline. The row never gets smaller.
class_name ItemRow
extends Node2D

const EMPTY_COLOUR := Color(1, 1, 1, 0.35)

## The Item kind of each outline.
var kinds := PackedStringArray()
## True for each filled outline.
var filled: Array[bool] = []
var _textures: Array[Texture2D] = []
var _visible_size := Vector2.ZERO


## Shows one outline for each Item of `labyrinth`. The outlines of collected Items are filled.
func show_items(labyrinth: Labyrinth, progress: Progress) -> void:
	kinds.clear()
	filled.clear()
	_textures.clear()
	for item in labyrinth.items:
		kinds.append(item.kind)
		filled.append(progress.is_collected(item.id))
		_textures.append(load(Area.item_texture_path(item.kind)))
	queue_redraw()


func fill(index: int) -> void:
	filled[index] = true
	queue_redraw()


func layout(visible_size: Vector2) -> void:
	_visible_size = visible_size
	queue_redraw()


func _draw() -> void:
	var centres := ScreenLayout.item_outline_centres(_visible_size, kinds.size())
	var px := ScreenLayout.item_outline_px(_visible_size)
	for i in kinds.size():
		var rect := ScreenLayout.sprite_rect(centres[i], _textures[i].get_size(), px)
		draw_texture_rect(_textures[i], rect, false, Color.WHITE if filled[i] else EMPTY_COLOUR)
