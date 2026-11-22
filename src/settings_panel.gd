## The settings panel (spec 11.2): a click on the gear opens it and pauses play, a second click
## closes it. It shows pictures only: the music row and the effects row (picture, minus, 4 bars,
## plus), the reset button, and the quit button. Reset acts only after a hold of 8 s, and quit only
## after a hold of 3 s.
##
## A child of the main scene. It loads settings.json (spec 12.4) and sets the bus volumes when the
## scene starts. It uses `save_store` and `save_progress()` of the main scene, and it emits
## `reset_requested` for the reset.
class_name SettingsPanel
extends CanvasLayer

## Emitted after a hold of 8 s on the reset button, when the panel is closed and play runs again.
## The main scene resets the progress (spec 11.2).
signal reset_requested

## Above the game, its effects, and its fade.
const LAYER := 10
## The screen behind the panel gets darker.
const DIM_COLOUR := Color(0, 0, 0, 0.5)
## The cream-and-wood style of the logo (game-flow spec part 5, fix 7).
const BACKGROUND_COLOUR := Color("#fff3d6")
const BORDER_COLOUR := Color("#7a4a24")
const BORDER_WIDTH := 10
const CORNER_RADIUS := 40
const MARGIN_TOP_BOTTOM := 40
const MARGIN_SIDES := 56
const ROW_GAP := 28
const ITEM_GAP := 24
const HOLD_GAP := 96
## The reset needs a long hold, so the Child cannot reset the game by accident. Its ring has its own
## colour, so the Parent sees which hold runs.
const RESET_HOLD_SECONDS := 8.0
const RESET_RING_COLOUR := Color("#ff7a59")
const QUIT_HOLD_SECONDS := 3.0
## Dark brown: yellow has too little contrast on the light brown ring.
const QUIT_RING_COLOUR := SettingsPicture.FILL_COLOUR
## Before the quit, the players stop, and the audio server frees their playbacks in a later mix
## step. Without this wait, the quit prints a leaked music playback.
const AUDIO_STOP_SECONDS := 0.1

## The gear that opens and closes the panel.
@export var gear_path := NodePath("../Gear")
## The settings file. Tests set a store with their own folder before the scene enters the tree.
## Without one, settings.json is in the folder of the save file (user:// in the game).
var settings_store: SettingsStore
## The volume steps.
var settings: VolumeSettings

var music_minus: PictureButton
var music_plus: PictureButton
var music_bars: LevelBars
var effects_minus: PictureButton
var effects_plus: PictureButton
var effects_bars: LevelBars
var reset_button: HoldButton
var quit_button: HoldButton
## The dark layer behind the panel. It takes no clicks, so a click on the gear still closes the
## panel.
var dim := ColorRect.new()
var box := PanelContainer.new()


func _ready() -> void:
	layer = LAYER
	# The panel works while play is paused (spec 11.2).
	process_mode = PROCESS_MODE_ALWAYS
	visible = false
	if settings_store == null:
		settings_store = SettingsStore.new(get_parent().save_store.dir)
	settings = settings_store.load_settings()
	Sound.add_buses()
	settings.apply()
	_build()
	get_node(gear_path).pressed.connect(toggle)
	reset_button.held.connect(_reset)
	quit_button.held.connect(_quit)


func is_open() -> bool:
	return visible


func toggle() -> void:
	if is_open():
		close()
	else:
		open()


## Shows the panel and pauses play. The input for play is locked while the game is paused.
func open() -> void:
	visible = true
	get_tree().paused = true


## Hides the panel and unpauses play. A hold that has not ended stops.
func close() -> void:
	reset_button.release()
	quit_button.release()
	visible = false
	get_tree().paused = false


## Moves the step of `bus` by `change`, sets the bus volume, and writes settings.json.
func change_step(bus: StringName, change: int) -> void:
	settings.set_step(bus, settings.step_of(bus) + change)
	settings.apply()
	music_bars.step = settings.music_step
	effects_bars.step = settings.effects_step
	var error := settings_store.save(settings)
	if error != OK:
		push_warning("The settings were not saved: %s" % error_string(error))


## The reset after a hold of 8 s: the panel closes and play unpauses, then the main scene resets the
## progress. The volume steps and settings.json stay (spec 12.4).
func _reset() -> void:
	close()
	reset_requested.emit()


## The quit after a hold of 3 s: the game writes the save, then quits. It is the only quit path
## (spec 11.1).
func _quit() -> void:
	get_parent().save_progress()
	for player: AudioStreamPlayer in get_tree().root.find_children("*", "AudioStreamPlayer", true, false):
		player.stop()
	await get_tree().create_timer(AUDIO_STOP_SECONDS, true, false, true).timeout
	get_tree().quit()


func _build() -> void:
	dim.color = DIM_COLOUR
	# A CanvasItem under a CanvasLayer does not inherit the filter of the main scene (spec 3.5).
	dim.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var centre := CenterContainer.new()
	# A CanvasItem under a CanvasLayer does not inherit the filter of the main scene (spec 3.5).
	centre.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre)
	box.add_theme_stylebox_override("panel", _box_style())
	centre.add_child(box)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", ROW_GAP)
	box.add_child(rows)
	var music := _add_volume_row(rows, SettingsPicture.Kind.MUSIC, Sound.MUSIC_BUS)
	music_minus = music[0]
	music_bars = music[1]
	music_plus = music[2]
	var effects := _add_volume_row(rows, SettingsPicture.Kind.SPEAKER, Sound.EFFECTS_BUS)
	effects_minus = effects[0]
	effects_bars = effects[1]
	effects_plus = effects[2]
	var hold_row := _add_row(rows, HOLD_GAP)
	reset_button = HoldButton.new(SettingsPicture.Kind.RESET, RESET_HOLD_SECONDS, RESET_RING_COLOUR)
	quit_button = HoldButton.new(SettingsPicture.Kind.DOOR, QUIT_HOLD_SECONDS, QUIT_RING_COLOUR)
	hold_row.add_child(reset_button)
	hold_row.add_child(quit_button)


## A row with the picture of the bus, a minus button, the bars, and a plus button. Returns
## [minus, bars, plus].
func _add_volume_row(rows: Container, picture: SettingsPicture.Kind, bus: StringName) -> Array:
	var row := _add_row(rows, ITEM_GAP)
	var minus := PictureButton.new(SettingsPicture.Kind.MINUS)
	var bars := LevelBars.new()
	var plus := PictureButton.new(SettingsPicture.Kind.PLUS)
	bars.step = settings.step_of(bus)
	minus.pressed.connect(change_step.bind(bus, -1))
	plus.pressed.connect(change_step.bind(bus, 1))
	for control: Control in [SettingsPicture.new(picture), minus, bars, plus]:
		row.add_child(control)
	return [minus, bars, plus]


func _add_row(rows: Container, gap: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", gap)
	rows.add_child(row)
	return row


func _box_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOUR
	style.border_color = BORDER_COLOUR
	style.set_border_width_all(BORDER_WIDTH)
	style.set_corner_radius_all(CORNER_RADIUS)
	# The content margin counts from the outer edge, so it includes the border.
	style.content_margin_top = BORDER_WIDTH + MARGIN_TOP_BOTTOM
	style.content_margin_bottom = BORDER_WIDTH + MARGIN_TOP_BOTTOM
	style.content_margin_left = BORDER_WIDTH + MARGIN_SIDES
	style.content_margin_right = BORDER_WIDTH + MARGIN_SIDES
	style.anti_aliasing = true
	return style
