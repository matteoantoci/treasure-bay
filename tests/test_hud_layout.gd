## The place of the Item row and the Collection strip on the screen (spec 10). The HUD values are
## prototype px at 760 px height, times h = height / 760.
extends RefCounted

const SCREEN_16_10 := Vector2(1920, 1200)
const SCREEN_1512_982 := Vector2(1920, 1247)


func test_item_row_at_1920_by_1200(t) -> bool:
	# h = 1200 / 760. Row height 60 h = 94.74, distance 90 h = 142.11, outline 56 h = 88.42.
	var centres := ScreenLayout.item_outline_centres(SCREEN_16_10, 2)
	t.assert_eq(centres.size(), 2, "2 outlines")
	t.assert_true(centres[0].distance_to(Vector2(888.9474, 94.7368)) < 0.01, "outline 1 of 2")
	t.assert_true(centres[1].distance_to(Vector2(1031.0526, 94.7368)) < 0.01, "outline 2 of 2")
	t.assert_true(absf(ScreenLayout.item_outline_px(SCREEN_16_10) - 88.4211) < 0.01, "outline size")
	var eight := ScreenLayout.item_outline_centres(SCREEN_16_10, 8)
	t.assert_true(absf(eight[0].x - (960 - 3.5 * 142.1053)) < 0.01, "outline 1 of 8")
	t.assert_true(absf(eight[7].x - (960 + 3.5 * 142.1053)) < 0.01, "outline 8 of 8")
	t.assert_true(absf(eight[1].x - eight[0].x - 142.1053) < 0.01, "distance between outlines")
	return true


func test_item_row_is_in_the_top_band(t) -> bool:
	for screen: Vector2 in [SCREEN_16_10, SCREEN_1512_982]:
		var half := ScreenLayout.item_outline_px(screen) / 2
		for centre in ScreenLayout.item_outline_centres(screen, 8):
			t.assert_true(centre.y - half >= 0 and centre.y + half <= ScreenLayout.top_band_height(screen), "outline inside the top band on %s" % screen)
			t.assert_true(centre.x - half >= 0 and centre.x + half <= screen.x, "outline on the screen on %s" % screen)
	return true


func test_collection_strip_at_1920_by_1200(t) -> bool:
	# Strip 111 px. The count area is 2 strip heights (222 px) at the left end. The 20 slots share
	# the other 1698 px: 84.9 px each. The slot icon is 44 h = 69.47 px. The count font is 64 px.
	var slots := ScreenLayout.collection_slot_centres(SCREEN_16_10)
	t.assert_eq(slots.size(), 20, "20 slots")
	t.assert_true(slots[0].distance_to(Vector2(222 + 42.45, 1144.5)) < 0.01, "slot 1")
	t.assert_true(slots[19].distance_to(Vector2(1920 - 42.45, 1144.5)) < 0.01, "slot 20")
	t.assert_true(absf(ScreenLayout.collection_icon_px(SCREEN_16_10) - 69.4737) < 0.01, "slot icon size")
	t.assert_eq(ScreenLayout.collection_count_rect(SCREEN_16_10), Rect2(0, 1089, 222, 111), "count area")
	t.assert_eq(ScreenLayout.collection_count_font_size(SCREEN_16_10), 64, "count font size")
	return true


func test_collection_slots_fit_the_strip(t) -> bool:
	for screen: Vector2 in [SCREEN_16_10, SCREEN_1512_982]:
		var slots := ScreenLayout.collection_slot_centres(screen)
		var icon := ScreenLayout.collection_icon_px(screen)
		var strip_top := screen.y - ScreenLayout.bottom_strip_height(screen)
		t.assert_true(slots[1].x - slots[0].x >= icon, "slot icons do not overlap on %s" % screen)
		t.assert_true(slots[0].x - icon / 2 >= ScreenLayout.collection_count_rect(screen).end.x, "slot 1 is right of the count on %s" % screen)
		t.assert_true(slots[0].y - icon / 2 >= strip_top and slots[0].y + icon / 2 <= screen.y, "slot icons inside the strip on %s" % screen)
	return true


func test_a_sprite_fits_its_longer_side_to_the_size(t) -> bool:
	t.assert_eq(ScreenLayout.sprite_rect(Vector2(100, 100), Vector2(512, 256), 60.0), Rect2(70, 85, 60, 30), "wide sprite")
	t.assert_eq(ScreenLayout.sprite_rect(Vector2(100, 100), Vector2(256, 512), 60.0), Rect2(85, 70, 30, 60), "tall sprite")
	t.assert_eq(ScreenLayout.labyrinth_scale(65.0), 0.5, "s at a 65 px tile")
	return true


func test_gear_in_the_top_right_corner(t) -> bool:
	# 64 px. Its centre is at the height of the Item row, 60 h = 94.74 px at 1200, and the same
	# distance from the right edge.
	t.assert_eq(ScreenLayout.gear_rect(SCREEN_16_10).size, Vector2(64, 64), "gear size")
	t.assert_true(ScreenLayout.gear_rect(SCREEN_16_10).get_center().distance_to(Vector2(1920 - 94.7368, 94.7368)) < 0.01, "gear centre at 1200")
	t.assert_true(ScreenLayout.gear_rect(SCREEN_1512_982).get_center().distance_to(Vector2(1920 - 98.4474, 98.4474)) < 0.01, "gear centre at 1247")
	return true
