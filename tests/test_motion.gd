## The motion values of spec 8 and 5.2 to 5.4 at the medium amount, and the pure motion functions.
## The expected values are the spec numbers, written here by hand.
extends RefCounted


func _near(t, actual: float, expected: float, label: String) -> void:
	t.assert_true(absf(actual - expected) < 0.0001, "%s: expected %s, got %s" % [label, expected, actual])


func test_curves_are_the_prototype_curves(t) -> bool:
	# Spec 8.1: out, inout, and back.
	t.assert_eq(Motion.transition(Motion.Easing.OUT), Tween.TRANS_CUBIC, "out transition")
	t.assert_eq(Motion.ease_of(Motion.Easing.OUT), Tween.EASE_OUT, "out ease")
	t.assert_eq(Motion.transition(Motion.Easing.INOUT), Tween.TRANS_CUBIC, "inout transition")
	t.assert_eq(Motion.ease_of(Motion.Easing.INOUT), Tween.EASE_IN_OUT, "inout ease")
	t.assert_eq(Motion.transition(Motion.Easing.BACK), Tween.TRANS_BACK, "back transition")
	t.assert_eq(Motion.ease_of(Motion.Easing.BACK), Tween.EASE_OUT, "back ease")
	return true


func test_boat_move_and_bump(t) -> bool:
	# Spec 5.2, 5.3, 8.3.
	_near(t, Motion.TILE_SECONDS, 0.18, "slide seconds for each tile")
	t.assert_eq(Motion.SLIDE_CURVE, Motion.Easing.OUT, "slide curve")
	_near(t, Motion.BUMP_TILES, 0.12, "bump distance in tiles")
	_near(t, Motion.BUMP_OUT_SECONDS, 0.07, "bump out")
	_near(t, Motion.BUMP_BACK_SECONDS, 0.11, "bump back")
	return true


func test_boat_idle_rock_and_bob(t) -> bool:
	# Spec 8.2: rock 0.06 sin(1.6 t) rad, bob 2 sin(1.6 t + 1) px.
	_near(t, Motion.boat_rock(0.0), 0.0, "rock at 0 s")
	_near(t, Motion.boat_rock(PI / 3.2), 0.06, "rock at its top (1.6 t = PI / 2)")
	_near(t, Motion.boat_bob(0.0), 2.0 * sin(1.0), "bob at 0 s")
	_near(t, Motion.boat_bob((PI / 2 - 1.0) / 1.6), 2.0, "bob at its top")
	return true


func test_item_idle_bob_and_sparkle(t) -> bool:
	# Spec 8.2: bob 4 sin(2 t + i) px. The sparkle shows while fract(0.7 t + 0.33 i) < 0.15, with
	# alpha 1 - fract / 0.15: a cycle of 1.4 s.
	_near(t, Motion.item_bob(0.0, 0), 0.0, "Item 0 bob at 0 s")
	_near(t, Motion.item_bob(PI / 4, 0), 4.0, "Item 0 bob at its top")
	_near(t, Motion.item_bob(0.0, 1), 4.0 * sin(1.0), "Item 1 bob at 0 s")
	_near(t, Motion.item_sparkle_alpha(0.0, 0), 1.0, "the sparkle starts at full alpha")
	_near(t, Motion.item_sparkle_alpha(0.075 / 0.7, 0), 0.5, "half way through the sparkle")
	_near(t, Motion.item_sparkle_alpha(0.15 / 0.7 + 0.01, 0), 0.0, "no sparkle after 15 % of the cycle")
	_near(t, Motion.item_sparkle_alpha(1.0 / 0.7, 0), 1.0, "the next sparkle after 1 / 0.7 s")
	_near(t, Motion.item_sparkle_alpha((1.0 - 0.33) / 0.7, 1), 1.0, "Item 1 sparkles 0.33 of a cycle earlier")
	_near(t, Motion.SPARKLE_RADIUS_PX, 7.0, "sparkle radius")
	t.assert_eq(Motion.SPARKLE_OFFSET_PX, Vector2(18, -18), "sparkle place from the Item centre")
	return true


func test_palm_sway(t) -> bool:
	# Spec 8.2: 0.08 sin(1.5 t) rad.
	_near(t, Motion.palm_sway(0.0), 0.0, "palm at 0 s")
	_near(t, Motion.palm_sway(PI / 3.0), 0.08, "palm at its top")
	return true


func test_water_waves_light_and_foam(t) -> bool:
	# Spec 8.2: each wave line moves 8 sin(1.2 t + 0.02 x + 0.05 y) px; the shader gets 1.2 t.
	_near(t, Motion.wave_phase(2.0), 2.4, "wave phase at 2 s")
	# Open gap 6: the light shapes move at 10 px/s.
	_near(t, Motion.light_shift(3.0), 30.0, "light shapes after 3 s")
	# Foam: 55 % white, 4 px wide, dashes of 10 px with gaps of 9 px that move at 20 px/s, at a
	# distance from the coast that changes by 2 sin(2 t) px.
	_near(t, Motion.FOAM_ALPHA, 0.55, "foam opacity")
	_near(t, Motion.FOAM_WIDTH_PX, 4.0, "foam width")
	_near(t, Motion.FOAM_DASH_PX, 10.0, "dash")
	_near(t, Motion.FOAM_GAP_PX, 9.0, "gap")
	_near(t, Motion.foam_shift(0.5), 10.0, "dashes after 0.5 s")
	_near(t, Motion.foam_distance(PI / 4) - Motion.foam_distance(0.0), 2.0, "foam distance at its top")
	_near(t, Motion.foam_distance(3 * PI / 4) - Motion.foam_distance(0.0), -2.0, "foam distance at its bottom")
	return true


func test_wake_rings(t) -> bool:
	# Spec 8.2: a ring in 60 % of the frames at 60 fps, 30 px behind the boat centre, a white 2 px
	# ellipse from 4 x 2 px to 30 x 16 px that fades out in 900 ms.
	_near(t, Motion.WAKE_RINGS_PER_SECOND, 36.0, "rings each second")
	_near(t, Motion.WAKE_BEHIND_PX, 30.0, "ring start behind the boat centre")
	_near(t, Motion.WAKE_WIDTH_PX, 2.0, "ring line width")
	_near(t, Motion.WAKE_LIFE, 0.9, "ring life")
	t.assert_eq(Motion.wake_ring_radii(0.0), Vector2(4, 2), "new ring")
	t.assert_eq(Motion.wake_ring_radii(0.45), Vector2(17, 9), "ring at half its life")
	t.assert_eq(Motion.wake_ring_radii(0.9), Vector2(30, 16), "ring at the end of its life")
	_near(t, Motion.wake_ring_alpha(0.0), 1.0, "new ring alpha")
	_near(t, Motion.wake_ring_alpha(0.45), 0.5, "ring alpha at half its life")
	_near(t, Motion.wake_ring_alpha(0.9), 0.0, "ring alpha at the end")
	return true


func test_area_decoration_motion(t) -> bool:
	# Open gap 6: crests drift at 15 px/s; 1 bubble each second rises at 30 px/s for 3 s; 1 drop
	# each second falls at 40 px/s for 1.5 s; the stars go from alpha 0.2 to 0.9 in a cycle of 2 s.
	_near(t, Motion.CREST_DRIFT_PX, 15.0, "crest drift")
	# A crest drifts along a path of 80 px: 15 px/s takes it 3/16 of the path in 1 s.
	_near(t, Motion.crest_progress(1.0, 0.0), 15.0 / 80.0, "crest after 1 s")
	_near(t, Motion.crest_progress(1.0, 0.9), 0.9 + 15.0 / 80.0 - 1.0, "a crest starts its path again")
	_near(t, Motion.BUBBLE_INTERVAL, 1.0, "a bubble each second")
	_near(t, Motion.BUBBLE_RISE_PX, 30.0, "bubble rise")
	_near(t, Motion.BUBBLE_LIFE, 3.0, "bubble life")
	_near(t, Motion.DROPLET_INTERVAL, 1.0, "a drop each second")
	_near(t, Motion.DROPLET_FALL_PX, 40.0, "drop fall")
	_near(t, Motion.DROPLET_LIFE, 1.5, "drop life")
	_near(t, Motion.STAR_CYCLE, 2.0, "star cycle")
	_near(t, Motion.star_alpha(0.0, 0.0), 0.55, "star alpha in the middle at 0 s")
	_near(t, Motion.star_alpha(0.5, 0.0), 0.9, "star alpha at its top after a quarter cycle")
	_near(t, Motion.star_alpha(1.5, 0.0), 0.2, "star alpha at its bottom after 3 quarters")
	_near(t, Motion.star_alpha(0.0, 0.25), 0.9, "a star a quarter cycle ahead")
	return true


func test_piece_ages_repeat_with_one_piece_each_interval(t) -> bool:
	# 3 bubble places, a bubble each second, a life of 3 s: place k starts a bubble at k s, k + 3 s,
	# and so on.
	_near(t, Motion.piece_age(0.25, 0, 3, 1.0), 0.25, "place 0 at 0.25 s")
	_near(t, Motion.piece_age(0.25, 1, 3, 1.0), 2.25, "place 1 started its bubble at -2 s")
	_near(t, Motion.piece_age(0.25, 2, 3, 1.0), 1.25, "place 2 started its bubble at -1 s")
	_near(t, Motion.piece_age(3.5, 0, 3, 1.0), 0.5, "place 0 starts again after 3 s")
	# 2 drop places, a drop each second: each place starts a drop every 2 s.
	_near(t, Motion.piece_age(2.75, 1, 2, 1.0), 1.75, "drop place 1")
	return true


func test_item_collect(t) -> bool:
	# Spec 8.4.
	t.assert_eq(Motion.SPLASH_COUNT, 8, "splash dots")
	t.assert_eq(Motion.SPLASH_COLOURS, [Color("#ffffff"), Color("#bbddff")], "splash colours")
	_near(t, Motion.SPLASH_SPEED_PX, 90.0, "splash speed")
	_near(t, Motion.SPLASH_LIFE, 0.4, "splash life")
	_near(t, Motion.ITEM_POP_SCALE, 1.4, "pop scale")
	_near(t, Motion.ITEM_POP_SECONDS, 0.12, "pop time")
	t.assert_eq(Motion.ITEM_POP_CURVE, Motion.Easing.OUT, "pop curve")
	_near(t, Motion.ITEM_FLY_SECONDS, 0.45, "fly time")
	t.assert_eq(Motion.ITEM_FLY_CURVE, Motion.Easing.INOUT, "fly curve")
	_near(t, Motion.ITEM_FLY_SCALE, 0.55, "scale at the outline")
	_near(t, Motion.OUTLINE_FILL_SECONDS, 0.15, "outline fill time")
	_near(t, Motion.OUTLINE_BOUNCE_SCALE, 1.5, "outline bounce from")
	_near(t, Motion.OUTLINE_BOUNCE_SECONDS, 0.35, "outline bounce time")
	t.assert_eq(Motion.OUTLINE_BOUNCE_CURVE, Motion.Easing.BACK, "outline bounce curve")
	t.assert_eq(Motion.OUTLINE_SPARKLE_COUNT, 10, "outline sparkles")
	t.assert_eq(Motion.SPARKLE_COLOURS, [Color("#ffffff"), Color("#ffe07a")], "sparkle colours")
	_near(t, Motion.OUTLINE_SPARKLE_SPEED_PX, 120.0, "outline sparkle speed")
	_near(t, Motion.OUTLINE_SPARKLE_LIFE, 0.5, "outline sparkle life")
	_near(t, Motion.item_fly_arrival(), 0.57, "the Item is at its outline 120 ms + 450 ms after the arrival")
	return true


func test_goal_hop_and_confetti(t) -> bool:
	# Spec 8.5.
	t.assert_eq(Motion.HOP_TIMES, [0.0, 0.6], "2 hops")
	_near(t, Motion.HOP_SCALE, 1.25, "hop height scale")
	_near(t, Motion.HOP_UP_SECONDS, 0.15, "hop up")
	t.assert_eq(Motion.HOP_UP_CURVE, Motion.Easing.OUT, "hop up curve")
	_near(t, Motion.HOP_DOWN_SECONDS, 0.25, "hop down")
	t.assert_eq(Motion.HOP_DOWN_CURVE, Motion.Easing.BACK, "hop down curve")
	t.assert_eq(Motion.CONFETTI_COUNT, 40, "confetti pieces")
	_near(t, Motion.CONFETTI_RISE_PX, 40.0, "confetti start above the Goal island centre")
	t.assert_eq(Motion.CONFETTI_SIZE_PX, Vector2(10, 6), "confetti piece size")
	t.assert_eq(Motion.CONFETTI_COLOURS, [Color("#ff5a5a"), Color("#ffd54a"), Color("#5ad1ff"), Color("#7cff7a"), Color("#ff8ad8")], "confetti colours")
	_near(t, Motion.CONFETTI_SPEED_PX, 320.0, "confetti speed")
	t.assert_eq(Motion.BURST_SPEED_FACTOR, Vector2(0.4, 1.2), "random speed factor")
	_near(t, Motion.CONFETTI_GRAVITY_PX, 380.0, "confetti gravity")
	_near(t, Motion.CONFETTI_LIFE, 2.6, "confetti life")
	return true


func test_sea_friend_arrival(t) -> bool:
	# Spec 8.6. The x of the start place is +60, at the far side of the Goal island, not -60: at -60
	# the Sea friend covers the chest and the boat (ticket 28).
	t.assert_eq(Motion.FRIEND_START_PX, Vector2(60, 60), "start place from the Goal island centre")
	_near(t, Motion.FRIEND_PX, 110.0, "Sea friend size")
	_near(t, Motion.FRIEND_SCALE, 1.3, "Sea friend scale next to the island")
	_near(t, Motion.FRIEND_GROW_SECONDS, 0.45, "grow time")
	t.assert_eq(Motion.FRIEND_GROW_CURVE, Motion.Easing.BACK, "grow curve")
	_near(t, Motion.FRIEND_RISE_PX, 30.0, "end height above the island centre")
	_near(t, Motion.FRIEND_WIGGLE_RAD, 0.15, "wiggle angle")
	_near(t, Motion.FRIEND_WIGGLE_SECONDS, 0.25, "wiggle half time")
	t.assert_eq(Motion.FRIEND_WIGGLE_CURVE, Motion.Easing.INOUT, "wiggle curve")
	_near(t, Motion.FRIEND_FLY_SECONDS, 0.7, "fly to the slot")
	t.assert_eq(Motion.FRIEND_FLY_CURVE, Motion.Easing.INOUT, "fly curve")
	t.assert_eq(Motion.SLOT_SPARKLE_COUNT, 10, "slot sparkles")
	_near(t, Motion.SLOT_SPARKLE_SPEED_PX, 100.0, "slot sparkle speed")
	_near(t, Motion.SLOT_SPARKLE_LIFE, 0.5, "slot sparkle life")
	return true


func test_fade_and_new_area_item(t) -> bool:
	# Spec 8.8.
	_near(t, Motion.FADE_SECONDS, 0.5, "fade time")
	t.assert_eq(Motion.FADE_CURVE, Motion.Easing.INOUT, "fade curve")
	t.assert_eq(Motion.FADE_COLOUR, Color("#0a1428"), "fade colour")
	_near(t, Motion.AREA_ITEM_SCALE, 2.0, "the Area Item is 2 times the Item size")
	_near(t, Motion.AREA_ITEM_GROW_SECONDS, 0.4, "Area Item grow")
	t.assert_eq(Motion.AREA_ITEM_GROW_CURVE, Motion.Easing.BACK, "Area Item grow curve")
	_near(t, Motion.AREA_ITEM_STAY_SECONDS, 0.6, "Area Item stay")
	_near(t, Motion.AREA_ITEM_FADE_SECONDS, 0.4, "Area Item fade")
	return true


func test_goal_celebration_steps(t) -> bool:
	# Spec 6.3, 8.5, 8.6, 8.8: seconds from the arrival on the Goal square.
	var expected := [
		[0.0, Motion.GoalStep.OPEN_CHEST],
		[0.0, Motion.GoalStep.HOP],
		[0.0, Motion.GoalStep.CONFETTI],
		[0.6, Motion.GoalStep.HOP],
		[1.4, Motion.GoalStep.FRIEND_APPEARS],
		[1.9, Motion.GoalStep.FRIEND_WIGGLES],
		[3.0, Motion.GoalStep.FRIEND_FLIES],
		[3.7, Motion.GoalStep.FRIEND_IN_SLOT],
		[4.2, Motion.GoalStep.FADE_OUT],
		[4.7, Motion.GoalStep.NEXT_LABYRINTH],
		[5.2, Motion.GoalStep.UNLOCK],
	]
	var steps := Motion.goal_steps()
	t.assert_eq(steps.size(), expected.size(), "step count")
	for i in mini(steps.size(), expected.size()):
		_near(t, steps[i][0], expected[i][0], "time of step %d" % i)
		t.assert_eq(steps[i][1], expected[i][1], "step %d" % i)
	# The Sea friend is in its slot when its fly ends.
	_near(t, Motion.FRIEND_FLIES_AT + Motion.FRIEND_FLY_SECONDS, Motion.FRIEND_IN_SLOT_AT, "the fly ends in the slot")
	return true


func test_new_area_starts(t) -> bool:
	# Spec 7.2, 8.8: the Area changes at Labyrinths 6, 11, 16, 21, and every 5 after that.
	var starts := []
	for n in range(2, 32):
		if Motion.starts_new_area(n):
			starts.append(n)
	t.assert_eq(starts, [6, 11, 16, 21, 26, 31], "Labyrinths that start a new Area")
	t.assert_true(not Motion.starts_new_area(1), "Labyrinth 1 at launch shows no Area Item")
	return true