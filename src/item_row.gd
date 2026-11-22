## The Item column at the left (spec 6.1, game-flow spec part 5, fix 3): one slot for each Item of
## this Labyrinth, in placement order. A slot is a light disc with a white outline, and the Item
## sprite in its middle. An empty slot shows the ghost of its Item: the sprite at 35 % opacity, drawn
## grey and light (spec 8.7), with a thin dark edge around its shape. A collected Item fills its
## slot: the normal sprite shows on top, and the ghost goes. The column never gets shorter. When the
## Item arrives at its slot, the slot fills in 150 ms and the Item bounces (spec 8.4). At a visit to
## the locked chest, each empty slot pulses (game-flow spec Part 2).
class_name ItemRow
extends Node2D

const OUTLINE_SHADER := preload("res://src/item_outline.gdshader")
## The opacity of the grey sprite of the ghost (spec 8.7).
const EMPTY_OPACITY := 0.35
## The edge of the ghost (code review fix of ticket 12). A light ghost on the light disc of Areas 1
## and 2 has a contrast of 1.3:1 to 1.4:1, so the sand dollar and the pearl do not show. The edge
## gives the rim of the ghost 3:1 or more in each Area: against the disc in Areas 1 to 3, and against
## the grey sprite on the dark disc of Area 4.
const GHOST_EDGE_COLOUR := Color("#0a1428", 0.8)
## The width of the ghost edge in pixels of the 512 px Item sprites: about 2 px on a disc of 120 px.
const GHOST_EDGE_TEXELS := 12.0
## The Item sprite, as a part of the disc diameter.
const ITEM_SHARE := 0.7
const DISC_FILL_COLOUR := Color(1, 1, 1, 0.22)
const DISC_OUTLINE_COLOUR := Color(1, 1, 1, 0.85)
## px at a visible height of 1200 px.
const DISC_OUTLINE_PX := 3.0
## A thin dark edge outside the white outline. White on the light water of Areas 1 and 2 has less
## than 3:1 contrast, the edge gives the outline 3:1 or more against the colour next to it.
const DISC_EDGE_COLOUR := Color("#0a1428", 0.6)
const DISC_EDGE_PX := 1.5

## The Item kind of each slot.
var kinds := PackedStringArray()
## True for each slot of a collected Item. The slot fills when the Item arrives (show_fill).
var filled: Array[bool] = []
## For each slot: its disc, the grey sprite, and the normal sprite on top of it.
var discs: Array[SlotDisc] = []
var outlines: Array[Sprite2D] = []
var fills: Array[Sprite2D] = []
var _visible_size := Vector2.ZERO
var _outline_material := ShaderMaterial.new()
## The scale of each Item sprite without the bounce.
var _scales: Array[Vector2] = []
var _tweens := []
## Slot index -> the Tween of its pulse.
var _pulses := {}


func _init() -> void:
	_outline_material.shader = OUTLINE_SHADER
	_outline_material.set_shader_parameter("body_opacity", EMPTY_OPACITY)
	_outline_material.set_shader_parameter("edge_colour", GHOST_EDGE_COLOUR)
	_outline_material.set_shader_parameter("edge_texels", GHOST_EDGE_TEXELS)


## Shows one slot for each Item of `labyrinth`. The slots of collected Items are filled.
func show_items(labyrinth: Labyrinth, progress: Progress) -> void:
	for tween in _tweens + _pulses.values():
		tween.kill()
	_tweens.clear()
	_pulses.clear()
	for node in discs + outlines + fills:
		node.queue_free()
	kinds.clear()
	filled.clear()
	discs.clear()
	outlines.clear()
	fills.clear()
	for item in labyrinth.items:
		var texture: Texture2D = load(Area.item_texture_path(item.kind))
		var disc := SlotDisc.new()
		var outline := Sprite2D.new()
		outline.texture = texture
		outline.material = _outline_material
		var fill := Sprite2D.new()
		fill.texture = texture
		add_child(disc)
		add_child(outline)
		add_child(fill)
		kinds.append(item.kind)
		filled.append(false)
		discs.append(disc)
		outlines.append(outline)
		fills.append(fill)
		_show_fill(filled.size() - 1, progress.is_collected(item.id))
	_place()


## The Item of slot `index` is collected. Its slot stays empty until the Item arrives.
func collect(index: int) -> void:
	filled[index] = true


## Each empty slot pulses two times: scale 1.0 to 1.15 and back, 300 ms each. The disc and the Item
## sprite pulse together. The opacity does not change. A pulse that runs starts again. Returns the
## Tween of each pulse.
func pulse_empty() -> Array[Tween]:
	var pulses: Array[Tween] = []
	for index in kinds.size():
		if filled[index]:
			continue
		_stop_pulse(index)
		var tween := create_tween()
		_pulses[index] = tween
		for i in Motion.SLOT_PULSE_COUNT:
			for factor: float in [Motion.SLOT_PULSE_SCALE, 1.0]:
				var size := _scales[index] * factor
				Motion.shape(tween.tween_property(outlines[index], "scale", size, Motion.SLOT_PULSE_SECONDS), Motion.SLOT_PULSE_CURVE)
				Motion.shape(tween.parallel().tween_property(fills[index], "scale", size, Motion.SLOT_PULSE_SECONDS), Motion.SLOT_PULSE_CURVE)
				Motion.shape(tween.parallel().tween_property(discs[index], "scale", Vector2.ONE * factor, Motion.SLOT_PULSE_SECONDS), Motion.SLOT_PULSE_CURVE)
		pulses.append(tween)
	return pulses


## The Item arrives at slot `index`: the normal sprite fades in on top in 150 ms, the ghost fades out
## in the same time, and the Item bounces from 1.5 times its size to its size in 350 ms. The disc does
## not bounce.
func show_fill(index: int) -> Tween:
	_stop_pulse(index)
	_tweens = _tweens.filter(func(tween: Tween) -> bool: return tween.is_valid())
	var tween := create_tween().set_parallel()
	_tweens.append(tween)
	fills[index].modulate.a = 0.0
	Motion.shape(tween.tween_property(fills[index], "modulate:a", 1.0, Motion.OUTLINE_FILL_SECONDS), Motion.OUTLINE_FILL_CURVE)
	Motion.shape(tween.tween_property(outlines[index], "modulate:a", 0.0, Motion.OUTLINE_FILL_SECONDS), Motion.OUTLINE_FILL_CURVE)
	for sprite: Sprite2D in [outlines[index], fills[index]]:
		sprite.scale = _scales[index] * Motion.OUTLINE_BOUNCE_SCALE
		Motion.shape(tween.tween_property(sprite, "scale", _scales[index], Motion.OUTLINE_BOUNCE_SECONDS), Motion.OUTLINE_BOUNCE_CURVE)
	return tween


## The centre of slot `index` on the screen.
func slot_centre(index: int) -> Vector2:
	return discs[index].position


## The pulse of slot `index` stops, and the slot gets its size back.
func _stop_pulse(index: int) -> void:
	if not _pulses.has(index):
		return
	_pulses[index].kill()
	_pulses.erase(index)
	outlines[index].scale = _scales[index]
	fills[index].scale = _scales[index]
	discs[index].scale = Vector2.ONE


func layout(visible_size: Vector2) -> void:
	_visible_size = visible_size
	_place()


func _show_fill(index: int, is_filled: bool) -> void:
	filled[index] = is_filled
	fills[index].modulate.a = 1.0 if is_filled else 0.0
	outlines[index].modulate.a = 0.0 if is_filled else 1.0


func _place() -> void:
	var centres := ScreenLayout.item_slot_centres(_visible_size, kinds.size())
	var diameter := ScreenLayout.item_slot_px(_visible_size, kinds.size())
	_scales.clear()
	for i in kinds.size():
		discs[i].position = centres[i]
		discs[i].diameter = diameter
		discs[i].outline_px = ScreenLayout.scaled_px(_visible_size, DISC_OUTLINE_PX)
		discs[i].edge_px = ScreenLayout.scaled_px(_visible_size, DISC_EDGE_PX)
		discs[i].queue_redraw()
		var size := outlines[i].texture.get_size()
		var scale_factor := ScreenLayout.sprite_rect(centres[i], size, ITEM_SHARE * diameter).size / size
		_scales.append(scale_factor)
		for sprite: Sprite2D in [outlines[i], fills[i]]:
			sprite.position = centres[i]
			sprite.scale = scale_factor


## The disc of one slot: the light fill, the dark edge on its rim, and the white outline inside the
## edge. The edge and the outline are inside the diameter, so the gap between two discs stays
## free. Its position is the slot centre.
class SlotDisc:
	extends Node2D

	## The antialiased rim reaches about half a px outside the radius that Godot draws.
	const ANTIALIAS_PX := 0.5

	var diameter := 0.0
	var outline_px := 0.0
	var edge_px := 0.0

	func _draw() -> void:
		var radius := diameter / 2.0 - ANTIALIAS_PX
		var inner := radius - edge_px
		draw_circle(Vector2.ZERO, inner, DISC_FILL_COLOUR, true, -1.0, true)
		draw_arc(Vector2.ZERO, radius - edge_px / 2.0, 0.0, TAU, 96, DISC_EDGE_COLOUR, edge_px, true)
		draw_arc(Vector2.ZERO, inner - outline_px / 2.0, 0.0, TAU, 96, DISC_OUTLINE_COLOUR, outline_px, true)
