## The place of the Labyrinth on the screen (game-flow spec part 5, fix 1). No top band: the Item
## column is at the left, the Collection strip at the bottom, and the Labyrinth fills the rest.
extends RefCounted

const SCREEN_16_10 := Vector2(1920, 1200)
## The visible size of the 1512 x 982 screen (spec 10).
const SCREEN_1512_982 := Vector2(1920, 1247)
## The tiles of each Labyrinth size, and the tile px at 1920 x 1200 and at 1920 x 1247, worked out
## by hand: floor(min(area height / tile rows, area width / (tile columns + 1), cap)).
## At 1200: h = 1.5789, the area is 1724.21 x 1051.11 px, and the cap is 121 px.
## At 1247: h = 1.6408, the area is 1716.54 x 1092.62 px, and the cap is 125.74 px.
const TILE_PX := [
	[Vector2i(9, 7), 121, 125],
	[Vector2i(11, 7), 121, 125],
	[Vector2i(11, 9), 116, 121],
	[Vector2i(13, 9), 116, 121],
	[Vector2i(15, 9), 107, 107],
	[Vector2i(15, 11), 95, 99],
	[Vector2i(17, 11), 95, 95],
	[Vector2i(17, 13), 80, 84],
	[Vector2i(19, 13), 80, 84],
	[Vector2i(19, 15), 70, 72],
	[Vector2i(21, 15), 70, 72],
]


func test_the_hud_scale_and_the_strip(t) -> bool:
	t.assert_true(is_equal_approx(ScreenLayout.hud_scale(SCREEN_16_10), 1.5789474), "h at 1200")
	t.assert_eq(ScreenLayout.bottom_strip_height(SCREEN_16_10), 111, "strip at 1200: 70 h")
	t.assert_eq(ScreenLayout.bottom_strip_height(SCREEN_1512_982), 115, "strip at 1247: 70 h")
	return true


## The Item column is 100 h wide at the left. The Labyrinth area is the space right of the column
## and above the strip, less a margin of 12 h on each side. Its middle is the place of the Sea
## friend reveal (game-flow spec part 6, fix 5).
func test_the_labyrinth_area_is_right_of_the_item_column_and_above_the_strip(t) -> bool:
	t.assert_true(is_equal_approx(ScreenLayout.item_column_width(SCREEN_16_10), 157.894737), "column at 1200: 100 h")
	_near_rect(t, ScreenLayout.labyrinth_area(SCREEN_16_10), Rect2(176.842, 18.947, 1724.211, 1051.105), "area at 1200")
	_near_rect(t, ScreenLayout.labyrinth_area(SCREEN_1512_982), Rect2(183.768, 19.689, 1716.542, 1092.621), "area at 1247")
	return true


## The tile is the largest that fits, with one more tile of width for the Goal island, and a cap
## of 121 px at 1200 px (121 x visible height / 1200).
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


## The Labyrinth and the outer Goal island tile at its right are centred in the Labyrinth area, on
## whole px.
func test_the_labyrinth_and_the_goal_island_are_centred_in_the_area(t) -> bool:
	for screen: Vector2 in [SCREEN_16_10, SCREEN_1512_982]:
		var area := ScreenLayout.labyrinth_area(screen)
		for row: Array in TILE_PX:
			var tiles: Vector2i = row[0]
			var tile := ScreenLayout.tile_px(screen, tiles)
			var rect := ScreenLayout.labyrinth_rect(screen, tiles)
			var with_island := Rect2(rect.position, rect.size + Vector2(tile, 0))
			var label := "%s tiles on %s" % [tiles, screen]
			t.assert_eq(rect.size, Vector2(tiles) * tile, label + ": size")
			t.assert_eq(rect.position, rect.position.round(), label + ": on whole px")
			t.assert_true(area.encloses(with_island), label + ": fits in the area")
			t.assert_true(absf(with_island.get_center().x - area.get_center().x) <= 0.5, label + ": centred left to right")
			t.assert_true(absf(with_island.get_center().y - area.get_center().y) <= 0.5, label + ": centred top to bottom")
	return true


## Small Labyrinths keep the Area 1 tile, and large Labyrinths grow: Labyrinth 18 goes from about
## 65 px to about 80 px.
func test_labyrinth_18_grows_to_80_px(t) -> bool:
	var size := LabyrinthPlan.size_for(18)
	t.assert_eq(ScreenLayout.tile_px(SCREEN_16_10, Vector2i(2 * size.x + 1, 2 * size.y + 1)), 80, "Labyrinth 18 at 1200")
	return true


## The gear does not overlap the Labyrinth or its Goal island in Labyrinths 1 to 20.
func test_the_gear_is_outside_the_labyrinth(t) -> bool:
	for screen: Vector2 in [SCREEN_16_10, SCREEN_1512_982]:
		var gear := ScreenLayout.gear_rect(screen)
		for number in range(1, 21):
			var labyrinth := LabyrinthPlan.build(number)
			var rect := ScreenLayout.labyrinth_rect(screen, labyrinth.tile_count())
			var tile := rect.size.x / labyrinth.tile_count().x
			var outer := Rect2(rect.position + Vector2(IslandLook.goal_island_tiles(labyrinth)[1]) * tile, Vector2.ONE * tile)
			t.assert_true(not gear.intersects(rect), "Labyrinth %d on %s: the gear is outside the Labyrinth" % [number, screen])
			t.assert_true(not gear.intersects(outer), "Labyrinth %d on %s: the gear is outside the Goal island" % [number, screen])
	return true


func _near_rect(t, actual: Rect2, expected: Rect2, label: String) -> void:
	var near := actual.position.distance_to(expected.position) < 0.01 and actual.size.distance_to(expected.size) < 0.01
	t.assert_true(near, "%s (%s)" % [label, actual])
