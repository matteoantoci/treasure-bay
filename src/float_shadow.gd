## The still shadow of a sprite on the water (game-flow spec part 5, fix 8): the light comes from the
## top left, so the shadow is a black ellipse below the sprite and a little to the right. The boat
## and the Items on the water have it. The Item column and the Collection strip have no shadow.
class_name FloatShadow
extends RefCounted

const COLOUR := Color(0, 0, 0, 0.2)
## Parts of the sprite size: the ellipse width and height, and its centre from the sprite centre.
const SIZE := Vector2(0.8, 0.22)
const OFFSET := Vector2(0.05, 0.28)


## The ellipse box of the shadow of a sprite of `sprite_px` (its longer side) at `centre`.
static func rect(centre: Vector2, sprite_px: float) -> Rect2:
	var size := SIZE * sprite_px
	return Rect2(centre + OFFSET * sprite_px - size / 2.0, size)


## Draws the ellipse of `box` on `canvas`, with `base` from the box coordinates to the canvas item.
static func draw(canvas: CanvasItem, box: Rect2, base := Transform2D.IDENTITY) -> void:
	var squash := Transform2D(0.0, Vector2(1.0, box.size.y / box.size.x), 0.0, box.get_center())
	canvas.draw_set_transform_matrix(base * squash)
	canvas.draw_circle(Vector2.ZERO, box.size.x / 2.0, COLOUR, true, -1.0, true)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
