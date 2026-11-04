## The place of the Labyrinth on the screen (spec 10).
extends RefCounted

const SCREEN_16_10 := Vector2(1920, 1200)
const SCREEN_1512_982 := Vector2(1920, 1247)


func test_bands_at_1200(t) -> bool:
	t.assert_eq(ScreenLayout.top_band_height(SCREEN_16_10), 237, "top band at 1200")
	t.assert_eq(ScreenLayout.bottom_strip_height(SCREEN_16_10), 111, "bottom strip at 1200")
	return true


func test_tile_size_at_1920_by_1200(t) -> bool:
	t.assert_eq(ScreenLayout.tile_px(SCREEN_16_10, Vector2i(9, 7)), 121, "4 x 3 Labyrinth")
	t.assert_eq(ScreenLayout.tile_px(SCREEN_16_10, Vector2i(21, 15)), 56, "10 x 7 Labyrinth")
	return true


func test_labyrinth_is_centred_between_the_top_band_and_the_strip(t) -> bool:
	for screen: Vector2 in [SCREEN_16_10, SCREEN_1512_982]:
		for tiles: Vector2i in [Vector2i(9, 7), Vector2i(19, 15), Vector2i(21, 15)]:
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
