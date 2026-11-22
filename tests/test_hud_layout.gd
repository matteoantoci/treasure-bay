## The place of the Item column, the Collection strip, and the gear on the screen (game-flow spec
## part 5, fixes 1, 3, 6 and 7). The px values are px at a visible height of 1200 px. They scale
## with the visible height, as h does.
extends RefCounted

const SCREEN_16_10 := Vector2(1920, 1200)
const SCREEN_1512_982 := Vector2(1920, 1247)


## The disc diameter is min(120 px, (free height - (count - 1) x 16 px) / count). The free height
## is the height of the Labyrinth area: 1051.11 px at 1200. With 8 Items the disc is 117.39 px and
## the gap is 16 px. The column centre is 50 h = 78.95 px from the left edge.
func test_eight_item_slots_at_1920_by_1200(t) -> bool:
	var centres := ScreenLayout.item_slot_centres(SCREEN_16_10, 8)
	var px := ScreenLayout.item_slot_px(SCREEN_16_10, 8)
	t.assert_eq(centres.size(), 8, "8 slots")
	_near(t, px, 117.388, "disc diameter")
	_near(t, centres[0].x, 78.947, "column centre")
	_near(t, centres[0].y, 18.947 + 117.388 / 2, "slot 1 at the top of the free height")
	for i in 7:
		_near(t, centres[i + 1].y - centres[i].y - px, 16.0, "gap after slot %d" % (i + 1))
	_near(t, centres[7].y + px / 2, 1200 - 111 - 18.947, "slot 8 at the bottom of the free height")
	return true


## With 2 Items the disc is 120 px, the gap is 16 px, and the group is centred in the free height
## (its middle is at 544.5 px).
func test_two_item_slots_are_centred(t) -> bool:
	var centres := ScreenLayout.item_slot_centres(SCREEN_16_10, 2)
	_near(t, ScreenLayout.item_slot_px(SCREEN_16_10, 2), 120.0, "disc diameter")
	_near(t, centres[0].y, 544.5 - 68.0, "slot 1")
	_near(t, centres[1].y, 544.5 + 68.0, "slot 2")
	return true


func test_item_slots_fit_the_column_with_gaps_of_16_px(t) -> bool:
	for screen: Vector2 in [SCREEN_16_10, SCREEN_1512_982]:
		var at_1200 := screen.y / 1200.0
		var area := ScreenLayout.labyrinth_area(screen)
		for count in range(1, 9):
			var centres := ScreenLayout.item_slot_centres(screen, count)
			var half := ScreenLayout.item_slot_px(screen, count) / 2
			var label := "%d slots on %s" % [count, screen]
			t.assert_true(half * 2 <= 120.0 * at_1200 + 0.001, label + ": 120 px or less")
			t.assert_true(centres[0].x - half >= 0 and centres[0].x + half <= ScreenLayout.item_column_width(screen), label + ": in the column")
			t.assert_true(centres[0].y - half >= area.position.y - 0.001 and centres[-1].y + half <= area.end.y + 0.001, label + ": in the free height")
			for i in count - 1:
				t.assert_true(centres[i + 1].y - centres[i].y - 2 * half >= 16.0 * at_1200 - 0.001, label + ": gap %d of 16 px or more" % (i + 1))
	return true


## The strip keeps its height of 70 h. The count area is 300 px at the left. The 20 slots share the
## rest less 24 px at the right edge: 1596 px at 1200, so the disc is min(68 px, (1596 - 19 x 12) /
## 20) = 68 px and the gap is 12.42 px.
func test_collection_strip_at_1920_by_1200(t) -> bool:
	var slots := ScreenLayout.collection_slot_centres(SCREEN_16_10)
	var px := ScreenLayout.collection_slot_px(SCREEN_16_10)
	t.assert_eq(slots.size(), 20, "20 slots")
	_near(t, px, 68.0, "disc diameter")
	t.assert_true(slots[0].distance_to(Vector2(334, 1144.5)) < 0.01, "slot 1 (%s)" % slots[0])
	t.assert_true(slots[19].distance_to(Vector2(1862, 1144.5)) < 0.01, "slot 20 (%s)" % slots[19])
	_near(t, slots[1].x - slots[0].x - px, 12.421, "gap")
	t.assert_eq(ScreenLayout.collection_count_font_size(SCREEN_16_10), 64, "count font size")
	return true


func test_collection_slots_have_gaps_of_12_px_and_24_px_from_the_edges(t) -> bool:
	for screen: Vector2 in [SCREEN_16_10, SCREEN_1512_982]:
		var at_1200 := screen.y / 1200.0
		var slots := ScreenLayout.collection_slot_centres(screen)
		var half := ScreenLayout.collection_slot_px(screen) / 2
		var strip_top := screen.y - ScreenLayout.bottom_strip_height(screen)
		var count := ScreenLayout.collection_count_rect(screen)
		var shell := ScreenLayout.collection_shell_rect(screen)
		for i in 19:
			t.assert_true(slots[i + 1].x - slots[i].x - 2 * half >= 12.0 * at_1200 - 0.001, "gap %d of 12 px or more on %s" % [i + 1, screen])
		t.assert_true(slots[0].x - half >= 24.0 * at_1200, "slot 1 24 px or more from the left edge on %s" % screen)
		t.assert_true(screen.x - slots[19].x - half >= 24.0 * at_1200 - 0.001, "slot 20 24 px or more from the right edge on %s" % screen)
		t.assert_true(slots[0].y - half >= strip_top and slots[0].y + half <= screen.y, "slots inside the strip on %s" % screen)
		t.assert_true(shell.position.x >= 24.0 * at_1200 and shell.end.x <= count.position.x, "the shell is left of the count on %s" % screen)
		t.assert_true(count.end.x <= slots[0].x - half, "the count is left of slot 1 on %s" % screen)
		t.assert_true(shell.position.y >= strip_top and shell.end.y <= screen.y, "the shell is inside the strip on %s" % screen)
	return true


func test_a_sprite_fits_its_longer_side_to_the_size(t) -> bool:
	t.assert_eq(ScreenLayout.sprite_rect(Vector2(100, 100), Vector2(512, 256), 60.0), Rect2(70, 85, 60, 30), "wide sprite")
	t.assert_eq(ScreenLayout.sprite_rect(Vector2(100, 100), Vector2(256, 512), 60.0), Rect2(85, 70, 30, 60), "tall sprite")
	t.assert_eq(ScreenLayout.labyrinth_scale(65.0), 0.5, "s at a 65 px tile")
	return true


## The gear is 48 px, with its centre 40 px from the top and the right edges.
func test_gear_in_the_top_right_corner(t) -> bool:
	t.assert_eq(ScreenLayout.gear_rect(SCREEN_16_10), Rect2(1856, 16, 48, 48), "gear at 1200")
	var at_1247 := ScreenLayout.gear_rect(SCREEN_1512_982)
	_near(t, at_1247.size.x, 49.88, "gear size at 1247")
	t.assert_true(at_1247.get_center().distance_to(Vector2(1920 - 41.567, 41.567)) < 0.01, "gear centre at 1247")
	return true


func _near(t, actual: float, expected: float, label: String) -> void:
	t.assert_true(absf(actual - expected) < 0.01, "%s (%.3f, expected %.3f)" % [label, actual, expected])
