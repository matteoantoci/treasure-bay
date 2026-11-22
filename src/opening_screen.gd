## The opening screen (game-flow spec part 3, prototype round 2, variant B). From the top to the
## bottom: the still water of Area 1, the title "Treasure Bay" in an arc, an all-land island of
## 4 x 3 Labyrinth tiles from the Kenney tiles, the closed chest with its sparkle, four bobbing
## Items, and the wide start button. The gear of the main scene stays above it. The main scene
## shows it at each launch and after each Parent reset, and it starts the game on a press.
class_name OpeningScreen
extends Node2D

const TITLE := "Treasure Bay"
## The values below are px at a visible height of 1200 px. The logo scales with the visible height
## and stays in the centre of the visible width. x is from the centre, y from the top.
const REFERENCE_HEIGHT := 1200.0
const ISLAND_TILES := Vector2i(4, 3)
const ISLAND_TILE_PX := 165.0
const ISLAND_CENTRE := Vector2(0, 590)
## The PRNG seed of the tile variants of the island.
const ISLAND_SEED := 1
## The chest is 22 % of the visible height tall.
const CHEST_HEIGHT := 0.22 * REFERENCE_HEIGHT
const CHEST_CENTRE := Vector2(0, 570)
## The four Items on the island, with their centres from the island centre.
const ITEM_KINDS: PackedStringArray = ["spiral_shell", "starfish", "pearl", "coral"]
const ITEM_PLACES: Array[Vector2] = [Vector2(-235, 84), Vector2(235, 84), Vector2(-195, -110), Vector2(195, -110)]
const ITEM_PX := 84.0
## Each Item bobs 2 sin(2 t + i) px.
const ITEM_BOB_PX := 2.0
## The title: each letter on a circle arc, one advance width of the font after the other.
const TITLE_FONT_PX := 126
const TITLE_OUTLINE_PX := 16
const TITLE_FILL := Color("#ffe07a")
const TITLE_OUTLINE := Color("#7a4a24")
const TITLE_SHADOW := Color(0, 0, 0, 0.25)
const TITLE_SHADOW_OFFSET := Vector2(0, 9)
const TITLE_ARC_CENTRE := Vector2(0, 775)
const TITLE_RADIUS := 600.0
## The centre of the start button.
const BUTTON_CENTRE := Vector2(0, 1010)
## The fade to dark after the press.
const FADE_OUT_SECONDS := 0.8

## Seconds of the bob and the sparkle.
var time := 0.0
var water := WaterView.new()
## The logo and the button, scaled with the visible height.
var logo := Node2D.new()
var island: TileMapLayer
var chest := Sprite2D.new()
var chest_sparkle := Polygon2D.new()
var items: Array[Sprite2D] = []
var title := ArcTitle.new()
var button := StartButton.new()


func _init() -> void:
	water.name = "Water"
	logo.name = "Logo"
	chest.name = "Chest"
	chest_sparkle.name = "ChestSparkle"
	title.name = "Title"
	button.name = "StartButton"
	water.show_area(Area.for_labyrinth(1))
	add_child(water)
	add_child(logo)
	island = new_island(ISLAND_TILES, ISLAND_TILE_PX, ISLAND_CENTRE, ISLAND_SEED)
	island.name = "Island"
	logo.add_child(island)
	chest.texture = LabyrinthView.CHEST_CLOSED
	chest.position = CHEST_CENTRE
	chest.scale = Vector2.ONE * CHEST_HEIGHT / chest.texture.get_height()
	logo.add_child(chest)
	# The sparkle has the size and the place of the chest sparkle of the play screen, for this chest.
	var s := chest_px().x / (LabyrinthView.CHEST_TILES * ScreenLayout.PROTOTYPE_TILE_PX)
	chest_sparkle.position = CHEST_CENTRE + Motion.SPARKLE_OFFSET_PX * s
	chest_sparkle.polygon = Burst.star_points(Vector2.ZERO, Motion.SPARKLE_RADIUS_PX * s)
	logo.add_child(chest_sparkle)
	for kind in ITEM_KINDS:
		var sprite := Sprite2D.new()
		sprite.texture = load(Area.item_texture_path(kind))
		sprite.scale = Vector2.ONE * ITEM_PX / maxf(sprite.texture.get_width(), sprite.texture.get_height())
		logo.add_child(sprite)
		items.append(sprite)
	title.text = TITLE
	logo.add_child(title)
	button.position = BUTTON_CENTRE - StartButton.SIZE / 2.0
	logo.add_child(button)
	_idle()


## The size of the chest sprite on the screen at a visible height of 1200 px.
func chest_px() -> Vector2:
	return chest.texture.get_size() * chest.scale


## An all-land island of `tiles` Labyrinth tiles from the Kenney tiles, with the island rules of the
## game (IslandLook.block()), `tile_px` px for each Labyrinth tile, centred on `centre`. The opening
## screen and the Party show it (game-flow spec parts 3 and 4).
static func new_island(tiles: Vector2i, tile_px: float, centre: Vector2, seed_value: int) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.tile_set = LabyrinthView.kenney_tile_set()
	var look := IslandLook.block(tiles, seed_value)
	for cell: Vector2i in look.cells:
		layer.set_cell(cell, look.cells[cell], Vector2i.ZERO)
	layer.position = centre - Vector2(tiles) * tile_px / 2.0
	layer.scale = Vector2.ONE * tile_px / IslandLook.CELLS_PER_TILE / LabyrinthView.KENNEY_TILE_PX
	return layer


## Covers the visible rectangle. The logo scales with the visible height.
func layout(visible: Rect2) -> void:
	var u := visible.size.y / REFERENCE_HEIGHT
	logo.scale = Vector2.ONE * u
	logo.position = visible.position + Vector2(visible.size.x / 2.0, 0)
	var island_rect := Rect2(logo.position + (ISLAND_CENTRE - Vector2(ISLAND_TILES) * ISLAND_TILE_PX / 2.0) * u,
		Vector2(ISLAND_TILES) * ISLAND_TILE_PX * u)
	water.layout(visible, island_rect, ISLAND_TILE_PX * u)


## Shows the screen with the button ready for a press.
func open() -> void:
	button.reset()
	visible = true


func _process(delta: float) -> void:
	time += delta
	_idle()


## The Items bob, and the chest sparkles like the closed chest of the play screen. Nothing else
## moves, except the pulse of the button.
func _idle() -> void:
	for i in items.size():
		items[i].position = ISLAND_CENTRE + ITEM_PLACES[i] + Vector2(0, ITEM_BOB_PX * sin(Motion.ITEM_BOB_RATE * time + i))
	var alpha := Motion.item_sparkle_alpha(time, ITEM_KINDS.size())
	chest_sparkle.visible = alpha > 0.0
	chest_sparkle.color = Color(Motion.SPARKLE_COLOUR, alpha)


## The title on a circle arc. Each letter sits on the arc with the advance width of the font, so
## the gaps between the letters are even. Fill, outline, and a soft shadow below.
class ArcTitle extends Node2D:
	var text := "":
		set(value):
			text = value
			queue_redraw()
	var font := GameFont.bold()

	## The angle of the centre of each letter, in radians from the top of the arc. 0 is the
	## middle of the text.
	func letter_angles() -> PackedFloat32Array:
		var advances := letter_advances()
		var total := 0.0
		for advance in advances:
			total += advance
		var angles := PackedFloat32Array()
		var along := -total / 2.0
		for advance in advances:
			angles.append((along + advance / 2.0) / TITLE_RADIUS)
			along += advance
		return angles

	## The advance width of each letter in px.
	func letter_advances() -> PackedFloat32Array:
		var advances := PackedFloat32Array()
		for letter in text:
			advances.append(font.get_char_size(letter.unicode_at(0), TITLE_FONT_PX).x)
		return advances

	func _draw() -> void:
		var angles := letter_angles()
		var advances := letter_advances()
		# The letter box centre is on the arc.
		var baseline := (font.get_ascent(TITLE_FONT_PX) - font.get_descent(TITLE_FONT_PX)) / 2.0
		for pass_index in 3:
			for i in text.length():
				var a := angles[i]
				var centre := TITLE_ARC_CENTRE + Vector2(sin(a), -cos(a)) * TITLE_RADIUS
				var origin := Vector2(-advances[i] / 2.0, baseline)
				if pass_index == 0:
					draw_set_transform(centre + TITLE_SHADOW_OFFSET, a)
					draw_char_outline(font, origin, text[i], TITLE_FONT_PX, TITLE_OUTLINE_PX, TITLE_SHADOW)
				else:
					draw_set_transform(centre, a)
					if pass_index == 1:
						draw_char_outline(font, origin, text[i], TITLE_FONT_PX, TITLE_OUTLINE_PX, TITLE_OUTLINE)
					else:
						draw_char(font, origin, text[i], TITLE_FONT_PX, TITLE_FILL)
		draw_set_transform(Vector2.ZERO)
