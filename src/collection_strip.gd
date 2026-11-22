## The Collection strip at the bottom of the screen (spec 6.5, 10, game-flow spec part 5, fix 6):
## the spiral shell icon and the total Item count in the rounded font at the left end, and 20 slot
## discs in the order of spec 4.7. A slot shows its Sea friend after the Child gets it. An empty
## slot shows only its disc.
class_name CollectionStrip
extends Node2D

const STRIP_COLOUR := Color(0, 0, 0, 0.25)
const SLOT_FILL_COLOUR := Color(1, 1, 1, 0.14)
const SLOT_OUTLINE_COLOUR := Color(1, 1, 1, 0.45)
## px at a visible height of 1200 px.
const SLOT_OUTLINE_PX := 2.0
const COUNT_COLOUR := Color.WHITE
const COUNT_OUTLINE_COLOUR := Color("#0a1428")
const SHELL_TEXTURE := preload("res://assets/sprites/items/spiral_shell.png")

## The total count. The shell icon sits on its left.
var count_label := Label.new()
var shell := TextureRect.new()
## Sea friend ID -> its texture, for the Sea friends in their slots.
var _shown := {}
var _visible_size := Vector2.ZERO


func _ready() -> void:
	shell.texture = SHELL_TEXTURE
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shell.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(shell)
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count_label.add_theme_font_override("font", GameFont.bold())
	count_label.add_theme_color_override("font_color", COUNT_COLOUR)
	count_label.add_theme_color_override("font_outline_color", COUNT_OUTLINE_COLOUR)
	add_child(count_label)


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
	count_label.text = str(total_items)


## The Sea friends in their slots, in slot order.
func shown_friends() -> PackedStringArray:
	var ids := PackedStringArray()
	for id in SeaFriends.IDS:
		if _shown.has(id):
			ids.append(id)
	return ids


func count_text() -> String:
	return count_label.text


## The centres of the 20 slots on the screen.
func slot_centres() -> PackedVector2Array:
	return ScreenLayout.collection_slot_centres(_visible_size)


func layout(visible_size: Vector2) -> void:
	_visible_size = visible_size
	var area := ScreenLayout.collection_count_rect(visible_size)
	count_label.position = area.position
	count_label.size = area.size
	var font_size := ScreenLayout.collection_count_font_size(visible_size)
	count_label.add_theme_font_size_override("font_size", font_size)
	count_label.add_theme_constant_override("outline_size", roundi(font_size / 8.0))
	var shell_rect := ScreenLayout.collection_shell_rect(visible_size)
	shell.position = shell_rect.position
	shell.size = shell_rect.size
	queue_redraw()


func _draw() -> void:
	var strip := ScreenLayout.bottom_strip_height(_visible_size)
	draw_rect(Rect2(0, _visible_size.y - strip, _visible_size.x, strip), STRIP_COLOUR)
	var slots := slot_centres()
	# The antialiased rim reaches about half a px outside the radius that Godot draws.
	var radius := ScreenLayout.collection_slot_px(_visible_size) / 2.0 - ItemRow.SlotDisc.ANTIALIAS_PX
	var outline := ScreenLayout.scaled_px(_visible_size, SLOT_OUTLINE_PX)
	for centre in slots:
		draw_circle(centre, radius, SLOT_FILL_COLOUR, true, -1.0, true)
		draw_arc(centre, radius - outline / 2.0, 0.0, TAU, 64, SLOT_OUTLINE_COLOUR, outline, true)
	var px := ScreenLayout.collection_icon_px(_visible_size)
	for id: String in _shown:
		var texture: Texture2D = _shown[id]
		draw_texture_rect(texture, ScreenLayout.sprite_rect(slots[SeaFriends.slot_of(id)], texture.get_size(), px), false)
