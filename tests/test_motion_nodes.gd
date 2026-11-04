## The motion nodes with the values of spec 8: the bursts of spec 8.1 and 8.4 to 8.6, and the wake
## rings of spec 8.2. No frame waits: the tests call the nodes directly.
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


func test_the_wake_starts_36_rings_each_second_behind_the_boat(t) -> bool:
	var wake := WakeView.new()
	var boat := Node2D.new()
	boat.position = Vector2(100, 100)
	wake.boat = boat
	wake.set_tile_px(130.0)
	wake.start(Vector2i.RIGHT)
	wake._process(0.25)
	wake._process(0.25)
	t.assert_eq(wake.rings.size(), 18, "18 rings in 0.5 s")
	t.assert_true(wake.rings[0].centre.is_equal_approx(Vector2(70, 94)), "the first ring starts 30 px behind the boat, to one side: %s" % wake.rings[0].centre)
	t.assert_true(wake.rings[1].centre.is_equal_approx(Vector2(70, 106)), "the next ring starts to the other side: %s" % wake.rings[1].centre)
	t.assert_true(is_equal_approx(wake.rings[0].rotation, -PI / 2), "the ring turns to the boat direction")
	wake.stop()
	wake._process(0.85)
	t.assert_eq(wake.rings.size(), 9, "the rings of the last 0.25 s are 0.85 s old")
	wake._process(0.1)
	t.assert_eq(wake.rings.size(), 0, "each ring fades out in 900 ms")
	wake.free()
	boat.free()
	return true
