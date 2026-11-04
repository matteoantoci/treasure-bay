# 29: Sounds and credits

**What to build:** All sound files that the game needs exist in the project, processed and ready for import, and `credits.txt` is complete. Spec sections 9.3 to 9.6, 9.8, 13.3. This ticket needs no Parent action.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [x] The 22 sound files are downloaded with no login, cut at the spec times, faded, and set to the loudness targets (spec 9.5, 9.6).
- [x] `credits.txt` matches spec 9.8.

## Comments

- All 22 URLs of spec 9.2 to 9.4 returned HTTP 200 to `curl -A 'Mozilla/5.0'` on 2026-11-04 with no login. The `ffprobe` durations match the tables. The fallback clips were not needed.
- Music end points (open gap 7, the first time in the last 20 s from which the momentary loudness stays more than 6 dB below the integrated loudness): lagoon 162.2 s, coral_reef 133.5 s, open_sea 148.9 s, sea_at_night 148.2 s. Cut with `-t <end> -c copy`.
- The clip command in spec 9.5 (`-ss` after `-i` together with `afade`) runs the fades before the seek, so the Otter, Swan, and Jellyfish clips came out silent. The cuts use `-af "atrim=start=S:duration=D,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.05,afade=t=out:st=D-0.2:d=0.2"` instead. An envelope cross-correlation against the listen-page clips (Whale r3_wh_claret, Jellyfish r3_jf_bubble, Otter_3, Swan_3, Flamingo_1) gives 0.995 to 1.0 at a lag of 0 ms, so the cut times match the clips that the Parent chose.
- `src/sound_levels.gd` holds the measured LUFS, true peak, and `volume_db` for each file, and `level_for()` holds the rule of spec 9.6. `tests/test_sound_levels.gd` checks the rule and one row for each of the 22 files.
- Each WAV `.import` file has `edit/trim=true` and `edit/loop_mode=1` (Disabled). The MP3 files import with `loop=false`. A headless load of all 22 files works.
