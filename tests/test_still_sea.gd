## The still sea of the game-flow spec, part 5: the background does not move, a still soft foam edge
## follows each coast, the chest and the palm stand on the land of the Goal island of 2 tiles, and
## the boat and the Items on the water have a still shadow (fixes 2, 4 and 8).
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")

## Kenney tile number -> its picture, for the land checks.
var _kenney_images := {}


func _show(main: Node, number: int) -> void:
	var progress := Progress.new()
	progress.labyrinth_number = number
	main.progress = progress
	main.show_labyrinth()


## All values that set the look of the water and the foam.
func _background(main: Node) -> Array:
	var water: WaterView = main.get_node("Water")
	var values := []
	for uniform: Dictionary in water.material.shader.get_shader_uniform_list():
		values.append(water.material.get_shader_parameter(uniform.name))
	var foam: FoamView = main.get_node("Foam")
	for line in foam.lines:
		values.append_array([line.points, line.width, line.default_color])
	return values


func test_nothing_in_the_background_moves(t) -> bool:
	var main := await Scene.add_main(t)
	var water: WaterView = main.get_node("Water")
	var uniforms := []
	for uniform: Dictionary in water.material.shader.get_shader_uniform_list():
		uniforms.append(uniform.name)
	uniforms.sort()
	t.assert_eq(uniforms, ["deep_colour", "labyrinth_origin", "light_colour", "s"], "the water has colours and a place, and no moving parameter")
	t.assert_true(not water.material.shader.code.contains("TIME"), "the water shader does not read the time")
	for number in [1, 6, 11, 16]:
		_show(main, number)
		var label := "Labyrinth %d: " % number
		var before := _background(main)
		for frame in 10:
			await t.process_frame
		t.assert_eq(_background(main), before, label + "the water and the foam stay the same")
		for node_name in ["Water", "AreaDecoration", "Foam"]:
			t.assert_true(not main.get_node(node_name).is_processing(), label + "%s does not change from frame to frame" % node_name)
	await Scene.remove(t, main)
	return true


func test_the_foam_is_a_still_soft_white_line_along_each_coast_under_the_islands(t) -> bool:
	var main := await Scene.add_main(t)
	var foam: FoamView = main.get_node("Foam")
	var labyrinth: Labyrinth = main.labyrinth
	var tile_px: float = main.get_node("LabyrinthView").tile_px
	var s := tile_px / 130.0
	t.assert_true(foam.get_index() < main.get_node("LabyrinthView").get_index(), "the foam is under the islands")
	# The foam starts at the coast, on the water: its centre is half its width from the coast.
	var loops := CoastLine.foam_loops(CoastLine.water_outlines(labyrinth), CoastLine.outer_outline(labyrinth), tile_px, tile_px / IslandLook.CELLS_PER_TILE, 3.0 * s)
	t.assert_eq(foam.lines.size(), loops.size(), "one foam line for each coast")
	for i in loops.size():
		t.assert_eq(foam.lines[i].points, loops[i], "foam line %d follows its coast" % i)
		t.assert_true(is_equal_approx(foam.lines[i].width, 6.0 * s), "foam line %d is 6 px wide" % i)
		t.assert_eq(foam.lines[i].default_color, Color(1, 1, 1, 0.35), "foam line %d is white at 35 %%" % i)
	# Across the line, from one edge (0) to the other (1).
	t.assert_true(FoamView.alpha_across(0.0) < 0.05 and FoamView.alpha_across(1.0) < 0.05, "the foam line has soft edges")
	t.assert_true(is_equal_approx(FoamView.alpha_across(0.5), 1.0), "the foam line is full in its middle")
	await Scene.remove(t, main)
	return true


func test_the_chest_and_the_palm_stand_on_the_goal_island_in_all_20_labyrinths(t) -> bool:
	var tile_px := 130.0
	for number in range(1, 21):
		var view := LabyrinthView.new()
		view.tile_px = tile_px
		view.labyrinth = LabyrinthPlan.build(number)
		var label := "Labyrinth %d: " % number
		var goal := Vector2(view.labyrinth.goal_island_tile())
		var chest_size := view.chest.texture.get_size() * view.chest.scale
		t.assert_true(is_equal_approx(chest_size.x, 1.15 * tile_px), label + "the chest is 115 %% of a tile wide (%.3f)" % (chest_size.x / tile_px))
		t.assert_true(is_equal_approx(view.chest.position.x, (goal.x + 1.0) * tile_px), label + "the chest sits on the seam of the 2 tiles")
		t.assert_eq(_off_land(view, view.chest), 0, label + "the chest is fully on land")
		var outer := Rect2((goal + Vector2.RIGHT) * tile_px, Vector2.ONE * tile_px)
		t.assert_true(outer.has_point(view.palm.position), label + "the palm sits on the outer tile")
		t.assert_true(view.palm.position.x > view.chest.position.x and view.palm.position.y < view.chest.position.y, label + "the palm is up and to the right of the chest")
		for rotation in [-Motion.PALM_SWAY_RAD, 0.0, Motion.PALM_SWAY_RAD]:
			view.palm.rotation = rotation
			t.assert_eq(_off_land(view, view.palm), 0, label + "the palm is inside the coast at %.2f rad" % rotation)
		view.free()
	return true


func test_the_boat_has_a_still_shadow_that_moves_with_it(t) -> bool:
	var main := await Scene.add_main(t)
	var boat: BoatView = main.get_node("Boat")
	var s: float = main.get_node("LabyrinthView").tile_px / 130.0
	var length := BoatView.LENGTH_PX * s
	var shadow := boat.shadow_rect()
	t.assert_true(shadow.size.is_equal_approx(Vector2(0.8, 0.22) * length), "the shadow is 80 %% of the boat wide and 22 %% high: %s" % (shadow.size / length))
	var offset := shadow.get_center() - boat.position
	t.assert_true(is_equal_approx(offset.y, 0.28 * length), "the shadow is 28 %% of the boat below its centre (%.3f)" % (offset.y / length))
	t.assert_true(offset.x > 0.0 and offset.x <= 0.1 * length, "the shadow is a little to the right (%.3f)" % (offset.x / length))
	t.assert_eq(FloatShadow.COLOUR, Color(0, 0, 0, 0.2), "the shadow is black at 20 %")
	boat.time = 1.0
	boat.hop_scale = Motion.HOP_SCALE
	t.assert_eq(boat.shadow_rect(), shadow, "the shadow does not rock, bob or hop")
	boat.hop_scale = 1.0
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "the boat moves")
	t.assert_true(boat.shadow_rect().get_center().is_equal_approx(boat.position + offset), "the shadow moves with the boat")
	t.assert_true(boat.shadow_rect().size.is_equal_approx(shadow.size), "the shadow does not turn with the boat")
	await Scene.remove(t, main)
	return true


func test_each_item_on_the_water_has_a_still_shadow(t) -> bool:
	var main := await Scene.add_main(t)
	var items: ItemsView = main.get_node("Items")
	var labyrinth: Labyrinth = main.labyrinth
	var tile_px: float = main.get_node("LabyrinthView").tile_px
	var item_px := items.item_px()
	var shadows := items.shadow_rects()
	t.assert_eq(shadows.keys(), Array(items.shown_ids()), "one shadow for each Item on the water")
	for item in labyrinth.items:
		var centre := (Vector2(Labyrinth.square_to_tile(item.square)) + Vector2(0.5, 0.5)) * tile_px
		var shadow: Rect2 = shadows[item.id]
		t.assert_true(shadow.size.is_equal_approx(Vector2(0.8, 0.22) * item_px), "Item %s: the shadow is 80 %% wide and 22 %% high" % item.id)
		var offset := shadow.get_center() - centre
		t.assert_true(is_equal_approx(offset.y, 0.28 * item_px), "Item %s: the shadow is 28 %% below the Item centre" % item.id)
		t.assert_true(offset.x > 0.0 and offset.x <= 0.1 * item_px, "Item %s: the shadow is a little to the right" % item.id)
	items.time = 0.7
	items._process(0.0)
	t.assert_eq(items.shadow_rects(), shadows, "the shadows do not bob with the Items")
	var collected := labyrinth.items[0].id
	items.remove_item(collected)
	t.assert_true(not items.shadow_rects().has(collected), "a collected Item leaves its shadow on the water: no shadow in the Item column")
	await Scene.remove(t, main)
	return true


## The count of opaque pixels of `sprite` (sampled every 4 px of its picture) that are not over the
## land of the Kenney island tiles.
func _off_land(view: LabyrinthView, sprite: Sprite2D) -> int:
	var image := _image_of(sprite.texture)
	var cell_px := view.tile_px / IslandLook.CELLS_PER_TILE
	var off := 0
	for y in range(0, image.get_height(), 4):
		for x in range(0, image.get_width(), 4):
			if image.get_pixel(x, y).a < 0.5:
				continue
			var local := (Vector2(x, y) + Vector2(0.5, 0.5) - image.get_size() / 2.0) * sprite.scale
			var point := sprite.position + local.rotated(sprite.rotation)
			var cell := Vector2i((point / cell_px).floor())
			var number := view.island_tile_at(cell)
			if number < 0:
				off += 1
				continue
			var kenney := _kenney_image(number)
			var inside := (point - Vector2(cell) * cell_px) / cell_px * float(LabyrinthView.KENNEY_TILE_PX)
			var pixel := Vector2i(inside.floor()).clamp(Vector2i.ZERO, kenney.get_size() - Vector2i.ONE)
			if kenney.get_pixelv(pixel).a < 0.5:
				off += 1
	return off


func _kenney_image(number: int) -> Image:
	if not _kenney_images.has(number):
		_kenney_images[number] = _image_of(load(LabyrinthView.kenney_tile_path(number)))
	return _kenney_images[number]


func _image_of(texture: Texture2D) -> Image:
	var image := texture.get_image()
	if image.is_compressed():
		image.decompress()
	return image
