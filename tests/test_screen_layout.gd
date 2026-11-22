## The place of the Labyrinth on the screen (spec 10, spec 14.1 test 8).
extends RefCounted

const SCREEN_16_10 := Vector2(1920, 1200)
const SCREEN_1512_982 := Vector2(1920, 1247)
## The tiles of each Labyrinth size of spec 4.3, and the tile px at 1920 x 1200 and at 1920 x 1247,
## worked out by hand: floor(min(free height / tile rows, 1920 / tile columns)). The free height
## is 1200 - 237 - 111 = 852 px and 1247 - 246 - 115 = 886 px.
const TILE_PX := [
	[Vector2i(9, 7), 121, 126],
	[Vector2i(11, 7), 121, 126],
	[Vector2i(11, 9), 94, 98],
	[Vector2i(13, 9), 94, 98],
	[Vector2i(15, 9), 94, 98],
	[Vector2i(15, 11), 77, 80],
	[Vector2i(17, 11), 77, 80],
	[Vector2i(17, 13), 65, 68],
	[Vector2i(19, 13), 65, 68],
	[Vector2i(19, 15), 56, 59],
	[Vector2i(21, 15), 56, 59],
]


func test_bands_at_1200(t) -> bool:
	t.assert_eq(ScreenLayout.top_band_height(SCREEN_16_10), 237, "top band at 1200")
	t.assert_eq(ScreenLayout.bottom_strip_height(SCREEN_16_10), 111, "bottom strip at 1200")
	t.assert_eq(ScreenLayout.top_band_height(SCREEN_1512_982), 246, "top band at 1247")
	t.assert_eq(ScreenLayout.bottom_strip_height(SCREEN_1512_982), 115, "bottom strip at 1247")
	return true


func test_tile_size_of_each_labyrinth_size(t) -> bool:
	for row: Array in TILE_PX:
		var tiles: Vector2i = row[0]
		t.assert_eq(ScreenLayout.tile_px(SCREEN_16_10, tiles), row[1], "%s tiles at 1920 x 1200" % tiles)
		t.assert_eq(ScreenLayout.tile_px(SCREEN_1512_982, tiles), row[2], "%s tiles at 1920 x 1247" % tiles)
	return true


func test_the_table_has_each_labyrinth_size(t) -> bool:
	for number in range(1, 21):
		var size := LabyrinthPlan.size_for(number)
		var tiles := Vector2i(2 * size.x + 1, 2 * size.y + 1)
		t.assert_true(TILE_PX.any(func(row: Array) -> bool: return row[0] == tiles), "Labyrinth %d size is in the table" % number)
	return true


func test_labyrinth_is_centred_between_the_top_band_and_the_strip(t) -> bool:
	for screen: Vector2 in [SCREEN_16_10, SCREEN_1512_982]:
		for row: Array in TILE_PX:
			var tiles: Vector2i = row[0]
			var rect := ScreenLayout.labyrinth_rect(screen, tiles)
			var top := ScreenLayout.top_band_height(screen)
			var bottom := screen.y - ScreenLayout.bottom_strip_height(screen)
			var label := "%s tiles on %s" % [tiles, screen]
			t.assert_eq(rect.size, Vector2(tiles) * ScreenLayout.tile_px(screen, tiles), label + ": size")
			t.assert_true(rect.position.y >= top and rect.end.y <= bottom, label + ": fits between the bands")
			t.assert_true(rect.position.x >= 0 and rect.end.x <= screen.x, label + ": fits left to right")
			t.assert_true(is_equal_approx(rect.get_center().x, screen.x / 2), label + ": centred left to right")
			t.assert_true(is_equal_approx(rect.get_center().y, (top + bottom) / 2.0), label + ": centred top to bottom")
	return true
