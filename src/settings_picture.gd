## A picture of the settings panel (spec 11.2, Open gap 2): a simple white shape with a dark outline,
## drawn in code, 64 px. The panel has pictures only, no words.
class_name SettingsPicture
extends Control

enum Kind { MUSIC, SPEAKER, MINUS, PLUS, RESET, DOOR }

const PICTURE_PX := 64.0
const FILL_COLOUR := Color.WHITE
const OUTLINE_COLOUR := Color("#0a1428")
const OUTLINE_WIDTH := 4.0
## Line widths as parts of the picture size.
const THIN := 0.08
const THICK := 0.16

var kind := Kind.MUSIC:
	set(value):
		kind = value
		queue_redraw()


func _init(picture_kind := Kind.MUSIC) -> void:
	kind = picture_kind
	custom_minimum_size = Vector2.ONE * PICTURE_PX
	mouse_filter = MOUSE_FILTER_IGNORE


func _draw() -> void:
	draw_picture(self, kind, Rect2((size - Vector2.ONE * PICTURE_PX) / 2.0, Vector2.ONE * PICTURE_PX), FILL_COLOUR)


## Draws the picture `kind` in `rect` on `item`: first the dark outline of each part, then the
## parts in `fill`.
static func draw_picture(item: CanvasItem, picture_kind: Kind, rect: Rect2, fill: Color) -> void:
	for outline in [true, false]:
		var pen := _Pen.new(item, rect, OUTLINE_COLOUR if outline else fill, OUTLINE_WIDTH if outline else 0.0)
		match picture_kind:
			Kind.MUSIC:
				# Two eighth notes with one beam.
				pen.circle(Vector2(0.28, 0.76), 0.13)
				pen.circle(Vector2(0.70, 0.68), 0.13)
				pen.line([Vector2(0.39, 0.74), Vector2(0.39, 0.24)], THIN)
				pen.line([Vector2(0.81, 0.66), Vector2(0.81, 0.16)], THIN)
				pen.polygon([Vector2(0.39, 0.20), Vector2(0.81, 0.12), Vector2(0.81, 0.26), Vector2(0.39, 0.34)])
			Kind.SPEAKER:
				pen.polygon([
					Vector2(0.10, 0.38), Vector2(0.28, 0.38), Vector2(0.50, 0.18),
					Vector2(0.50, 0.82), Vector2(0.28, 0.62), Vector2(0.10, 0.62),
				])
				pen.arc(Vector2(0.50, 0.50), 0.18, -0.8, 0.8, THIN)
				pen.arc(Vector2(0.50, 0.50), 0.34, -0.8, 0.8, THIN)
			Kind.MINUS:
				pen.line([Vector2(0.20, 0.50), Vector2(0.80, 0.50)], THICK)
			Kind.PLUS:
				pen.line([Vector2(0.20, 0.50), Vector2(0.80, 0.50)], THICK)
				pen.line([Vector2(0.50, 0.20), Vector2(0.50, 0.80)], THICK)
			Kind.RESET:
				# A circular arrow: an arc of most of a circle, with the arrow head at its end.
				var start := -PI / 2.0 + 0.6
				var end := start + 4.8
				pen.arc(Vector2(0.50, 0.52), 0.28, start, end, THICK * 0.75)
				var base := Vector2(0.50, 0.52) + Vector2.from_angle(end) * 0.28
				var along := Vector2.from_angle(end + PI / 2.0)
				var across := Vector2.from_angle(end)
				pen.polygon([base + along * 0.22, base + across * 0.19, base - across * 0.19])
			Kind.DOOR:
				pen.polygon([Vector2(0.24, 0.08), Vector2(0.76, 0.08), Vector2(0.76, 0.92), Vector2(0.24, 0.92)])
		if not outline and picture_kind == Kind.DOOR:
			_Pen.new(item, rect, OUTLINE_COLOUR, 0.0).circle(Vector2(0.64, 0.52), 0.06)


## Draws parts in picture units: (0, 0) is the top-left corner of the picture and (1, 1) the
## bottom-right corner. `grow` makes each part wider by that many px on each side, for the outline.
class _Pen:
	var item: CanvasItem
	var rect: Rect2
	var colour: Color
	var grow: float

	func _init(canvas_item: CanvasItem, picture_rect: Rect2, pen_colour: Color, pen_grow: float) -> void:
		item = canvas_item
		rect = picture_rect
		colour = pen_colour
		grow = pen_grow

	func point(p: Vector2) -> Vector2:
		return rect.position + p * rect.size

	func circle(centre: Vector2, radius: float) -> void:
		item.draw_circle(point(centre), radius * rect.size.x + grow, colour)

	## A line with round ends through `points`, `width` picture units wide.
	func line(points: Array, width: float) -> void:
		var px := PackedVector2Array()
		for p: Vector2 in points:
			px.append(point(p))
		var w := width * rect.size.x + 2.0 * grow
		item.draw_polyline(px, colour, w, true)
		for p in px:
			item.draw_circle(p, w / 2.0, colour)

	func polygon(points: Array) -> void:
		var px := PackedVector2Array()
		for p: Vector2 in points:
			px.append(point(p))
		item.draw_colored_polygon(px, colour)
		if grow > 0.0:
			px.append(px[0])
			item.draw_polyline(px, colour, 2.0 * grow, true)
			for p in px:
				item.draw_circle(p, grow, colour)

	## An arc with round ends from angle `from` to angle `to`, `width` picture units wide.
	func arc(centre: Vector2, radius: float, from: float, to: float, width: float) -> void:
		var w := width * rect.size.x + 2.0 * grow
		var r := radius * rect.size.x
		item.draw_arc(point(centre), r, from, to, 48, colour, w, true)
		for angle in [from, to]:
			item.draw_circle(point(centre) + Vector2.from_angle(angle) * r, w / 2.0, colour)
