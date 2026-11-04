## All motion values of spec 8 (and the boat timings of spec 5.2 and 5.3) at the medium amount, in
## one place, with the pure functions of the idle, water, and decoration motion.
##
## Times are in seconds. A value in `_PX` is px of the prototype: in the Labyrinth, px of its tile
## of 130 px (multiply by s = tile_px / 130); in the HUD, px at a height of 760 px (multiply by
## h = viewport height / 760) (spec 8.1).
class_name Motion
extends RefCounted

## The curves of spec 8.1: `out` and `inout` are cubic, `back` overshoots.
enum Easing { OUT, INOUT, BACK }

## The steps of the Goal celebration (spec 6.3, 8.5, 8.6, 8.8).
enum GoalStep {
	OPEN_CHEST,
	HOP,
	CONFETTI,
	FRIEND_APPEARS,
	FRIEND_WIGGLES,
	FRIEND_FLIES,
	FRIEND_IN_SLOT,
	FADE_OUT,
	NEXT_LABYRINTH,
	UNLOCK,
}

# Boat move and bump (spec 5.2, 5.3, 8.3).
## One tween for the whole slide: 180 ms for each tile that the boat crosses.
const TILE_SECONDS := 0.18
const SLIDE_CURVE := Easing.OUT
## The bump moves the boat toward the wall by 0.12 of a tile in 70 ms, then back in 110 ms.
const BUMP_TILES := 0.12
const BUMP_OUT_SECONDS := 0.07
const BUMP_BACK_SECONDS := 0.11
const BUMP_CURVE := Easing.OUT

# Idle (spec 8.2).
## The boat rocks 0.06 sin(1.6 t) rad and bobs 2 sin(1.6 t + 1) px while it does not move.
const BOAT_ROCK_RAD := 0.06
const BOAT_BOB_PX := 2.0
const BOAT_IDLE_RATE := 1.6
const BOAT_BOB_PHASE := 1.0
## An Item bobs 4 sin(2 t + i) px, where i is its index.
const ITEM_BOB_PX := 4.0
const ITEM_BOB_RATE := 2.0
## A white sparkle at (+18, -18) px from the Item centre, while fract(0.7 t + 0.33 i) < 0.15.
const SPARKLE_RATE := 0.7
const SPARKLE_INDEX_SHIFT := 0.33
const SPARKLE_SHOWS := 0.15
const SPARKLE_RADIUS_PX := 7.0
const SPARKLE_OFFSET_PX := Vector2(18, -18)
## The palm of the Goal island sways 0.08 sin(1.5 t) rad.
const PALM_SWAY_RAD := 0.08
const PALM_SWAY_RATE := 1.5

# Water (spec 8.2, Open gap 6). The wave lines move 8 sin(1.2 t + 0.02 x + 0.05 y) px; the water
# shader holds the size values and gets the phase 1.2 t.
const WAVE_RATE := 1.2
## The soft light shapes move at 10 px/s.
const LIGHT_SPEED_PX := 10.0
## A white line at 55 % opacity, 4 px wide, along each island coast, in dashes of 10 px with gaps
## of 9 px that move at 20 px/s.
const FOAM_ALPHA := 0.55
const FOAM_WIDTH_PX := 4.0
const FOAM_DASH_PX := 10.0
const FOAM_GAP_PX := 9.0
const FOAM_SPEED_PX := 20.0
## The line distance from the coast changes by 2 sin(2 t) px around 4 px. The 4 px are the
## prototype gap between the sand and the foam ring (an ellipse of 62 px around one of 58 px).
const FOAM_DISTANCE_PX := 4.0
const FOAM_SWAY_PX := 2.0
const FOAM_SWAY_RATE := 2.0

# Wake (spec 8.2): rings in 60 % of the frames at 60 fps.
const WAKE_RINGS_PER_SECOND := 0.6 * 60.0
## Each ring starts 30 px behind the boat centre, on the move line, a little to the left or to the
## right in turn, so the rings make a V.
const WAKE_BEHIND_PX := 30.0
const WAKE_SIDE_PX := 6.0
## A white ellipse line, 2 px wide, turned to the boat direction. Its radii grow from 4 x 2 px to
## 30 x 16 px (the radii of the prototype ellipse) while it fades out in 900 ms.
const WAKE_WIDTH_PX := 2.0
const WAKE_START_RADII := Vector2(4, 2)
const WAKE_END_RADII := Vector2(30, 16)
const WAKE_LIFE := 0.9

# Area decoration motion (Open gap 6).
## Wave crests drift at 15 px/s. Each crest drifts along a path of 80 px, fades in and out on it,
## then starts again, so it stays on its water tile.
const CREST_DRIFT_PX := 15.0
const CREST_PATH_PX := 80.0
## 1 bubble each second, rising at 30 px/s for 3 s.
const BUBBLE_INTERVAL := 1.0
const BUBBLE_RISE_PX := 30.0
const BUBBLE_LIFE := 3.0
## 1 drop each second, falling at 40 px/s for 1.5 s.
const DROPLET_INTERVAL := 1.0
const DROPLET_FALL_PX := 40.0
const DROPLET_LIFE := 1.5
## Star alpha goes from 0.2 to 0.9 and back in 2 s.
const STAR_CYCLE := 2.0
const STAR_ALPHA := Vector2(0.2, 0.9)

# Bursts (spec 8.1): one-shot CPUParticles2D. Each piece starts at the burst speed times a random
# factor from 0.4 to 1.2, in all directions, and fades out over its life (the prototype burst()).
const BURST_SPEED_FACTOR := Vector2(0.4, 1.2)
## A splash dot or a sparkle is a small 8-point star of radius 4 px (the prototype star()).
const BURST_STAR_RADIUS_PX := 4.0
const SPARKLE_COLOURS := [Color("#ffffff"), Color("#ffe07a")]

# Item collect (spec 8.4).
const SPLASH_COUNT := 8
const SPLASH_COLOURS := [Color("#ffffff"), Color("#bbddff")]
const SPLASH_SPEED_PX := 90.0
const SPLASH_LIFE := 0.4
const ITEM_POP_SCALE := 1.4
const ITEM_POP_SECONDS := 0.12
const ITEM_POP_CURVE := Easing.OUT
const ITEM_FLY_SECONDS := 0.45
const ITEM_FLY_CURVE := Easing.INOUT
const ITEM_FLY_SCALE := 0.55
const OUTLINE_FILL_SECONDS := 0.15
const OUTLINE_FILL_CURVE := Easing.OUT
const OUTLINE_BOUNCE_SCALE := 1.5
const OUTLINE_BOUNCE_SECONDS := 0.35
const OUTLINE_BOUNCE_CURVE := Easing.BACK
const OUTLINE_SPARKLE_COUNT := 10
const OUTLINE_SPARKLE_SPEED_PX := 120.0
const OUTLINE_SPARKLE_LIFE := 0.5

# Goal (spec 8.5). Times from the arrival on the Goal square.
const CHEST_OPENS_AT := 0.0
const CONFETTI_AT := 0.0
const HOP_TIMES := [0.0, 0.6]
## One hop scales the boat height to 1.25 in 150 ms, then back to 1 in 250 ms.
const HOP_SCALE := 1.25
const HOP_UP_SECONDS := 0.15
const HOP_UP_CURVE := Easing.OUT
const HOP_DOWN_SECONDS := 0.25
const HOP_DOWN_CURVE := Easing.BACK
const CONFETTI_COUNT := 40
const CONFETTI_RISE_PX := 40.0
const CONFETTI_SIZE_PX := Vector2(10, 6)
const CONFETTI_COLOURS := [Color("#ff5a5a"), Color("#ffd54a"), Color("#5ad1ff"), Color("#7cff7a"), Color("#ff8ad8")]
const CONFETTI_SPEED_PX := 320.0
## The upward push: each piece starts with an extra 0.6 of its speed upward (the prototype).
const CONFETTI_PUSH := 0.6
const CONFETTI_GRAVITY_PX := 380.0
const CONFETTI_LIFE := 2.6
## The pieces turn 0.2 rad in each frame at 60 fps (the prototype).
const CONFETTI_SPIN_RAD := 0.2 * 60.0

# Sea friend (spec 8.6). Times from the arrival on the Goal square.
const FRIEND_APPEARS_AT := 1.4
## Spec 8.6 says (-60, +60) px from the Goal island centre. In the prototype the Goal island was
## below the boat; here it is right of the Goal square, so at x = -60 the Sea friend covered the
## chest (Open gap 3: at the side next to the Goal square) and the boat. At x = +60 it grows at the
## far side of the Goal island, over the palm, and the open chest and the boat stay in view.
const FRIEND_START_PX := Vector2(60, 60)
const FRIEND_PX := 110.0
const FRIEND_SCALE := 1.3
const FRIEND_GROW_SECONDS := 0.45
const FRIEND_GROW_CURVE := Easing.BACK
## It moves up to 30 px above the Goal island centre while it grows.
const FRIEND_RISE_PX := 30.0
const FRIEND_WIGGLES_AT := 1.9
const FRIEND_WIGGLE_RAD := 0.15
const FRIEND_WIGGLE_SECONDS := 0.25
const FRIEND_WIGGLE_CURVE := Easing.INOUT
const FRIEND_FLIES_AT := 3.0
const FRIEND_FLY_SECONDS := 0.7
const FRIEND_FLY_CURVE := Easing.INOUT
const FRIEND_IN_SLOT_AT := 3.7
const SLOT_SPARKLE_COUNT := 10
const SLOT_SPARKLE_SPEED_PX := 100.0
const SLOT_SPARKLE_LIFE := 0.5

# Next Labyrinth and new Area (spec 8.8).
const FADE_OUT_AT := 4.2
const FADE_SECONDS := 0.5
const FADE_CURVE := Easing.INOUT
const FADE_COLOUR := Color("#0a1428")
## The new Labyrinth shows when the screen is dark. The input unlocks at the end of the fade-in.
const NEXT_LABYRINTH_AT := FADE_OUT_AT + FADE_SECONDS
const UNLOCK_AT := NEXT_LABYRINTH_AT + FADE_SECONDS
## The first Item kind of a new Area grows from 0 to 2 times the Item size in 400 ms, stays for
## 600 ms, then fades out in 400 ms. It starts with the fade-in.
const AREA_ITEM_SCALE := 2.0
const AREA_ITEM_GROW_SECONDS := 0.4
const AREA_ITEM_GROW_CURVE := Easing.BACK
const AREA_ITEM_STAY_SECONDS := 0.6
const AREA_ITEM_FADE_SECONDS := 0.4


static func transition(curve: Easing) -> Tween.TransitionType:
	return Tween.TRANS_BACK if curve == Easing.BACK else Tween.TRANS_CUBIC


static func ease_of(curve: Easing) -> Tween.EaseType:
	return Tween.EASE_IN_OUT if curve == Easing.INOUT else Tween.EASE_OUT


## Sets the curve of one tweener.
static func shape(tweener: PropertyTweener, curve: Easing) -> PropertyTweener:
	return tweener.set_trans(transition(curve)).set_ease(ease_of(curve))


## The steps of the Goal celebration as [seconds, GoalStep], in time order.
static func goal_steps() -> Array:
	var steps := [[CHEST_OPENS_AT, GoalStep.OPEN_CHEST]]
	for i in HOP_TIMES.size():
		steps.append([HOP_TIMES[i], GoalStep.HOP])
		if i == 0:
			steps.append([CONFETTI_AT, GoalStep.CONFETTI])
	steps.append_array([
		[FRIEND_APPEARS_AT, GoalStep.FRIEND_APPEARS],
		[FRIEND_WIGGLES_AT, GoalStep.FRIEND_WIGGLES],
		[FRIEND_FLIES_AT, GoalStep.FRIEND_FLIES],
		[FRIEND_IN_SLOT_AT, GoalStep.FRIEND_IN_SLOT],
		[FADE_OUT_AT, GoalStep.FADE_OUT],
		[NEXT_LABYRINTH_AT, GoalStep.NEXT_LABYRINTH],
		[UNLOCK_AT, GoalStep.UNLOCK],
	])
	return steps


## Seconds from the arrival on an Item square to the arrival of the Item at its outline.
static func item_fly_arrival() -> float:
	return ITEM_POP_SECONDS + ITEM_FLY_SECONDS


## True when Labyrinth `number` is the first of a new Area after a Goal: its first Item kind pops
## up big in the centre (spec 8.8).
static func starts_new_area(number: int) -> bool:
	return number > 1 and Area.for_labyrinth(number) != Area.for_labyrinth(number - 1)


static func boat_rock(t: float) -> float:
	return BOAT_ROCK_RAD * sin(BOAT_IDLE_RATE * t)


static func boat_bob(t: float) -> float:
	return BOAT_BOB_PX * sin(BOAT_IDLE_RATE * t + BOAT_BOB_PHASE)


static func item_bob(t: float, index: int) -> float:
	return ITEM_BOB_PX * sin(ITEM_BOB_RATE * t + index)


## The alpha of the sparkle of Item `index`, or 0 while it does not show.
static func item_sparkle_alpha(t: float, index: int) -> float:
	var f := fposmod(SPARKLE_RATE * t + SPARKLE_INDEX_SHIFT * index, 1.0)
	return 1.0 - f / SPARKLE_SHOWS if f < SPARKLE_SHOWS else 0.0


static func palm_sway(t: float) -> float:
	return PALM_SWAY_RAD * sin(PALM_SWAY_RATE * t)


static func wave_phase(t: float) -> float:
	return WAVE_RATE * t


static func light_shift(t: float) -> float:
	return LIGHT_SPEED_PX * t


static func foam_shift(t: float) -> float:
	return FOAM_SPEED_PX * t


static func foam_distance(t: float) -> float:
	return FOAM_DISTANCE_PX + FOAM_SWAY_PX * sin(FOAM_SWAY_RATE * t)


static func wake_ring_radii(age: float) -> Vector2:
	return WAKE_START_RADII.lerp(WAKE_END_RADII, clampf(age / WAKE_LIFE, 0.0, 1.0))


static func wake_ring_alpha(age: float) -> float:
	return clampf(1.0 - age / WAKE_LIFE, 0.0, 1.0)


## The age of the piece of place `index` of `count` places that take turns, one piece each
## `interval` seconds. Each place starts a new piece every `count * interval` seconds.
static func piece_age(t: float, index: int, count: int, interval: float) -> float:
	return fposmod(t - index * interval, count * interval)


## The star alpha, from 0.2 to 0.9 and back in a cycle of 2 s. `phase` is a part of the cycle.
static func star_alpha(t: float, phase: float) -> float:
	var wave := sin(TAU * (t / STAR_CYCLE + phase))
	return lerpf(STAR_ALPHA.x, STAR_ALPHA.y, 0.5 + 0.5 * wave)


## Where a wave crest is on its drift path, from 0 to 1. `phase` is a part of the path.
static func crest_progress(t: float, phase: float) -> float:
	return fposmod(phase + CREST_DRIFT_PX * t / CREST_PATH_PX, 1.0)
