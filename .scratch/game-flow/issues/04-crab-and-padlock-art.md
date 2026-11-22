# 04: New crab and padlock art

**What to build:** A new crab sprite that stands straight and is wider than tall, and a new padlock sprite for the locked chest. Both come from the xAI image pipeline of the labyrinth-game art prototype, in the same style as the other Sea friends. Spec: [spec.md](../spec.md), Part 6 ("Crab", "Padlock", "Check") and user stories 59 and 60.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**Human step:** the Parent approves both sprites on the contact sheet before they go into `assets/`.

- [ ] The pipeline is `.scratch/labyrinth-game/prototypes/art-PROTOTYPE/` (`tools/make_batch.py`, `tools/run_batch.sh`, `tools/cutout.py`, `tools/contact_sheets.py`, `sprites/PROVENANCE.md`). The prompts use its style block and its references.
- [ ] Crab prompt: front view, symmetric, both claws at the same height, wider than tall.
- [ ] Padlock prompt: a small golden padlock, front view. It is an object: no face.
- [ ] Both sprites are normalized like the other sprites: trim, pad, 512 px on the long side, alpha.
- [ ] A contact sheet shows both new sprites next to the existing set, for the odd-one-out check (pile-pals rule 15).
- [ ] The Parent approves both sprites. If the Parent rejects one, generate it again with a changed prompt.
- [ ] After the approval: the new crab replaces `assets/sprites/friends/crab.png`, and the padlock goes to `assets/sprites/goal/padlock.png`. The asset tests pass. The app icon of `tools/make_app.sh` uses the new crab.
- [ ] `PROVENANCE.md` gets the new rows (prompt file, references, attempts, notes).
