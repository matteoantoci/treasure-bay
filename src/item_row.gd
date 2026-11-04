## The Item row at the top: one outline for each Item of this Labyrinth, in placement order
## (spec 6.1, 10). An empty outline is the Item sprite at 35 % opacity, drawn grey and light
## (spec 8.7). A collected Item fills its outline: the normal sprite shows on top. The row never
## gets smaller.
class_name ItemRow
extends Node2D

const OUTLINE_SHADER := preload("res://src/item_outline.gdshader")
const EMPTY_OPACITY := 0.35

## The Item kind of each outline.
var kinds := PackedStringArray()
## True for each filled outline.
var filled: Array[bool] = []
## For each outline: the grey sprite and the normal sprite on top of it.
var outlines: Array[Sprite2D] = []
var fills: Array[Sprite2D] = []
var _visible_size := Vector2.ZERO
var _outline_material := ShaderMaterial.new()


func _init() -> void:
	_outline_material.shader = OUTLINE_SHADER


## Shows one outline for each Item of `labyrinth`. The outlines of collected Items are filled.
func show_items(labyrinth: Labyrinth, progress: Progress) -> void:
	for sprite in outlines + fills:
		sprite.queue_free()
	kinds.clear()
	filled.clear()
	outlines.clear()
	fills.clear()
	for item in labyrinth.items:
		var texture: Texture2D = load(Area.item_texture_path(item.kind))
		var outline := Sprite2D.new()
		outline.texture = texture
		outline.material = _outline_material
		outline.modulate.a = EMPTY_OPACITY
		var fill := Sprite2D.new()
		fill.texture = texture
		add_child(outline)
		add_child(fill)
		kinds.append(item.kind)
		filled.append(false)
		outlines.append(outline)
		fills.append(fill)
		_show_fill(filled.size() - 1, progress.is_collected(item.id))
	_place()


func fill(index: int) -> void:
	_show_fill(index, true)


func layout(visible_size: Vector2) -> void:
	_visible_size = visible_size
	_place()


func _show_fill(index: int, is_filled: bool) -> void:
	filled[index] = is_filled
	fills[index].modulate.a = 1.0 if is_filled else 0.0


func _place() -> void:
	var centres := ScreenLayout.item_outline_centres(_visible_size, kinds.size())
	var px := ScreenLayout.item_outline_px(_visible_size)
	for i in kinds.size():
		var size := outlines[i].texture.get_size()
		var scale_factor := ScreenLayout.sprite_rect(centres[i], size, px).size / size
		for sprite: Sprite2D in [outlines[i], fills[i]]:
			sprite.position = centres[i]
			sprite.scale = scale_factor
