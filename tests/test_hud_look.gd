## The look of the HUD (game-flow spec part 5, fixes 3, 6, 7 and the outline rule of fix 8): the
## Item slots, the Collection strip, the quiet gear, and the settings panel in the cream-and-wood
## style.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")


## Each Item has a disc in the Item column: fill white at 22 %, an outline of 3 px in white at
## 85 %. The Item sprite sits in the middle of its disc.
func test_each_item_has_a_slot_disc_in_the_item_column(t) -> bool:
	var main := await Scene.add_main(t)
	var row: ItemRow = main.get_node("ItemRow")
	var visible: Vector2 = main.get_viewport().get_visible_rect().size
	var centres := ScreenLayout.item_slot_centres(visible, 2)
	t.assert_eq(row.discs.size(), 2, "2 slots in Labyrinth 1")
	for i in 2:
		var disc: ItemRow.SlotDisc = row.discs[i]
		t.assert_eq(row.slot_centre(i), centres[i], "slot %d centre" % i)
		t.assert_eq(disc.position, centres[i], "disc %d centre" % i)
		t.assert_true(is_equal_approx(disc.diameter, ScreenLayout.item_slot_px(visible, 2)), "disc %d diameter" % i)
		t.assert_eq(row.outlines[i].position, centres[i], "Item %d in its slot" % i)
		t.assert_true(row.outlines[i].get_rect().size.x * row.outlines[i].scale.x <= disc.diameter, "Item %d inside its disc" % i)
	t.assert_eq(ItemRow.DISC_FILL_COLOUR, Color(1, 1, 1, 0.22), "disc fill")
	t.assert_eq(ItemRow.DISC_OUTLINE_COLOUR, Color(1, 1, 1, 0.85), "disc outline")
	t.assert_true(is_equal_approx(row.discs[0].outline_px, ScreenLayout.scaled_px(visible, 3.0)), "outline of 3 px at 1200")
	await Scene.remove(t, main)
	return true


## Beat-pals rule C7: the slot outline has a contrast of 3:1 or more against the colours next to
## it, in all 4 Areas. White at 85 % on the light water of Areas 1 and 2 cannot reach 3:1 (2.12 and
## 2.56), so a thin dark edge lies outside the outline. The edge also has 3:1 or more against the
## water where the white outline has less.
func test_the_slot_outline_has_a_contrast_of_3_to_1_in_each_area(t) -> bool:
	for area in range(1, Area.COUNT + 1):
		var water := Area.deep_colour(area)
		var outline := _over(ItemRow.DISC_OUTLINE_COLOUR, water)
		var edge := _over(ItemRow.DISC_EDGE_COLOUR, water)
		var against_edge := _contrast(outline, edge)
		var against_water := maxf(_contrast(outline, water), _contrast(edge, water))
		t.assert_true(against_edge >= 3.0, "Area %d: the outline against the edge (%.2f:1)" % [area, against_edge])
		t.assert_true(against_water >= 3.0, "Area %d: the slot against the water (%.2f:1)" % [area, against_water])
	return true


## Code review fix of ticket 12: the ghost of each empty slot shows on its disc in all 4 Areas. The
## ghost is the Item sprite drawn grey and light at EMPTY_OPACITY (spec 8.7), with a thin dark edge
## around its shape. Its rim has a contrast of 3:1 or more: the edge against the disc, or the body
## against the edge. The body is the mean ghost grey of the sprite. With no edge, the rim is the body
## against the disc: 1.3:1 for the pearl of Area 1 and 1.4:1 for the sand dollar of Area 2.
func test_the_ghost_of_an_empty_slot_shows_on_its_disc_in_each_area(t) -> bool:
	for area in range(1, Area.COUNT + 1):
		var disc := _over(ItemRow.DISC_FILL_COLOUR, Area.deep_colour(area))
		var edge := _over(ItemRow.GHOST_EDGE_COLOUR, disc)
		for kind in Area.item_kinds(area):
			var grey := _ghost_grey(kind)
			var body := _over(Color(grey, grey, grey, ItemRow.EMPTY_OPACITY), disc)
			var rim := maxf(_contrast(edge, disc), _contrast(body, edge))
			t.assert_true(rim >= 3.0, "Area %d, %s: the ghost against its disc (%.2f:1)" % [area, kind, rim])
	return true


## The strip shows 20 slot discs (fill white at 14 %, outline 2 px in white at 45 %), the total
## count in the rounded font with an outline, and the spiral shell icon left of the count.
func test_the_collection_strip_shows_the_count_with_a_shell(t) -> bool:
	var main := await Scene.add_main(t)
	var strip: CollectionStrip = main.get_node("CollectionStrip")
	var visible: Vector2 = main.get_viewport().get_visible_rect().size
	t.assert_eq(strip.slot_centres(), ScreenLayout.collection_slot_centres(visible), "20 slots")
	t.assert_eq(CollectionStrip.SLOT_FILL_COLOUR, Color(1, 1, 1, 0.14), "slot fill")
	t.assert_eq(CollectionStrip.SLOT_OUTLINE_COLOUR, Color(1, 1, 1, 0.45), "slot outline")
	t.assert_eq(CollectionStrip.SLOT_OUTLINE_PX, 2.0, "slot outline of 2 px at 1200")
	t.assert_eq(strip.count_label.get_theme_font("font"), GameFont.bold(), "the count is in the rounded font")
	t.assert_true(strip.count_label.get_theme_constant("outline_size") > 0, "the count has an outline")
	t.assert_true(strip.count_label.get_rect().is_equal_approx(ScreenLayout.collection_count_rect(visible)), "the count place")
	t.assert_eq(strip.shell.texture.resource_path, Area.item_texture_path("spiral_shell"), "the shell icon")
	t.assert_true(strip.shell.get_rect().is_equal_approx(ScreenLayout.collection_shell_rect(visible)), "the shell place")
	await Scene.remove(t, main)
	return true


## The gear is quiet: 48 px and 40 % opacity.
func test_the_gear_is_quiet(t) -> bool:
	var main := await Scene.add_main(t)
	var gear: GearView = main.get_node("Gear")
	var visible: Vector2 = main.get_viewport().get_visible_rect().size
	t.assert_true(gear.get_rect().is_equal_approx(ScreenLayout.gear_rect(visible)), "gear rectangle")
	t.assert_true(is_equal_approx(gear.modulate.a, 0.4), "gear at 40 % opacity")
	await Scene.remove(t, main)
	return true


## The settings panel has the cream-and-wood style of the logo, with the screen black at 50 %
## behind it. The reset ring stays orange.
func test_the_settings_panel_has_the_cream_and_wood_style(t) -> bool:
	var main := await Scene.add_main(t)
	var panel: SettingsPanel = main.get_node("Settings")
	panel.open()
	var visible := main.get_viewport().get_visible_rect()
	t.assert_eq(panel.dim.color, Color(0, 0, 0, 0.5), "the screen is black at 50 % behind the panel")
	t.assert_eq(panel.dim.get_global_rect(), visible, "the dark layer covers the screen")
	t.assert_eq(panel.dim.mouse_filter, Control.MOUSE_FILTER_IGNORE, "the gear still takes the click that closes the panel")
	var style: StyleBoxFlat = panel.box.get_theme_stylebox("panel")
	t.assert_eq(style.bg_color, Color("#fff3d6"), "panel fill")
	t.assert_eq(style.border_color, Color("#7a4a24"), "border colour")
	t.assert_eq(style.border_width_top, 10, "border of 10 px")
	t.assert_eq(style.corner_radius_top_left, 40, "corner radius of 40 px")
	t.assert_eq(PictureButton.FACE_COLOUR, Color("#e9c98f"), "button colour")
	t.assert_eq(PictureButton.EDGE_COLOUR, Color("#b58a4a"), "button bottom edge")
	t.assert_eq(SettingsPicture.FILL_COLOUR, Color("#5a3416"), "icon colour")
	t.assert_eq(panel.reset_button.ring_full_colour, Color("#ff7a59"), "the reset ring stays orange")
	t.assert_eq(panel.reset_button.hold_seconds, 8.0, "the reset hold stays 8 s")
	t.assert_eq(panel.quit_button.hold_seconds, 3.0, "the quit hold stays 3 s")
	panel.close()
	await Scene.remove(t, main)
	return true


## `colour` with its alpha over the opaque `below`, in sRGB.
func _over(colour: Color, below: Color) -> Color:
	return Color(below.lerp(Color(colour, 1.0), colour.a), 1.0)


## The mean grey of the ghost of the Item `kind` over the sprite, weighted by alpha. Each pixel has
## the grey of spec 8.7: min(2 x luminance, 1), as the CSS filter grayscale(1) brightness(2).
func _ghost_grey(kind: String) -> float:
	var image := Image.load_from_file(ProjectSettings.globalize_path(Area.item_texture_path(kind)))
	image.resize(64, 64)
	var sum := 0.0
	var weight := 0.0
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			sum += minf(2.0 * (0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b), 1.0) * pixel.a
			weight += pixel.a
	return sum / weight


## The WCAG contrast ratio of two opaque colours.
func _contrast(a: Color, b: Color) -> float:
	var la := _luminance(a)
	var lb := _luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


func _luminance(colour: Color) -> float:
	var linear := colour.srgb_to_linear()
	return 0.2126 * linear.r + 0.7152 * linear.g + 0.0722 * linear.b
