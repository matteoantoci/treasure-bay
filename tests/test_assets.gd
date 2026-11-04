extends RefCounted
# Spec §7.3 and §3.5: every PNG asset exists, imports with mipmaps, and loads as a texture with mipmaps.

const FRIENDS := ["blowfish", "crab", "dolphin", "duck", "fish", "flamingo", "jellyfish", "lobster",
	"octopus", "otter", "oyster", "penguin", "seal", "shark", "shrimp", "spouting_whale", "squid",
	"swan", "turtle", "whale"]
const ITEMS := ["spiral_shell", "starfish", "pearl", "coral", "sand_dollar", "gem_stone", "glowing_star", "star"]
const GOAL := ["chest_closed", "chest_open"]
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


func test_asset_list_has_62_pngs(t) -> bool:
	t.assert_eq(png_paths().size(), 1 + 31 + 20 + 8 + 2, "PNG count of spec §7.3")
	return true


func test_kenney_licence_exists(t) -> bool:
	t.assert_true(FileAccess.file_exists("res://assets/kenney/License.txt"), "assets/kenney/License.txt")
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
	"friends/crab.wav": 2.393, "friends/octopus.wav": 0.659, "friends/whale.wav": 2.500,
	"friends/dolphin.wav": 2.580, "friends/fish.wav": 2.040, "friends/squid.wav": 0.959,
	"friends/seal.wav": 2.250, "friends/jellyfish.wav": 2.500, "friends/otter.wav": 1.500,
	"friends/penguin.wav": 0.600, "friends/duck.wav": 0.817, "friends/swan.wav": 1.500,
	"friends/flamingo.wav": 1.500,
}


func test_each_imported_wav_keeps_its_source_length(t) -> bool:
	t.assert_eq(WAV_SECONDS.size(), 18, "WAV count of spec §9.3 and §9.4")
	for file in WAV_SECONDS:
		var path: String = "res://assets/audio/" + file
		var stream := load(path) as AudioStreamWAV
		t.assert_true(stream != null, path + " loads as AudioStreamWAV")
		if stream != null:
			var length := stream.get_length()
			t.assert_true(absf(length - WAV_SECONDS[file]) <= 0.02,
				"%s length %.3f s, source %.3f s" % [path, length, WAV_SECONDS[file]])
	return true
