# 04: New crab and padlock art

**What to build:** A new crab sprite that stands straight and is wider than tall, and a new padlock sprite for the locked chest. Both come from the xAI image pipeline of the labyrinth-game art prototype, in the same style as the other Sea friends. Spec: [spec.md](../spec.md), Part 6 ("Crab", "Padlock", "Check") and user stories 59 and 60.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**Human step:** the Parent approves both sprites on the contact sheet before they go into `assets/`.

- [x] The pipeline is `.scratch/labyrinth-game/prototypes/art-PROTOTYPE/` (`tools/make_batch.py`, `tools/run_batch.sh`, `tools/cutout.py`, `tools/contact_sheets.py`, `sprites/PROVENANCE.md`). The prompts use its style block and its references.
- [x] Crab prompt: front view, symmetric, both claws at the same height, wider than tall.
- [x] Padlock prompt: a small golden padlock, front view. It is an object: no face.
- [x] Both sprites are normalized like the other sprites: trim, pad, 512 px on the long side, alpha.
- [x] A contact sheet shows both new sprites next to the existing set, for the odd-one-out check (pile-pals rule 15).
- [x] The Parent approves both sprites. If the Parent rejects one, generate it again with a changed prompt.
- [x] After the approval: the new crab replaces `assets/sprites/friends/crab.png`, and the padlock goes to `assets/sprites/goal/padlock.png`. The asset tests pass. The app icon of `tools/make_app.sh` uses the new crab.
- [x] `PROVENANCE.md` gets the new rows (prompt file, references, attempts, notes).

Build note (gf/04-crab-and-padlock-art): Batch 12 generated the new crab (`crab_front`, 1 attempt) and padlock attempt 1. Batch 13 generated padlock attempt 2. Padlock attempt 1 was open and had a grey shackle, so the prompt of attempt 2 asks for a locked, symmetric, all-gold padlock. The raw image of attempt 1 stays as `gen/raw/padlock-attempt1.png`. The old crab raw image and sprite stay in the prototype. The generator now saves PNG, not JPEG. The padlock cutout uses `--seed 512,390` to clear the white hole inside the shackle. On the light and dark contact sheets, neither sprite is the odd one out. The Parent approved both sprites on 2026-11-22. The new crab replaces `assets/sprites/friends/crab.png` (512 × 378 px, wider than tall). The padlock is `assets/sprites/goal/padlock.png` (421 × 512 px). Its `.import` file has `mipmaps/generate=true`, as the other sprites. The asset tests now cover the padlock: 63 PNG files. `tools/make_app.sh` reads `crab.png`, so the app icon uses the new crab with no script change. A person must check: the new app icon after `tools/make_app.sh`, and the crab at Sea friend size in the game. The padlock behaviour on the chest is ticket 06.
