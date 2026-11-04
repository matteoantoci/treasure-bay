## The settings panel (spec 11.2): a click on the gear opens it and pauses play, a second click
## closes it. It shows pictures only: the music row and the effects row (picture, minus, 4 bars,
## plus), the reset button, and the quit button. Reset and quit act only after a hold of 3 s.
##
## A child of the main scene. It loads settings.json (spec 12.4) and sets the bus volumes when the
## scene starts, and it uses the public part of the main scene: `save_store`, `progress`,
## `save_progress()`, and `start_with_fade()`.
class_name SettingsPanel
extends CanvasLayer

## Above the game, its effects, and its fade.
const LAYER := 10
const BACKGROUND_COLOUR := Color("#10213a")
const BORDER_COLOUR := Color(1, 1, 1, 0.85)
const BORDER_WIDTH := 4
const CORNER_RADIUS := 28
const MARGIN := 40
const ROW_GAP := 36
const ITEM_GAP := 24
const HOLD_GAP := 96
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


## The reset after a hold of 3 s: the panel closes and play unpauses, the progress goes back to
## Labyrinth 1 with an empty Collection and a total of 0, the game writes the save, and the screen
## fades in from dark (spec 8.8). The volume steps and settings.json stay (spec 12.4).
func _reset() -> void:
	close()
	var main := get_parent()
	main.progress = Progress.new()
	main.save_progress()
	main.start_with_fade()


## The quit after a hold of 3 s: the game writes the save, then quits. It is the only quit path
## (spec 11.1).
func _quit() -> void:
	get_parent().save_progress()
	for player: AudioStreamPlayer in get_tree().root.find_children("*", "AudioStreamPlayer", true, false):
		player.stop()
	await get_tree().create_timer(AUDIO_STOP_SECONDS, true, false, true).timeout
	get_tree().quit()


func _build() -> void:
	var centre := CenterContainer.new()
	# A CanvasItem under a CanvasLayer does not inherit the filter of the main scene (spec 3.5).
	centre.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre)
	var box := PanelContainer.new()
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
	reset_button = HoldButton.new(SettingsPicture.Kind.RESET)
	quit_button = HoldButton.new(SettingsPicture.Kind.DOOR)
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
	style.set_content_margin_all(MARGIN)
	style.anti_aliasing = true
	return style
