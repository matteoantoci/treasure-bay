extends RefCounted
## Player volume_db for each sound file (spec 9.6).
##
## Each row holds the integrated loudness ("lufs", LUFS) and the true peak
## ("true_peak", dBTP) of the processed file, measured one time with
## `ffmpeg -i f -af ebur128=peak=true -f null -`, and the player level that
## level_for() gives for them. Music aims at -24 LUFS, effects and Sea friend
## sounds at -18 LUFS. The true peak after the level stays at or below -1 dBTP.

const MUSIC_TARGET_LUFS := -24.0
const EFFECT_TARGET_LUFS := -18.0
const PEAK_LIMIT_DBTP := -1.0

const LEVELS := {
	"res://assets/audio/music/lagoon.mp3": {"lufs": -11.5, "true_peak": 0.5, "volume_db": -12.5},
	"res://assets/audio/music/coral_reef.mp3": {"lufs": -12.2, "true_peak": 0.2, "volume_db": -11.8},
	"res://assets/audio/music/open_sea.mp3": {"lufs": -10.5, "true_peak": 0.6, "volume_db": -13.5},
	"res://assets/audio/music/sea_at_night.mp3": {"lufs": -10.0, "true_peak": 0.7, "volume_db": -14.0},
	"res://assets/audio/effects/move.wav": {"lufs": -31.3, "true_peak": -2.4, "volume_db": 1.4},
	"res://assets/audio/effects/wall.wav": {"lufs": -21.3, "true_peak": -0.9, "volume_db": -0.1},
	"res://assets/audio/effects/item.wav": {"lufs": -29.0, "true_peak": -6.5, "volume_db": 5.5},
	"res://assets/audio/effects/goal.wav": {"lufs": -20.2, "true_peak": -6.6, "volume_db": 2.2},
	"res://assets/audio/effects/splash.wav": {"lufs": -24.6, "true_peak": -0.1, "volume_db": -0.9},
	"res://assets/audio/effects/locked.wav": {"lufs": -24.4, "true_peak": -0.9, "volume_db": -0.1},
	"res://assets/audio/effects/unlock.wav": {"lufs": -20.2, "true_peak": 0.4, "volume_db": -1.4},
	"res://assets/audio/friends/crab.wav": {"lufs": -33.0, "true_peak": -5.6, "volume_db": 4.6},
	"res://assets/audio/friends/octopus.wav": {"lufs": -25.5, "true_peak": -5.6, "volume_db": 4.6},
	"res://assets/audio/friends/whale.wav": {"lufs": -39.4, "true_peak": -26.2, "volume_db": 21.4},
	"res://assets/audio/friends/dolphin.wav": {"lufs": -10.7, "true_peak": -0.5, "volume_db": -7.3},
	"res://assets/audio/friends/fish.wav": {"lufs": -31.5, "true_peak": -7.7, "volume_db": 6.7},
	"res://assets/audio/friends/squid.wav": {"lufs": -18.1, "true_peak": -0.0, "volume_db": -1.0},
	"res://assets/audio/friends/seal.wav": {"lufs": -30.9, "true_peak": -12.0, "volume_db": 11.0},
	"res://assets/audio/friends/jellyfish.wav": {"lufs": -19.7, "true_peak": -1.7, "volume_db": 0.7},
	"res://assets/audio/friends/otter.wav": {"lufs": -23.3, "true_peak": -8.9, "volume_db": 5.3},
	"res://assets/audio/friends/penguin.wav": {"lufs": -19.9, "true_peak": -9.4, "volume_db": 1.9},
	"res://assets/audio/friends/duck.wav": {"lufs": -39.1, "true_peak": -22.0, "volume_db": 21.0},
	"res://assets/audio/friends/swan.wav": {"lufs": -24.5, "true_peak": -13.6, "volume_db": 6.5},
	"res://assets/audio/friends/flamingo.wav": {"lufs": -23.4, "true_peak": -10.1, "volume_db": 5.4},
}


## The player level in dB for a file with loudness `lufs` and true peak `true_peak`.
static func level_for(target_lufs: float, lufs: float, true_peak: float) -> float:
	var level := target_lufs - lufs
	if true_peak + level > PEAK_LIMIT_DBTP:
		level = PEAK_LIMIT_DBTP - true_peak
	return level


## The player volume_db for the sound file at `path` (a res:// path).
static func volume_db(path: String) -> float:
	return LEVELS[path].volume_db
