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
		var chest_px: float = (view.chest.texture.get_size() * view.chest.scale).x
		t.assert_true(absf(chest_px - 60.0 * tile_px / 130.0) < 0.01, label + "chest is 60 px of the 130 px tile")
		t.assert_true(not view.decorations().values().has(IslandLook.PALM), label + "no palm on a wall island")
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
	row.fill(1)
	t.assert_eq(row.fills[1].modulate.a, 1.0, "a filled outline shows the normal sprite")
	await Scene.remove(t, main)
	return true


func test_the_gear_is_in_the_top_right_corner(t) -> bool:
	var main := await Scene.add_main(t)
	var visible: Vector2 = main.get_viewport().get_visible_rect().size
	t.assert_eq(main.get_node("Gear").get_rect(), ScreenLayout.gear_rect(visible), "gear rectangle")
	await Scene.remove(t, main)
	return true
