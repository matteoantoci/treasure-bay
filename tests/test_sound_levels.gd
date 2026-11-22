extends RefCounted
## Tests for src/sound_levels.gd: the loudness rule of spec 9.6 and one level for
## each sound file of spec 9.2, 9.3, and 9.4.

const SoundLevels := preload("res://src/sound_levels.gd")

const SOUND_FILES := [
	"res://assets/audio/music/lagoon.mp3",
	"res://assets/audio/music/coral_reef.mp3",
	"res://assets/audio/music/open_sea.mp3",
	"res://assets/audio/music/sea_at_night.mp3",
	"res://assets/audio/effects/move.wav",
	"res://assets/audio/effects/wall.wav",
	"res://assets/audio/effects/item.wav",
	"res://assets/audio/effects/goal.wav",
	"res://assets/audio/effects/splash.wav",
	"res://assets/audio/effects/locked.wav",
	"res://assets/audio/effects/unlock.wav",
	"res://assets/audio/friends/crab.wav",
	"res://assets/audio/friends/octopus.wav",
	"res://assets/audio/friends/whale.wav",
	"res://assets/audio/friends/dolphin.wav",
	"res://assets/audio/friends/fish.wav",
	"res://assets/audio/friends/squid.wav",
	"res://assets/audio/friends/seal.wav",
	"res://assets/audio/friends/jellyfish.wav",
	"res://assets/audio/friends/otter.wav",
	"res://assets/audio/friends/penguin.wav",
	"res://assets/audio/friends/duck.wav",
	"res://assets/audio/friends/swan.wav",
	"res://assets/audio/friends/flamingo.wav",
]


func test_rule_uses_the_loudness_target(t) -> bool:
	t.assert_eq(SoundLevels.level_for(-18.0, -30.0, -20.0), 12.0, "effect: -18 - I")
	t.assert_eq(SoundLevels.level_for(-24.0, -12.0, -6.0), -12.0, "music: -24 - I")
	return true


func test_rule_keeps_the_true_peak_at_minus_1(t) -> bool:
	# -18 - (-30) = 12 dB would put the peak at -2 + 12 = 10 dBTP, so -1 - TP wins.
	t.assert_eq(SoundLevels.level_for(-18.0, -30.0, -2.0), -1.0 - -2.0, "peak limit")
	# A peak of exactly -1 dBTP after the gain is allowed.
	t.assert_eq(SoundLevels.level_for(-18.0, -20.0, -3.0), 2.0, "peak at -1 is fine")
	return true


func test_each_sound_file_has_a_level(t) -> bool:
	t.assert_eq(SoundLevels.LEVELS.size(), SOUND_FILES.size(), "one row for each file")
	for path: String in SOUND_FILES:
		t.assert_eq(SoundLevels.LEVELS.has(path), true, "level for %s" % path)
	return true


func test_each_level_follows_the_rule(t) -> bool:
	for path: String in SoundLevels.LEVELS:
		var row: Dictionary = SoundLevels.LEVELS[path]
		var target := -24.0 if path.begins_with("res://assets/audio/music/") else -18.0
		var expected := snappedf(SoundLevels.level_for(target, row.lufs, row.true_peak), 0.1)
		t.assert_eq(snappedf(SoundLevels.volume_db(path), 0.1), expected, "rule for %s" % path)
	return true
