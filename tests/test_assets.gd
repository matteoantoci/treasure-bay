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
