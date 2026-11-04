## The sea look of the main scene (spec 7, 10): the water fills the screen in the Area colours, the
## islands are Kenney tiles, the Goal island has the palm and the closed chest, and each Area has
## its decoration and Items.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")


func _show(main: Node, number: int) -> void:
	var progress := Progress.new()
	progress.labyrinth_number = number
	progress.random_seed = 777 if LabyrinthPlan.is_random(number) else 0
	main.progress = progress
	main.show_labyrinth()


func test_the_water_fills_the_screen_in_the_area_colours(t) -> bool:
	var main := await Scene.add_main(t)
	var water: WaterView = main.get_node("Water")
	var expected := {1: "#3fb4d8", 5: "#3fb4d8", 6: "#2aa6a0", 11: "#1f6fb5", 16: "#14284f", 21: "#3fb4d8", 26: "#2aa6a0"}
	for number: int in expected:
		_show(main, number)
		t.assert_eq(water.get_rect(), main.get_viewport().get_visible_rect(), "Labyrinth %d: the water covers the screen" % number)
		t.assert_eq(water.material.get_shader_parameter("deep_colour"), Color(expected[number]), "Labyrinth %d: deep colour" % number)
	_show(main, 16)
	t.assert_eq(water.material.get_shader_parameter("light_colour"), Color("#3a5a92"), "Labyrinth 16: light colour")
	await Scene.remove(t, main)
	return true


func test_the_islands_are_kenney_tiles(t) -> bool:
	var main := await Scene.add_main(t)
	var view: LabyrinthView = main.get_node("LabyrinthView")
	var look := IslandLook.build(main.labyrinth)
	var count: Vector2i = main.labyrinth.tile_count() * IslandLook.CELLS_PER_TILE
	var same := true
	for y in count.y:
		for x in count.x:
			var cell := Vector2i(x, y)
			same = same and view.island_tile_at(cell) == look.cells.get(cell, -1)
	t.assert_true(same, "each Kenney cell shows the tile of IslandLook, and water cells show none")
	t.assert_eq(view.decorations(), look.decorations, "rocks and bushes of the wall islands")
	await Scene.remove(t, main)
	return true


func test_the_goal_island_has_the_palm_and_the_closed_chest(t) -> bool:
	var main := await Scene.add_main(t)
	for number in [1, 13, 21]:
		_show(main, number)
		var view: LabyrinthView = main.get_node("LabyrinthView")
		var tile_px: float = view.tile_px
		var island := Rect2(Vector2(main.labyrinth.goal_island_tile()) * tile_px, Vector2.ONE * tile_px)
		var label := "Labyrinth %d: " % number
		t.assert_eq(view.palm.texture.resource_path, "res://assets/kenney/tiles/tile_71.png", label + "palm tile")
		t.assert_eq(view.chest.texture.resource_path, "res://assets/sprites/goal/chest_closed.png", label + "closed chest")
		t.assert_true(view.palm.visible and view.chest.visible, label + "palm and chest show")
		t.assert_true(island.has_point(view.palm.position) and view.palm.position.x > island.get_center().x, label + "palm at the far side of the Goal island")
		t.assert_true(island.has_point(view.chest.position) and view.chest.position.x < island.get_center().x, label + "chest at the side next to the Goal square")
		var grass: Color = view.get_node("Islands").modulate
		t.assert_true(view.palm.modulate.get_luminance() < grass.get_luminance(), label + "the palm is darker than the grass")
		t.assert_true(not view.decorations().values().has(IslandLook.PALM), label + "no palm on a wall island")
	await Scene.remove(t, main)
	return true


## The closed chest shows the Item sparkle of spec 8.2 with i = the Item count. The sparkle is white,
## with a radius of 7 px, at (+18, -18) px from the chest centre. It shows while
## fract(0.7 t + 0.33 i) < 0.15, with alpha 1 - fract / 0.15. The open chest does not sparkle.
## Labyrinth 1 opens its chest, so Labyrinth 20 also checks that a new chest sparkles again.
func test_the_closed_chest_sparkles_like_an_item(t) -> bool:
	var main := await Scene.add_main(t)
	var view: LabyrinthView = main.get_node("LabyrinthView")
	var sparkle: Polygon2D = view.get_node("ChestSparkle")
	# Labyrinth -> [Item count, the first time of full alpha]: fract(0.66) = 0.66, so 0.34 / 0.7 s;
	# fract(2.64) = 0.64, so 0.36 / 0.7 s.
	var cases := {1: [2, 0.485714], 20: [8, 0.514286]}
	for number: int in cases:
		_show(main, number)
		var label := "Labyrinth %d: " % number
		t.assert_eq(main.labyrinth.items.size(), cases[number][0], label + "Item count")
		# 0.1 ms after the cycle time, so the float rounding of the time does not hide the sparkle.
		var start: float = cases[number][1] + 0.0001
		var s := view.tile_px / 130.0
		_at(view, start - 0.01)
		t.assert_true(not sparkle.visible, label + "no sparkle just before its cycle time")
		_at(view, start)
		t.assert_true(sparkle.visible, label + "the sparkle shows")
		t.assert_true(absf(sparkle.color.a - 1.0) < 0.002, label + "at full alpha")
		t.assert_true(sparkle.color.is_equal_approx(Color(1, 1, 1, sparkle.color.a)), label + "white")
		t.assert_true(sparkle.position.is_equal_approx(view.chest.position + Vector2(18, -18) * s), label + "at (+18, -18) px from the chest centre")
		var radius := 0.0
		for point in sparkle.polygon:
			radius = maxf(radius, point.length())
		t.assert_true(absf(radius - 7.0 * s) < 0.001, label + "radius 7 px")
		_at(view, start + 0.075 / 0.7)
		t.assert_true(absf(sparkle.color.a - 0.5) < 0.002, label + "half way through the sparkle")
		_at(view, start + 0.15 / 0.7 + 0.01)
		t.assert_true(not sparkle.visible, label + "no sparkle after 15 % of the cycle")
		_at(view, start + 1.0 / 0.7)
		t.assert_true(sparkle.visible and absf(sparkle.color.a - 1.0) < 0.002, label + "the next sparkle after 1 / 0.7 s")
		view.open_chest()
		_at(view, start)
		t.assert_true(not sparkle.visible, label + "the open chest does not sparkle")
	await Scene.remove(t, main)
	return true


## One frame of the view at `seconds` of palm sway and chest sparkle.
func _at(view: LabyrinthView, seconds: float) -> void:
	view.time = seconds
	view._process(0.0)


## At 1920 x 1200, in the small Labyrinth 1 and the large Labyrinth 20, the Item is 90 px, the
## boat 69 x 110 px, and the chest 100 px of the 130 px tile (play-improvements spec, part 2).
func test_items_boat_and_chest_have_their_sizes_in_labyrinths_1_and_20(t) -> bool:
	var main := await Scene.add_main(t)
	# The headless window is square. The window size of a 16:10 screen gives the visible rect of
	# the Child's screen.
	var window_size: Vector2i = t.root.size
	t.root.size = Vector2i(1920, 1200)
	await t.process_frame
	t.assert_eq(main.get_viewport().get_visible_rect().size, Vector2(1920, 1200), "the screen is 1920 x 1200")
	var tile_px := {1: 121.0, 20: 56.0}
	for number: int in tile_px:
		_show(main, number)
		var view: LabyrinthView = main.get_node("LabyrinthView")
		var items: ItemsView = main.get_node("Items")
		var boat: BoatView = main.get_node("Boat")
		var s: float = view.tile_px / 130.0
		var label := "Labyrinth %d: " % number
		t.assert_eq(view.tile_px, tile_px[number], label + "tile px at 1920 x 1200")
		t.assert_true(items.shown_ids().size() >= 2, label + "Items show")
		for item_id in items.shown_ids():
			var sprite := items.sprite_of(item_id)
			var item_size := sprite.texture.get_size() * sprite.global_scale
			t.assert_true(absf(maxf(item_size.x, item_size.y) - 90.0 * s) < 0.01, label + "Item %s is 90 px" % item_id)
		var hull: Vector2 = boat.hull_rect().size * boat.global_scale
		t.assert_true(absf(hull.y - 110.0 * s) < 0.01, label + "the boat is 110 px long")
		t.assert_true(hull.x >= 69.0 * s and hull.x < 70.0 * s, label + "the boat is 69 px wide (%.2f)" % (hull.x / s))
		var picture := BoatView.TEXTURE.get_size()
		t.assert_true(absf(hull.x / hull.y - picture.x / picture.y) < 0.001, label + "the boat keeps the aspect of its picture")
		var chest: Vector2 = view.chest.texture.get_size() * view.chest.global_scale
		t.assert_true(absf(maxf(chest.x, chest.y) - 100.0 * s) < 0.01, label + "the chest is 100 px")
	t.root.size = window_size
	await Scene.remove(t, main)
	return true


func test_each_area_has_its_decoration(t) -> bool:
	var main := await Scene.add_main(t)
	var decoration: AreaDecoration = main.get_node("AreaDecoration")
	var expected := {
		1: [Area.Decoration.WAVES, 6],
		6: [Area.Decoration.BUBBLES, 3],
		11: [Area.Decoration.DROPLETS, 2],
		16: [Area.Decoration.STARS, 12],
	}
	for number: int in expected:
		_show(main, number)
		t.assert_eq(decoration.decoration, expected[number][0], "Labyrinth %d decoration" % number)
		t.assert_eq(decoration.pieces.size(), expected[number][1], "Labyrinth %d decoration pieces" % number)
		for piece in decoration.pieces:
			var tile := Vector2i(floori(piece.x), floori(piece.y))
			t.assert_true(main.labyrinth.is_water_tile(tile), "Labyrinth %d: decoration on the water" % number)
	t.assert_true(main.get_node("AreaDecoration").get_index() < main.get_node("LabyrinthView").get_index(), "decoration under the islands")
	await Scene.remove(t, main)
	return true


func test_empty_item_outlines_are_grey_and_light(t) -> bool:
	var main := await Scene.add_main(t)
	var row: ItemRow = main.get_node("ItemRow")
	t.assert_eq(row.outlines.size(), 2, "2 outlines in Labyrinth 1")
	for i in row.outlines.size():
		t.assert_eq(row.outlines[i].material.shader.resource_path, "res://src/item_outline.gdshader", "outline %d shader" % i)
		t.assert_true(is_equal_approx(row.outlines[i].modulate.a, 0.35), "outline %d at 35 %% opacity" % i)
		t.assert_eq(row.fills[i].modulate.a, 0.0, "outline %d is empty" % i)
	row.collect(1)
	t.assert_eq(row.fills[1].modulate.a, 0.0, "the outline stays empty until the Item arrives")
	t.assert_true(await t.wait_for(row.show_fill(1).finished, Scene.MOVE_TIMEOUT), "the outline fills")
	t.assert_eq(row.fills[1].modulate.a, 1.0, "a filled outline shows the normal sprite")
	await Scene.remove(t, main)
	return true


func test_the_gear_is_in_the_top_right_corner(t) -> bool:
	var main := await Scene.add_main(t)
	var visible: Vector2 = main.get_viewport().get_visible_rect().size
	t.assert_eq(main.get_node("Gear").get_rect(), ScreenLayout.gear_rect(visible), "gear rectangle")
	await Scene.remove(t, main)
	return true
