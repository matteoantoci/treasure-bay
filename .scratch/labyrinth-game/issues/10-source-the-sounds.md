# Source the sounds

Type: research
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

Which exact sound files and music files does the game use, and where do they come from?

The game needs:

- 4 calm music loops, one for each Area.
- Effects: a soft water swish for a move, a soft "boing" at a wall, a pop for an Item, a happy fanfare of about 3 seconds at the Goal, and a splash for a Sea friend.
- One sound for each Sea friend that has a good real or cartoon sound. The other Sea friends use the splash.

For each file, record the source, the licence, and a direct link. Write a `credits.txt` list. The game is for private use by one family, but prefer CC0 or no-credit licences.

## Context

From [Sound](06-sound.md): the decisions above. From [Levels and difficulty](05-levels-and-difficulty.md): the list of 20 Sea friends.

The Parent gave this list of sources (https://x.com/froessell/status/2115367991835513154):

- Kenney Audio, CC0: https://kenney.nl/assets/category:Audio
- Sonniss GameAudioGDC bundles, royalty free.
- Freesound: each sound has its own licence (CC0, CC BY, or CC BY-NC).
- ChipTone and jsfxr: generated sounds, CC0.
- Pixabay Music: free, no credit required.
- ElevenLabs Sound Effects: the free plan is for personal use only.

Consult the `audio-design` and `godot-audio` skills in `.claude/skills/`. Godot needs the files in OGG or WAV format.

## Answer

- **Music:** 4 calm children's tracks from Pixabay Music (no credit needed): Ocean Joy, Marine Melody, Under the Sea, and Midnight Reef Sleep. Each track has a CC0 fallback from Freesound. The Area names are placeholders.
- **Effects:** 5 CC0 files from Freesound: Water Swish, Boing 2, Bubble Pop, Success Fanfare Trumpets (4.4 s), and Splash. Each effect has a CC0 alternative. Kenney has no water, animal, or music files that fit.
- **Sea friends:** 15 Sea friends get an own CC0 sound. Shark, Lobster, Shrimp, Oyster, and Turtle use the splash. Only the Otter file is CC BY 4.0 and needs a credit.
- **Format:** effects as WAV (mono, 16-bit), music as OGG or MP3 with the Loop import option. Godot also imports MP3. Downloads from Freesound need a free account. Nobody listened to the files yet.
- Tables, links, the draft `credits.txt`, and the Godot notes: [research/sounds.md](../research/sounds.md).
