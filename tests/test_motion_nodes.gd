## The motion nodes with the values of spec 8: the bursts of spec 8.1 and 8.4 to 8.6, and the wake
## dots of the game-flow spec part 5, fix 9. No frame waits: the tests call the nodes directly.
extends RefCounted


func test_a_burst_of_splash_dots(t) -> bool:
	var burst := Burst.stars(8, [Color("#ffffff"), Color("#bbddff")], 90.0, 0.4)
	t.assert_eq(burst.amount, 8, "8 dots")
	t.assert_true(is_equal_approx(burst.lifetime, 0.4), "life 400 ms")
	t.assert_true(burst.one_shot and not burst.emitting, "one shot, waiting for its start")
	t.assert_eq(burst.explosiveness, 1.0, "all dots at once")
	t.assert_true(is_equal_approx(burst.initial_velocity_min, 36.0) and is_equal_approx(burst.initial_velocity_max, 108.0), "90 px/s times 0.4 to 1.2")
	t.assert_eq(burst.spread, 180.0, "in all directions")
	t.assert_eq(burst.gravity, Vector2.ZERO, "no gravity")
	t.assert_eq(burst.color_initial_ramp.colors, PackedColorArray([Color("#ffffff"), Color("#bbddff")]), "the 2 colours")
	t.assert_eq(burst.color_ramp.sample(1.0).a, 0.0, "the dots fade out")
	burst.free()
	return true


func test_the_confetti_burst(t) -> bool:
	var burst := Burst.confetti()
	t.assert_eq(burst.amount, 40, "40 pieces")
	t.assert_true(is_equal_approx(burst.lifetime, 2.6), "life 2.6 s")
	t.assert_eq(burst.gravity, Vector2(0, 380), "gravity 380 px/s²")
	t.assert_true(is_equal_approx(burst.initial_velocity_min, 128.0) and is_equal_approx(burst.initial_velocity_max, 384.0), "320 px/s times 0.4 to 1.2")
	t.assert_eq(burst.color_initial_ramp.colors.size(), 5, "5 colours")
	t.assert_eq(burst.texture.get_size(), Vector2(20, 12), "the piece texture")
	t.assert_eq(burst.scale_amount_min, 0.5, "drawn at 10 x 6 px")
	# All directions, with an upward push of 0.6 of the speed on average.
	var sum := Vector2.ZERO
	for normal in burst.emission_normals:
		sum += normal
	t.assert_eq(burst.emission_normals.size(), 40, "a direction for each piece")
	t.assert_true((sum / 40.0).is_equal_approx(Vector2(0, -0.6)), "upward push: %s" % (sum / 40.0))
	burst.free()
	return true


func test_the_wake_starts_a_dot_every_40_ms_behind_the_stern(t) -> bool:
	var wake := WakeView.new()
	var boat := Node2D.new()
	boat.position = Vector2(100, 100)
	wake.boat = boat
	wake.set_tile_px(130.0)
	wake.start(Vector2i.RIGHT)
	wake._process(0.25)
	wake._process(0.25)
	t.assert_eq(wake.dots.size(), 12, "12 dots in 0.5 s")
	for dot in wake.dots:
		t.assert_true(dot.centre.x <= 100.0 - BoatView.LENGTH_PX / 2.0, "the dot starts behind the stern: %s" % dot.centre)
		t.assert_true(absf(dot.centre.y - 100.0) <= 0.1 * 130.0, "the dot starts near the move line: %s" % dot.centre)
	wake.stop()
	wake._process(0.3)
	t.assert_eq(wake.dots.size(), 12, "no new dot after the stop, and no dot is 0.6 s old")
	wake._process(0.1)
	t.assert_eq(wake.dots.size(), 6, "the dots of the first 0.25 s are gone after 0.6 s")
	wake._process(0.2)
	t.assert_eq(wake.dots.size(), 0, "each dot lives 0.6 s")
	wake.free()
	boat.free()
	return true
