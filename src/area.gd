## The Area table: which Area each Labyrinth is in (spec 4.3, 4.4), and the Item kinds, the water
## colours, the decoration (spec 7.2), and the music track (spec 9.2) of each Area. Areas are
## numbered 1 to 4.
class_name Area
extends RefCounted

const COUNT := 4
## Each Area holds 5 Labyrinths.
const LABYRINTHS_PER_AREA := 5

## The water effect of each Area (spec 7.2, 8.2).
enum Decoration { WAVES, BUBBLES, DROPLETS, STARS }

## Item kinds of Areas 1 to 4, in list order. Each kind is a file in assets/sprites/items/.
const ITEM_KINDS := [
	["spiral_shell", "starfish", "pearl"],
	["coral", "sand_dollar"],
	["gem_stone", "spiral_shell"],
	["glowing_star", "star"],
]
## The deep colour fills the water. The light colour draws the wave lines.
const DEEP_COLOURS: Array[Color] = [Color("#3fb4d8"), Color("#2aa6a0"), Color("#1f6fb5"), Color("#14284f")]
const LIGHT_COLOURS: Array[Color] = [Color("#7fd8ef"), Color("#76d6c4"), Color("#5aa0dc"), Color("#3a5a92")]
const DECORATIONS: Array[Decoration] = [
	Decoration.WAVES,
	Decoration.BUBBLES,
	Decoration.DROPLETS,
	Decoration.STARS,
]
const MUSIC_PATHS: PackedStringArray = [
	"res://assets/audio/music/lagoon.mp3",
	"res://assets/audio/music/coral_reef.mp3",
	"res://assets/audio/music/open_sea.mp3",
	"res://assets/audio/music/sea_at_night.mp3",
]


## Labyrinths 1 to 5 are Area 1, 6 to 10 Area 2, 11 to 15 Area 3, 16 to 20 Area 4, then the
## order starts again from 21.
static func for_labyrinth(number: int) -> int:
	return ((number - 1) / LABYRINTHS_PER_AREA) % COUNT + 1


static func item_kinds(area: int) -> PackedStringArray:
	return PackedStringArray(ITEM_KINDS[area - 1])


static func item_texture_path(kind: String) -> String:
	return "res://assets/sprites/items/%s.png" % kind


static func deep_colour(area: int) -> Color:
	return DEEP_COLOURS[area - 1]


static func light_colour(area: int) -> Color:
	return LIGHT_COLOURS[area - 1]


static func decoration(area: int) -> Decoration:
	return DECORATIONS[area - 1]


static func music_path(area: int) -> String:
	return MUSIC_PATHS[area - 1]
