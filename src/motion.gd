## All motion values of spec 8 (and the boat timings of spec 5.2 and 5.3) at the medium amount, in
## one place, with the pure functions of the idle and wake motion. The water, the foam and the Area
## decoration do not move (game-flow spec part 5, fix 2).
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
const SPARKLE_COLOUR := Color.WHITE
## The palm of the Goal island sways 0.08 sin(1.5 t) rad.
const PALM_SWAY_RAD := 0.08
const PALM_SWAY_RATE := 1.5

# Wake (game-flow spec part 5, fix 9): soft white dots behind the stern, a new dot every 40 ms
# while the boat moves.
const WAKE_DOTS_PER_SECOND := 1.0 / 0.04
## Each dot starts 58 px behind the boat centre, just behind the stern of the 110 px boat, on the
## move line. The dots start a little to the left and to the right in turn.
const WAKE_BEHIND_PX := 58.0
const WAKE_SIDE_PX := 4.0
## The radius starts at 9 % of the 130 px tile and gets smaller to 40 % of that with age. The
## opacity starts at 42 % and goes to 0 at the end of the life of 0.6 s.
const WAKE_START_RADIUS_PX := 0.09 * 130.0
const WAKE_END_RADIUS_SCALE := 0.4
const WAKE_START_ALPHA := 0.42
const WAKE_LIFE := 0.6

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

# Padlock on the chest (game-flow spec Part 2).
## A visit to the locked chest: the chest moves sideways by these offsets, linear, in 360 ms in all
## (the pile-pals soft shake). The first offset is the rest place.
const CHEST_SHAKE_PX := [0.0, -10.0, 8.0, -6.0, 4.0, -2.0, 0.0]
const CHEST_SHAKE_SECONDS := 0.36
## Each empty Item slot pulses two times: scale 1.0 to 1.15 in 300 ms, and back in 300 ms.
const SLOT_PULSE_SCALE := 1.15
const SLOT_PULSE_SECONDS := 0.3
const SLOT_PULSE_COUNT := 2
const SLOT_PULSE_CURVE := Easing.INOUT
## The last Item arrives in its slot: the padlock grows to 1.3 times its size and fades out in
## 300 ms, with 6 sparkles.
const PADLOCK_POP_SCALE := 1.3
const PADLOCK_POP_SECONDS := 0.3
const PADLOCK_POP_CURVE := Easing.OUT
const PADLOCK_SPARKLE_COUNT := 6
const PADLOCK_SPARKLE_SPEED_PX := 100.0
const PADLOCK_SPARKLE_LIFE := 0.5

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
## chest and the boat. The chest of 115 % of a tile sits on the seam of the Goal island tile and
## the outer tile (game-flow spec part 5, fix 4), so the Sea friend grows at x = +175, right of the
## chest, over the outer tile. The open chest and the boat stay in view.
const FRIEND_START_PX := Vector2(175, 60)
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


static func wake_dot_radius(age: float) -> float:
	return WAKE_START_RADIUS_PX * lerpf(1.0, WAKE_END_RADIUS_SCALE, clampf(age / WAKE_LIFE, 0.0, 1.0))


static func wake_dot_alpha(age: float) -> float:
	return WAKE_START_ALPHA * clampf(1.0 - age / WAKE_LIFE, 0.0, 1.0)
