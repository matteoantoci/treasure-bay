extends RefCounted
# Spec §7.3, §9, and §3.5 (spec 14.1 test 10): every asset exists and loads, every PNG imports with
# mipmaps, each WAV keeps its length, and credits.txt has a line for each sound file.

const FRIENDS := ["blowfish", "crab", "dolphin", "duck", "fish", "flamingo", "jellyfish", "lobster",
	"octopus", "otter", "oyster", "penguin", "seal", "shark", "shrimp", "spouting_whale", "squid",
	"swan", "turtle", "whale"]
const ITEMS := ["spiral_shell", "starfish", "pearl", "coral", "sand_dollar", "gem_stone", "glowing_star", "star"]
const GOAL := ["chest_closed", "chest_open", "padlock"]
const TILES := [6, 7, 8, 9, 22, 23, 24, 25, 36, 37, 38, 39, 40, 41, 49, 50, 51, 52, 53, 54, 55, 56, 57,
	65, 66, 67, 70, 71, 72, 87, 88]


static func png_paths() -> Array[String]:
	var paths: Array[String] = ["res://assets/kenney/ships/boat_white_sail.png"]
	for n in TILES:
		paths.append("res://assets/kenney/tiles/tile_%02d.png" % n)
	for id in FRIENDS:
		paths.append("res://assets/sprites/friends/%s.png" % id)
	for id in ITEMS:
		paths.append("res://assets/sprites/items/%s.png" % id)
	for id in GOAL:
		paths.append("res://assets/sprites/goal/%s.png" % id)
	return paths


func test_asset_list_has_63_pngs(t) -> bool:
	t.assert_eq(png_paths().size(), 1 + 31 + 20 + 8 + 3, "PNG count of spec §7.3")
	return true


func test_kenney_licence_exists(t) -> bool:
	t.assert_true(FileAccess.file_exists("res://assets/kenney/License.txt"), "assets/kenney/License.txt")
	return true


## Spec 15 criterion 14: every PNG .import file of the project, not only the PNG files of §7.3.
func test_every_png_import_file_of_the_project_generates_mipmaps(t) -> bool:
	var import_paths := _png_import_paths("res://")
	t.assert_eq(import_paths.size(), png_paths().size(), "the project has only the PNG files of spec §7.3")
	for import_path in import_paths:
		var cfg := ConfigFile.new()
		t.assert_eq(cfg.load(import_path), OK, import_path + " parses")
		t.assert_eq(cfg.get_value("params", "mipmaps/generate", false), true, import_path + " mipmaps/generate")
	return true


func test_every_png_import_generates_mipmaps(t) -> bool:
	for path in png_paths():
		var import_path := path + ".import"
		t.assert_true(FileAccess.file_exists(import_path), import_path + " exists")
		var cfg := ConfigFile.new()
		t.assert_eq(cfg.load(import_path), OK, import_path + " parses")
		t.assert_eq(cfg.get_value("params", "mipmaps/generate", false), true, import_path + " mipmaps/generate")
	return true


func test_every_png_loads_as_texture_with_mipmaps(t) -> bool:
	for path in png_paths():
		var tex := load(path) as Texture2D
		t.assert_true(tex != null, path + " loads as Texture2D")
		if tex != null:
			t.assert_true(tex.get_image().has_mipmaps(), path + " has mipmaps")
	return true


# Spec §9.5 and §13.4: each WAV keeps its full length after import (Edit > Trim off).
# The durations come from `ffprobe` on the source WAV files.
const WAV_SECONDS := {
	"effects/move.wav": 0.875, "effects/wall.wav": 1.133, "effects/item.wav": 0.471,
	"effects/goal.wav": 3.700, "effects/splash.wav": 1.331,
	"effects/locked.wav": 0.600, "effects/unlock.wav": 0.500,
	"friends/crab.wav": 2.393, "friends/octopus.wav": 0.659, "friends/whale.wav": 2.500,
	"friends/dolphin.wav": 2.580, "friends/fish.wav": 2.040, "friends/squid.wav": 0.959,
	"friends/seal.wav": 2.250, "friends/jellyfish.wav": 2.500, "friends/otter.wav": 1.500,
	"friends/penguin.wav": 0.600, "friends/duck.wav": 0.817, "friends/swan.wav": 1.500,
	"friends/flamingo.wav": 1.500,
}


func test_each_imported_wav_keeps_its_source_length(t) -> bool:
	t.assert_eq(WAV_SECONDS.size(), 20, "WAV count of spec §9.3 and §9.4, and the 2 padlock sounds of game-flow spec Part 2")
	for file in WAV_SECONDS:
		var path: String = "res://assets/audio/" + file
		var stream := load(path) as AudioStreamWAV
		t.assert_true(stream != null, path + " loads as AudioStreamWAV")
		if stream != null:
			var length := stream.get_length()
			t.assert_true(absf(length - WAV_SECONDS[file]) <= 0.02,
				"%s length %.3f s, source %.3f s" % [path, length, WAV_SECONDS[file]])
	return true


# Spec §9.2: the 4 music files.
const MUSIC := ["lagoon", "coral_reef", "open_sea", "sea_at_night"]


func test_each_music_file_loads_and_does_not_loop(t) -> bool:
	for id in MUSIC:
		var path := "res://assets/audio/music/%s.mp3" % id
		var stream := load(path) as AudioStreamMP3
		t.assert_true(stream != null, path + " loads as AudioStreamMP3")
		if stream != null:
			t.assert_true(stream.get_length() > 100.0, path + " has the whole track")
			t.assert_eq(stream.loop, false, path + " imports with Loop off")
	return true


# Spec §9.2 to §9.4 and §9.8: sound file -> [title, author, page] in credits.txt.
const CREDITS := {
	"music/lagoon.mp3": ["Ocean Joy", "AndriiComposer", "https://pixabay.com/music/cartoons-ocean-joy-380628/"],
	"music/coral_reef.mp3": ["Marine Melody", "AndriiComposer", "https://pixabay.com/music/happy-childrens-tunes-marine-melody-380629/"],
	"music/open_sea.mp3": ["Fairy Land", "AndriiComposer", "https://pixabay.com/music/happy-childrens-tunes-fairy-land-440535/"],
	"music/sea_at_night.mp3": ["Cloud of Dreams", "AndriiComposer", "https://pixabay.com/music/acoustic-group-cloud-of-dreams-380619/"],
	"effects/move.wav": ["Water Swish", "dslrguide", "https://freesound.org/people/dslrguide/sounds/321489/"],
	"effects/wall.wav": ["Boing 2", "magnuswaker", "https://freesound.org/people/magnuswaker/sounds/540790/"],
	"effects/item.wav": ["Bubble Pop", "YehawSnail", "https://freesound.org/people/YehawSnail/sounds/683587/"],
	"effects/goal.wav": ["Success Fanfare Trumpets.mp3", "FunWithSound", "https://freesound.org/people/FunWithSound/sounds/456966/"],
	"effects/splash.wav": ["Splash", "swordofkings128", "https://freesound.org/people/swordofkings128/sounds/398032/"],
	"effects/locked.wav": ["Impact Sounds", "Kenney", "https://kenney.nl/assets/impact-sounds"],
	"effects/unlock.wav": ["RPG Audio", "Kenney", "https://kenney.nl/assets/rpg-audio"],
	"friends/crab.wav": ["scissors;snips.wav", "Abir19", "https://freesound.org/people/Abir19/sounds/629513/"],
	"friends/octopus.wav": ["Cartoon - Smoochy Squeak + Plop", "Breviceps", "https://freesound.org/people/Breviceps/sounds/444494/"],
	"friends/whale.wav": ["Whale.wav", "claretcanelon", "https://freesound.org/people/claretcanelon/sounds/458626/"],
	"friends/dolphin.wav": ["Dolphin Noise-.wav", "jfournier18", "https://freesound.org/people/jfournier18/sounds/456151/"],
	"friends/fish.wav": ["Bubbles Light Short Descend.wav", "murraysortz", "https://freesound.org/people/murraysortz/sounds/192496/"],
	"friends/squid.wav": ["Bottle Squirt.wav", "jimbo555", "https://freesound.org/people/jimbo555/sounds/630484/"],
	"friends/seal.wav": ["Sound of a Seal", "florianreichelt", "https://freesound.org/people/florianreichelt/sounds/450751/"],
	"friends/jellyfish.wav": ["Bubble.wav", "megmcduffee", "https://freesound.org/people/megmcduffee/sounds/332597/"],
	"friends/otter.wav": ["Otters Squeaking.wav", "Motion_S", "https://freesound.org/people/Motion_S/sounds/221761/"],
	"friends/penguin.wav": ["Penguin Squeak", "Breviceps", "https://freesound.org/people/Breviceps/sounds/705839/"],
	"friends/duck.wav": ["single quack from a duck", "Mikes-MultiMedia", "https://freesound.org/people/Mikes-MultiMedia/sounds/418509/"],
	"friends/swan.wav": ["Trumpeter Swans little honks 2pm TTP B 180531.mp3", "TRP", "https://freesound.org/people/TRP/sounds/572743/"],
	"friends/flamingo.wav": ["Flamingos", "Breviceps", "https://freesound.org/people/Breviceps/sounds/535778/"],
}


func test_credits_has_a_line_for_each_sound_file(t) -> bool:
	t.assert_eq(CREDITS.size(), 24, "sound file count of spec §9.2 to §9.4, and the 2 padlock sounds")
	var text := FileAccess.get_file_as_string("res://credits.txt")
	var lines := Array(text.split("\n"))
	for file in CREDITS:
		t.assert_true(FileAccess.file_exists("res://assets/audio/" + file), file + " exists")
		var credit: Array = CREDITS[file]
		var line := "\"%s\" by %s" % [credit[0], credit[1]]
		t.assert_true(lines.any(func(l: String) -> bool: return l.begins_with(line)), "credits.txt has the line %s for %s" % [line, file])
		t.assert_true(text.contains(credit[2]), "credits.txt has the page of %s" % file)
	return true


func test_credits_has_the_otter_licence_and_the_art(t) -> bool:
	var lines := FileAccess.get_file_as_string("res://credits.txt").split("\n")
	for line in [
		"== CC BY 4.0 (credit necessary) ==",
		"  Licence: CC BY 4.0, https://creativecommons.org/licenses/by/4.0/",
		"  Change: we cut a short part (0:33.3 to 0:34.8) of the Freesound preview file and converted it to WAV.",
		"\"Pirate Pack\" by Kenney (www.kenney.nl), CC0 - https://kenney.nl/assets/pirate-pack",
		"The Sea friends, the Items, and the treasure chest were generated for this family game",
	]:
		t.assert_true(lines.has(line), "credits.txt has the line: " + line)
	return true


## The .png.import files under `dir`. Godot does not import hidden folders or folders with a
## .gdignore file.
func _png_import_paths(dir: String) -> Array[String]:
	var paths: Array[String] = []
	if FileAccess.file_exists(dir.path_join(".gdignore")):
		return paths
	for file_name in DirAccess.get_files_at(dir):
		if file_name.ends_with(".png.import"):
			paths.append(dir.path_join(file_name))
	for sub in DirAccess.get_directories_at(dir):
		if not sub.begins_with("."):
			paths.append_array(_png_import_paths(dir.path_join(sub)))
	return paths
