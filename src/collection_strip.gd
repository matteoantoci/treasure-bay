## The Collection strip at the bottom of the screen (spec 6.5, 10): the total Item count as a
## number at the left end, and 20 slots in the order of spec 4.7. A slot shows its Sea friend after
## the Child gets it. An empty slot shows nothing.
class_name CollectionStrip
extends Node2D

const STRIP_COLOUR := Color(0, 0, 0, 0.25)
const COUNT_COLOUR := Color.WHITE
const COUNT_OUTLINE_COLOUR := Color("#0a1428")

## Sea friend ID -> its texture, for the Sea friends in their slots.
var _shown := {}
var _visible_size := Vector2.ZERO
var _count := Label.new()


func _ready() -> void:
	_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count.add_theme_color_override("font_color", COUNT_COLOUR)
	_count.add_theme_color_override("font_outline_color", COUNT_OUTLINE_COLOUR)
	add_child(_count)


## Shows the Collection and the total count of `progress`.
func show_progress(progress: Progress) -> void:
	_shown.clear()
	for id in progress.collection:
		show_friend(id)
	set_count(progress.total_items)


## The slot of this Sea friend shows it.
func show_friend(id: String) -> void:
	_shown[id] = load(SeaFriends.texture_path(id))
	queue_redraw()


func set_count(total_items: int) -> void:
	_count.text = str(total_items)


## The Sea friends in their slots, in slot order.
func shown_friends() -> PackedStringArray:
	var ids := PackedStringArray()
	for id in SeaFriends.IDS:
		if _shown.has(id):
			ids.append(id)
	return ids


func count_text() -> String:
	return _count.text


func layout(visible_size: Vector2) -> void:
	_visible_size = visible_size
	var area := ScreenLayout.collection_count_rect(visible_size)
	_count.position = area.position
	_count.size = area.size
	var font_size := ScreenLayout.collection_count_font_size(visible_size)
	_count.add_theme_font_size_override("font_size", font_size)
	_count.add_theme_constant_override("outline_size", roundi(font_size / 8.0))
	queue_redraw()


func _draw() -> void:
	var strip := ScreenLayout.bottom_strip_height(_visible_size)
	draw_rect(Rect2(0, _visible_size.y - strip, _visible_size.x, strip), STRIP_COLOUR)
	var slots := ScreenLayout.collection_slot_centres(_visible_size)
	var px := ScreenLayout.collection_icon_px(_visible_size)
	for id: String in _shown:
		var texture: Texture2D = _shown[id]
		draw_texture_rect(texture, ScreenLayout.sprite_rect(slots[SeaFriends.slot_of(id)], texture.get_size(), px), false)
