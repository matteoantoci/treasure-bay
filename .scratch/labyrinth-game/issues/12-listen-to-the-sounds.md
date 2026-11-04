# Listen to the sounds

Type: task
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

Does each sound on the short list in [research/sounds.md](../research/sounds.md) sound right for a 5-year-old?

[Source the sounds](10-source-the-sounds.md) chose the files from titles, tags, and ratings only. No one has listened to them. The Parent agreed to listen to the final short list.

Listening page: `open .scratch/labyrinth-game/prototypes/sounds-LISTEN/index.html`. It plays the Freesound previews in the page, links the 4 Pixabay tracks, and has a **Copy answers** button. Paste the copied text into the chat.

Checklist for the Parent:

1. Open each page link in `research/sounds.md`, and play the preview.
2. For each sound, write "keep" or "replace".
3. For the 4 music tracks, listen to the end of each track and to its start. Write whether the loop jumps.
4. For the 6 long recordings (Spouting whale, Whale, Blowfish, Otter, Swan, Flamingo), write the part that sounds best, for example "0:12 to 0:14".

The agent replaces each "replace" sound with the next candidate, and the Parent listens again. The ticket is resolved when every sound is "keep".

## Round 1 (2026-11-03)

- Keep: Lagoon music (Ocean Joy), Coral reef music (Marine Melody), and all 5 effects.
- Lagoon loop jumps. The spec uses the crossfade to the track start (pattern 3 in the `godot-audio` skill) for every music track, so a jump at the loop point does not matter. Coral reef has no jump.
- Replace: Open sea (Under the Sea) and Sea at night (Midnight Reef Sleep). The next candidates are The Whale's Dream and Starlight on the Waves. The Freesound fallbacks stay as backups.
- Sea friends: no answers. Some files are 30 s or longer. The agent cut 3 short parts from each of the 6 long files, from the loudest windows of the preview file. The parts are in `prototypes/sounds-LISTEN/clips/`.

Round 2 page: `open .scratch/labyrinth-game/prototypes/sounds-LISTEN/round2.html`.

## Round 2 (2026-11-03)

- Music: the Parent rejected The Whale's Dream, Starlight on the Waves, and both Freesound backups. Reason: they are not joyful. All music must be joyful, like the AndriiComposer ukulele tracks. Sea at night can be slower, but it must sound happy.
- Keep: Otter 0:33.3 to 0:34.8, Swan 0:44.6 to 0:46.1, Flamingo 0:00.3 to 0:01.8. The times are for the preview file. Check them against the original file before the cut.
- Replace: Spouting whale, Whale, Blowfish.
- Keep (second answer): Crab, Dolphin, Fish, Squid, Seal, Penguin.
- Replace (second answer): Octopus, Jellyfish.
- No answer: Duck, Frog. The paste was cut after Penguin. Round 3 asks again, with "keep" selected.

## Stop rule

Round 3 is the last round. After round 3:
- A Sea friend with no kept sound uses the splash.
- An Area with no kept music reuses a kept track: Ocean Joy or Marine Melody.
- A Sea friend with no answer keeps its pick from `research/sounds.md`.

Round 3 page: `open .scratch/labyrinth-game/prototypes/sounds-LISTEN/round3.html`. One Blowfish candidate (designerschoice) is CC BY 4.0 and needs a credit.

## Clip processing

The build must cut each kept clip from the original Freesound file and repeat this processing:
- Round 2 clips (Otter, Swan, Flamingo): cut at the kept times, fade-in 0.05 s, fade-out 0.2 s. No gain.
- Round 3 clips: cut at the times in the Copy answers line, fade-in 0.05 s, fade-out 0.2 s. The page clips also have a peak gain to -3 dB. Do not copy that gain: the loudness step in `research/sounds.md` sets each level in the build.

## Final list (2026-11-03, after round 3)

- Music: Lagoon Ocean Joy, Coral reef Marine Melody, Open sea [Fairy Land](https://pixabay.com/music/happy-childrens-tunes-fairy-land-440535/), Sea at night [Cloud of Dreams](https://pixabay.com/music/acoustic-group-cloud-of-dreams-380619/). All 4 are by AndriiComposer, Pixabay Content License. Every track uses the crossfade to its start, so a loop jump is not audible.
- Effects: the 5 first picks.
- Sea friends with an own sound: Crab, Dolphin, Fish, Squid, Seal, Penguin, Duck (first picks, whole file); Otter 0:33.3 to 0:34.8 (CC BY 4.0, credit); Swan 0:44.6 to 0:46.1; Flamingo 0:00.3 to 0:01.8; Whale [Whale.wav by claretcanelon](https://freesound.org/people/claretcanelon/sounds/458626/) 0:01.3 to 0:03.8; Octopus [Cartoon - Smoochy Squeak + Plop by Breviceps](https://freesound.org/people/Breviceps/sounds/444494/), whole file; Jellyfish [Bubble.wav by megmcduffee](https://freesound.org/people/megmcduffee/sounds/332597/) 0:06.85 to 0:09.35. All CC0 except Otter.
- Sea friends with the splash: Spouting whale, Blowfish, Shark, Lobster, Shrimp, Oyster, Turtle.
- Frog stays a spare, not one of the 20 Sea friends.
- Duck and Frog had "keep" selected in round 3 and the paste had no other answer, so they keep their first picks by the stop rule.
- Clip processing: see "Clip processing" in [ticket 12](12-listen-to-the-sounds.md).
