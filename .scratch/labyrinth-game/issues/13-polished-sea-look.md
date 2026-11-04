# Polished sea look

Type: prototype
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

Which art and which water effects make the game look like a real, polished game?

The Parent reopened [Source the graphics](07-source-the-graphics.md) on 2026-11-03 for these reasons:

- The emoji images do not look like a real game.
- The Labyrinth looks like a diagram. The walls are plain lines on a flat floor.
- The Parent wants to see the water and the effect of the boat in the water. The result must be polished, not a prototype.

## Criteria

- One style covers everything: the boat, the water, the walls, the Goal, the Items, and all 20 Sea friends from [Levels and difficulty](05-levels-and-difficulty.md). No emoji remain.
- A Sea friend is never an Item or a decoration.
- The licence permits use in a private family game.

Kenney Pirate Pack has no sea animals. The Kenney Animal Pack Redux has some sea animals, for example a narwhal, a penguin, a walrus, and a whale, but most of the 20 Sea friends are absent [INFERENCE: from the file list on construct.net, not a full check]. Kenney alone therefore fails the first criterion.

## Options for the art

- **Kenney Pirate Pack + AI-generated animals** (pack CC0, free). The pack has top-down water, sand coasts, and grass islands. The islands become the walls, and the water becomes the paths. Use a ship with a white sail and no skull flag. The pack has no sea animals, so an AI model makes the 20 Sea friends and the Items in the flat Kenney style, with a Kenney image as the style reference. The Parent's xAI subscription runs the model (`xai-oauth/grok-imagine-image`). No OpenAI key is necessary.
- **AI-generated set** in one picture-book style: the boat, the island tiles, the Items, and all 20 Sea friends. This option needs an OpenAI API key. The cost is probably less than $10 [INFERENCE]. Each image can drift in style, so each image needs a check and a cleanup.
- **Paid pack** with cute top-down sea art. Not researched yet.

Details and links for the first two options: [graphics research](../research/graphics.md), sections B and D.

## Choice so far

The Parent chose option 1 on 2026-11-03: the Kenney world plus AI-generated animals and Items. The Parent asked to use the xAI subscription, not an OpenAI key.

Test on 2026-11-03 with `grok-imagine-image` through a headless omp session. The prompt and the results are in [the art prototype folder](../prototypes/art-PROTOTYPE/gen/):

```sh
# omp-imagegen.yml (in the art prototype folder) enables the tool: generate_image.enabled: true, modelRoles.image: xai-oauth/grok-imagine-image
omp -p --model xai-oauth/grok-4.7 --thinking high --config omp-imagegen.yml \
  --no-session --auto-approve --max-cost 3 @gen/PROMPT.md "Follow the instructions in the attached file."
```

- **Dolphin: good.** It has flat colours, a thick dark outline, and a friendly face, and it matches the Kenney style.
- **Boat: failed.** The model drew a side view, not a top-down view. Use a Kenney ship with the flag removed for the boat.
- **Background: not clean.** The model drew pink (#FF55AF), not magenta (#FF00FF), and saved a JPEG. The dolphin belly is also pink. For the next batch, use a white background and remove it with a flood fill from the corners. The closed dark outline stops the fill.
- **Size: too small.** The object fills about 30% of the image. Ask for an object that fills 80% of the image.
- Each run took about 1 minute for 2 images.

## Water and boat effects

These effects apply to all art options. Godot makes them with a `canvas_item` shader and particles, so they need no art:

- The water moves, and light patterns move on it.
- White foam moves along each island coast.
- The boat leaves a V-shaped wake and small ripples.
- The boat rocks a little when it does not move.

## Answer

The agent stopped a Godot sample and an HTML sample after the Parent said that they took too long. No visual sample exists. The vision below is the decision. The build checks it on the real game. The visual references are [the Kenney sample](../prototypes/art-PROTOTYPE/ref/kenney-pirate-sample.png) and [the sprite sheet](../prototypes/art-PROTOTYPE/sprites/contact-light.png).

- **World:** Kenney Pirate Pack look, top-down. The walls are islands: a sand coast, a grass top, and some palms, rocks, and bushes. The paths are water channels. The Labyrinth must look like islands in a sea, not like lines. See `prototypes/art-PROTOTYPE/ref/kenney-pirate-sample.png`.
- **Boat:** the Kenney boat with a white sail, top-down, at `prototypes/style-target/assets/kenney/ships/boat_white_sail.png`. It turns to face each move.
- **Water and boat effects:** the four effects in the section above. They are required, because the Parent asked for them by name.
- **Animals and Items:** the 23 sprites in `prototypes/art-PROTOTYPE/sprites/` (20 Sea friends, plus spiral shell, starfish, and pearl for Area 1). See `sprites/contact-light.png`. The method, the prompts, and the cleanup script are in `art-PROTOTYPE/` (`tools/`, `gen/`, `sprites/PROVENANCE.md`).
- **More art:** generate new Kenney-style variants with the same Grok method, for example Items for Areas 2 to 4. The full set of 23 sprites used about 2% of the weekly xAI quota.
- **Known weak sprites:** the crab faces the front; the shrimp antennae are thin; the navy whale has low contrast on dark water; the swan and the pearl are near-white.

Godot 4.7.2 is installed (`/opt/homebrew/bin/godot`). The folder `prototypes/style-target/` is an abandoned Godot project and is not a visual target. Keep only its `assets/kenney/` files (the tiles and `boat_white_sail.png`).

## Effect on other tickets

- [Visual change between Labyrinths](08-visual-change-between-labyrinths.md): the 4 Areas stay. The colours, the Items, and the decorations of each Area must change to match the new art.
- [Motion and animation](11-motion-and-animation.md): do it after this ticket, because the motion depends on the art.
