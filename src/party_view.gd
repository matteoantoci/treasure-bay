## The Party (game-flow spec part 4, prototype round 1, variant B): the end screen of a Voyage,
## after the Goal celebration of Labyrinth 20. The still water of Area 1, an all-land island with the
## island rules of the game, the chest on it, and the boat below the island with its bow up. Then,
## from start():
## - 0 to 2.4 s: the 20 Sea friends pop in one by one, every 120 ms, on an ellipse around the
##   island, in Labyrinth order, with the gap at the bottom for the boat.
## - 0.4 s: the chest opens, confetti bursts over it, and 8 Items fly out onto the island.
## - 3.0 s: the star of the Items folder pops in over the chest, with the number 20.
## - From 3.0 s: the Sea friends do a wave that loops.
## - From 2.0 s: a confetti burst every 1.5 s at a random place.
## The main scene shows the Party, plays its sounds, and reads the key presses.
class_name PartyView
extends Node2D

## Emitted when a Sea friend pops in. Its sound plays.
signal friend_popped(sea_friend: String)
## Emitted when the chest opens. The Goal sound plays.
signal chest_opened

## The values below are px at a visible size of REFERENCE_SIZE. The prototype is 1600 x 1000 px,
## so its values are 1.2 times larger here. x is from the centre, y from the top. The logo scales
## with the visible size and stays in its centre.
const REFERENCE_SIZE := Vector2(1920, 1200)
const ISLAND_TILES := Vector2i(4, 3)
const ISLAND_TILE_PX := 150.0
const ISLAND_CENTRE := Vector2(0, 576)
## The PRNG seed of the tile variants of the island.
const ISLAND_SEED := 1
## The chest is 228 px wide, closed and open.
const CHEST_WIDTH := 228.0
const CHEST_CENTRE := Vector2(0, 546)
## The boat: 180 px long, with its bow up.
const BOAT_LENGTH := 180.0
const BOAT_CENTRE := Vector2(0, 912)
## The ring of the Sea friends: an ellipse around the island centre. Sea friend k sits at the angle
## 110 + k * 320 / 19 degrees, clockwise from the right on the screen, so the gap of 40 degrees is at
## the bottom.
const RING_RADII := Vector2(780, 480)
const RING_START_DEG := 110.0
const RING_SWEEP_DEG := 320.0
const FRIEND_PX := 120.0
## The Sea friends pop in 120 ms apart. A pop scales from 0 to 1.25 in 350 ms, then to 1 in 150 ms.
const FRIEND_POP_SECONDS := 0.12
const POP_PEAK_SCALE := 1.25
const POP_UP_SECONDS := 0.35
const POP_DOWN_SECONDS := 0.15
## The chest opens at 0.4 s. The confetti bursts 40 px of the 760 px HUD scale over its centre.
const CHEST_OPENS_AT := 0.4
## The 8 Items fly out of the chest in 0.7 s onto an arc over the island centre: angle 200 + 20 i
## degrees on an ellipse.
const ITEM_KINDS: PackedStringArray = ["spiral_shell", "coral", "gem_stone", "glowing_star", "pearl", "starfish", "sand_dollar", "star"]
const ITEM_PX := 77.0
const ITEM_FLY_SECONDS := 0.7
const ITEM_FLY_CURVE := Motion.Easing.BACK
const ITEM_START := Vector2(0, 528)
const ITEM_ARC_CENTRE := Vector2(0, 588)
const ITEM_ARC_RADII := Vector2(252, 180)
const ITEM_ARC_START_DEG := 200.0
const ITEM_ARC_STEP_DEG := 20.0
## At 3.0 s the star pops in over the chest. The number 20 shows 150 ms later, in the rounded font.
const STAR_AT := 3.0
const STAR_CENTRE := Vector2(0, 276)
const STAR_PX := 228.0
const STAR_TEXT := "20"
const NUMBER_AT := STAR_AT + 0.15
const NUMBER_FONT_PX := 73
## The number sits 6 % of the star size below the star centre.
const NUMBER_DROP_PX := 0.06 * STAR_PX
const NUMBER_COLOUR := Color("#7a4a00")
const NUMBER_SHADOW := Color(1, 1, 1, 0.53)
const NUMBER_SHADOW_PX := Vector2i(0, 2)
## The wave from 3.0 s: Sea friend k hops max(0, sin(4 t - 0.45 k)) times 40 px of the 760 px HUD
## scale, where t is the time from the wave start.
const WAVE_AT := 3.0
const WAVE_RATE := 4.0
const WAVE_PHASE := 0.45
const WAVE_HUD_PX := 40.0
## From 2.0 s a confetti burst every 1.5 s, in a rectangle over the middle of the screen.
const BURSTS_FROM := 2.0
const BURST_SECONDS := 1.5
const BURST_AREA := Rect2(-600, 240, 1200, 480)
## The input is locked for the first 3.0 s.
const INPUT_LOCK_SECONDS := 3.0
## One frame moves the timeline by at most 1/30 s (times the time scale). The first open() loads the
## pictures, and the slow frame after it does not skip the first pops.
const MAX_STEP_SECONDS := 1.0 / 30.0
## The visible height of the HUD values: a HUD value in px is that value times visible height / 760
## on the screen (spec 8.1). The confetti and the wave use it.
const HUD_HEIGHT := 760.0

## Seconds from start(). It does not run before start() or while the game is paused.
var time := 0.0
var water := WaterView.new()
## All pictures of the Party, scaled with the visible size. The first open() makes them, so a
## launch does not load the 20 Sea friend pictures.
var logo := Node2D.new()
var island: TileMapLayer
var chest: Sprite2D
var items: Array[Sprite2D] = []
var boat: BoatView
## The Sea friends in Labyrinth order.
var friends: Array[Sprite2D] = []
var star: Sprite2D
var star_number: Label
## The confetti bursts, above all pictures.
var effects := Node2D.new()
## Logo px for one px of the 760 px HUD scale.
var _hud := REFERENCE_SIZE.y / HUD_HEIGHT

var _running := false
var _leaving := false
var _popped := 0
var _chest_open := false
var _number_shown := false
var _next_burst := BURSTS_FROM
var _tweens: Array[Tween] = []


func _init() -> void:
	water.name = "Water"
	logo.name = "Logo"
	effects.name = "Effects"
	water.show_area(Area.for_labyrinth(1))
	add_child(water)
	add_child(logo)
	logo.add_child(effects)
	visible = false


## Makes the pictures of the Party under the logo, from the bottom to the top.
func _build() -> void:
	island = OpeningScreen.new_island(ISLAND_TILES, ISLAND_TILE_PX, ISLAND_CENTRE, ISLAND_SEED)
	island.name = "Island"
	logo.add_child(island)
	chest = Sprite2D.new()
	chest.name = "Chest"
	chest.position = CHEST_CENTRE
	logo.add_child(chest)
	for kind in ITEM_KINDS:
		var sprite := Sprite2D.new()
		sprite.texture = load(Area.item_texture_path(kind))
		sprite.scale = _scale_for(sprite.texture, ITEM_PX)
		logo.add_child(sprite)
		items.append(sprite)
	boat = BoatView.new()
	boat.name = "Boat"
	boat.position = BOAT_CENTRE
	boat.rotation = PI
	boat.scale = Vector2.ONE * BOAT_LENGTH / BoatView.LENGTH_PX
	logo.add_child(boat)
	for id in SeaFriends.IDS:
		var sprite := Sprite2D.new()
		sprite.texture = load(SeaFriends.texture_path(id))
		logo.add_child(sprite)
		friends.append(sprite)
	star = Sprite2D.new()
	star.name = "Star"
	star.texture = load(Area.item_texture_path("star"))
	star.position = STAR_CENTRE
	logo.add_child(star)
	star_number = Label.new()
	star_number.name = "StarNumber"
	star_number.text = STAR_TEXT
	star_number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	star_number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	star_number.add_theme_font_override("font", GameFont.bold())
	star_number.add_theme_font_size_override("font_size", NUMBER_FONT_PX)
	star_number.add_theme_color_override("font_color", NUMBER_COLOUR)
	star_number.add_theme_color_override("font_shadow_color", NUMBER_SHADOW)
	star_number.add_theme_constant_override("shadow_offset_x", NUMBER_SHADOW_PX.x)
	star_number.add_theme_constant_override("shadow_offset_y", NUMBER_SHADOW_PX.y)
	star_number.size = Vector2(STAR_PX, STAR_PX)
	star_number.position = STAR_CENTRE + Vector2(0, NUMBER_DROP_PX) - star_number.size / 2.0
	logo.add_child(star_number)
	logo.move_child(effects, -1)


## The ring place of Sea friend `k` (from 0) in logo px.
static func friend_place(k: int) -> Vector2:
	var angle := deg_to_rad(RING_START_DEG + k * RING_SWEEP_DEG / (SeaFriends.IDS.size() - 1))
	return ISLAND_CENTRE + Vector2(cos(angle), sin(angle)) * RING_RADII


## The place of Item `i` (from 0) on the island after its flight, in logo px.
static func item_place(i: int) -> Vector2:
	var angle := deg_to_rad(ITEM_ARC_START_DEG + i * ITEM_ARC_STEP_DEG)
	return ITEM_ARC_CENTRE + Vector2(cos(angle), sin(angle)) * ITEM_ARC_RADII


## The hop of Sea friend `k` in logo px, up, at `wave_time` seconds from the wave start.
func wave_lift(wave_time: float, k: int) -> float:
	return maxf(0.0, sin(WAVE_RATE * wave_time - WAVE_PHASE * k)) * WAVE_HUD_PX * _hud


## Covers the visible rectangle. The logo scales with the visible size and stays in its centre.
func layout(visible: Rect2) -> void:
	var u := minf(visible.size.y / REFERENCE_SIZE.y, visible.size.x / REFERENCE_SIZE.x)
	logo.scale = Vector2.ONE * u
	logo.position = visible.get_center() - Vector2(0, REFERENCE_SIZE.y / 2.0) * u
	var island_px := Vector2(ISLAND_TILES) * ISLAND_TILE_PX
	var island_rect := Rect2(logo.position + (ISLAND_CENTRE - island_px / 2.0) * u, island_px * u)
	water.layout(visible, island_rect, ISLAND_TILE_PX * u)
	_hud = visible.size.y / HUD_HEIGHT / u


## Shows the still picture of the start: the island, the closed chest, and the boat. No Sea friend,
## no Item, and no star show yet. The timeline waits for start().
func open() -> void:
	if friends.is_empty():
		_build()
	_stop()
	time = 0.0
	_popped = 0
	_chest_open = false
	_number_shown = false
	_next_burst = BURSTS_FROM
	_set_chest(LabyrinthView.CHEST_CLOSED)
	for item in items:
		item.visible = false
	for k in friends.size():
		friends[k].visible = false
		friends[k].position = friend_place(k)
	star.visible = false
	star_number.visible = false
	visible = true


## Hides the Party, and its motion stops.
func close() -> void:
	_stop()
	visible = false


func _stop() -> void:
	for tween in _tweens:
		tween.kill()
	_tweens.clear()
	for child in effects.get_children():
		child.queue_free()
	_running = false
	_leaving = false


## Starts the timeline at 0 s: the first Sea friend pops in at once.
func start() -> void:
	_running = true
	_advance(0.0)


## True when a press ends the Party: after the first 3.0 s, and only one time.
func accepts_press() -> bool:
	return _running and not _leaving and time >= INPUT_LOCK_SECONDS


## A press ends the Party. The Party goes on until the main scene hides it.
func leave() -> void:
	_leaving = true


func _process(delta: float) -> void:
	if _running:
		_advance(minf(delta, MAX_STEP_SECONDS * Engine.time_scale))


## Moves the time on by `delta` and runs each step of the timeline that is due.
func _advance(delta: float) -> void:
	time += delta
	while _popped < friends.size() and time >= _popped * FRIEND_POP_SECONDS:
		_pop_friend(_popped)
		_popped += 1
	if not _chest_open and time >= CHEST_OPENS_AT:
		_chest_open = true
		_open_chest()
	if not star.visible and time >= STAR_AT:
		_pop(star, _scale_for(star.texture, STAR_PX))
	if not _number_shown and time >= NUMBER_AT:
		_number_shown = true
		star_number.visible = true
	if time >= _next_burst:
		var place := BURST_AREA.position + Vector2(randf(), randf()) * BURST_AREA.size
		Burst.confetti().fire(effects, place, _hud)
		_next_burst += BURST_SECONDS
	if time >= WAVE_AT:
		for k in friends.size():
			friends[k].position = friend_place(k) - Vector2(0, wave_lift(time - WAVE_AT, k))


func _pop_friend(k: int) -> void:
	var friend := friends[k]
	_pop(friend, _scale_for(friend.texture, FRIEND_PX))
	friend_popped.emit(SeaFriends.IDS[k])


## Pops `sprite` in: its scale goes from 0 to 1.25 times `full`, then to `full`.
func _pop(sprite: Sprite2D, full: Vector2) -> void:
	sprite.scale = Vector2.ZERO
	sprite.visible = true
	var tween := _new_tween()
	Motion.shape(tween.tween_property(sprite, "scale", full * POP_PEAK_SCALE, POP_UP_SECONDS), Motion.Easing.OUT)
	Motion.shape(tween.tween_property(sprite, "scale", full, POP_DOWN_SECONDS), Motion.Easing.INOUT)


## The chest opens, the confetti bursts over it, and the 8 Items fly out onto the island.
func _open_chest() -> void:
	_set_chest(LabyrinthView.CHEST_OPEN)
	var top := CHEST_CENTRE - Vector2(0, Motion.CONFETTI_RISE_PX * _hud)
	Burst.confetti().fire(effects, top, _hud)
	var tween := _new_tween().set_parallel()
	for i in items.size():
		items[i].position = ITEM_START
		items[i].visible = true
		Motion.shape(tween.tween_property(items[i], "position", item_place(i), ITEM_FLY_SECONDS), ITEM_FLY_CURVE)
	chest_opened.emit()


func _set_chest(texture: Texture2D) -> void:
	chest.texture = texture
	chest.scale = Vector2.ONE * CHEST_WIDTH / texture.get_width()


## The scale that gives the longer side of `texture` `px`.
func _scale_for(texture: Texture2D, px: float) -> Vector2:
	return Vector2.ONE * px / maxf(texture.get_width(), texture.get_height())


func _new_tween() -> Tween:
	_tweens = _tweens.filter(func(tween: Tween) -> bool: return tween.is_valid())
	var tween := create_tween()
	_tweens.append(tween)
	return tween
