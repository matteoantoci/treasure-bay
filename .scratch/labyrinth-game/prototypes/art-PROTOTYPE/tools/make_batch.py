#!/usr/bin/env python3
"""Write a gen/<batch>.md prompt file for the headless omp + grok-imagine-image run.

Usage: make_batch.py BATCH_NAME NAME [NAME ...] [--no-dolphin]
Subjects live in SUBJECTS below so every batch uses identical style wording.
"""

from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

FRIEND_TAIL = " A sticker-like children's game character for a 5-year-old, cute and friendly, big round eyes, happy smile."
ITEM_TAIL = " A collectable treasure object for a children's game. It is an object, not a character: no face, no eyes, no mouth."

SUBJECTS: dict[str, tuple[str, str]] = {
    # friends
    "crab": ("friend", "A cute friendly red crab with a big happy smile, two big round eyes on short stalks, two raised claws as if waving hello, small legs."),
    "octopus": ("friend", "A cute friendly purple octopus in three-quarter view, round head, eight short curly tentacles."),
    "spouting_whale": ("friend", "A cute friendly light blue whale seen from the side, round chubby body, white belly, tail fin raised, with a small fountain of water spouting up from the top of its head."),
    "whale": ("friend", "A cute friendly dark navy-blue humpback whale seen from the side, long round body with a pale striped throat, long side flipper, tail fin raised. No water spout."),
    "dolphin": ("friend", "A cute friendly grey-blue dolphin seen from the side, jumping in a gentle arc, pale belly, curved dorsal fin."),
    "fish": ("friend", "A cute friendly orange clownfish with three white stripes edged in dark outline, seen from the side, round fins."),
    "blowfish": ("friend", "A cute friendly yellow blowfish (pufferfish) puffed up into a round ball with small soft rounded spikes, little fins, seen from the side."),
    "shark": ("friend", "A cute friendly blue-grey shark seen from the side, white belly, closed smiling mouth with no teeth showing, rounded fins, not scary at all."),
    "squid": ("friend", "A cute friendly mint-green squid standing upright, pointed head with two small triangle fins on top, ten short tentacles at the bottom."),
    "lobster": ("friend", "A cute friendly orange lobster in three-quarter view, two big claws, long thin antennae, segmented body, fan-shaped tail."),
    "shrimp": ("friend", "A cute friendly light pink shrimp seen from the side, curved segmented body, small legs, long thin antennae, fan tail."),
    "oyster": ("friend", "A cute friendly oyster: a rough grey-lavender oval shell, slightly open, with a pink inside, big eyes and a smile on the top shell. No pearl."),
    "seal": ("friend", "A cute friendly light grey seal with small dark spots, lying on its belly in three-quarter view, round head, whiskers, front flippers, tail flippers."),
    "turtle": ("friend", "A cute friendly green sea turtle swimming, seen from the side in three-quarter view, rounded patterned shell, four flippers."),
    "jellyfish": ("friend", "A cute friendly lavender-purple jellyfish, round dome bell with a scalloped edge, several short wavy tentacles hanging below."),
    "otter": ("friend", "A cute friendly brown sea otter floating on its back in three-quarter view, light cream face, paws together on its chest, small tail. No water."),
    # Attempt 1 ("A cute friendly yellow duck floating, seen from the side, orange beak, small wing. Not a toy,
    # a real little duck. No water.") came out as a rubber toy duck; attempt 2 asks for a mallard.
    "duck": ("friend", "A cute friendly mallard duck swimming, seen from the side: glossy green head, thin white neck ring, brown chest, light grey body, small dark tail, yellow-orange beak. A real duck, not a rubber toy. No water."),
    "penguin": ("friend", "A cute friendly penguin standing, three-quarter view, black back, white tummy, orange beak and orange feet, small flippers."),
    "swan": ("friend", "A cute friendly white swan floating, seen from the side, long curved S-shaped neck, orange beak with a black base, folded wings. No water."),
    "flamingo": ("friend", "A cute friendly pink flamingo standing on one long thin leg, seen from the side, curved neck, bent beak with a black tip."),
    # items
    "spiral_shell": ("item", "A spiral sea snail shell (a small conch) seen from the side, cream and peach colours with a soft pink opening."),
    "starfish": ("item", "A five-armed orange starfish seen from above, plump rounded arms, small lighter dots on its arms."),
    "pearl": ("item", "One big round shiny pearl, creamy white with a soft lavender-pink tint, one bright white highlight. Only the pearl, nothing else."),
    "coral": ("item", "A small branch of pink coral with rounded tips, seen from the side."),
    "sand_dollar": ("item", "A round flat sand dollar seen from above, pale cream with a five-petal flower pattern in the middle."),
    "gem_stone": ("item", "One blue gem stone with large flat facets and one bright white highlight. Only the gem, nothing else."),
    # Attempt 1 (the spec sentence alone) drew thin pale rays with no outline; the cutout dropped them as specks,
    # so the sprite looked like the plain star. Attempt 2 keeps the sentence and asks for outlined chunky rays.
    "glowing_star": ("item", "A yellow five-point star with soft rounded points and short light rays around it. The rays are a few short chunky rounded yellow strokes close to the star, each with the same thick dark brown outline, clearly visible."),
    "star": ("item", "A plain yellow five-point star with soft rounded points and no rays."),
    # goal chest: kind "item" (an object, no face)
    "chest_closed": ("item", "A small wooden treasure chest with gold metal bands and a gold lock, lid closed, seen in three-quarter view."),
    "chest_open": ("item", "The same small wooden treasure chest with gold metal bands, lid open, gold coins inside, seen in three-quarter view."),
}

HEADER = """Generate {n} image(s) with the generate_image tool. Make exactly one tool call per image, one after the other. Use the exact wording below; do not shorten it.

Call settings for every image:
- model: "xai-oauth/grok-imagine-image"
- input: {inputs}
- aspect_ratio: "1:1"
- style: "{style}"
- composition: "One single object only, centred, seen from the side or in three-quarter view (unless the subject says otherwise). The object is big: it fills about 80% of the image width or height, with a small white margin, and it is not cropped by the image edges. Background: plain flat pure white (#FFFFFF), the same white everywhere, nothing else in the background. No shadow under or behind the object, no water, no ground, no bubbles, no sparkles, no frame, no text, no letters, no numbers, no logo, no watermark."
"""

STYLE_ONE = ("Image 1 is a style reference only (Kenney Pirate Pack, CC0). Copy its flat vector game-art style exactly: "
             "flat solid colours, simple rounded chunky shapes, one thick dark brown outline around the whole object and around its parts, "
             "soft cheerful colours, no gradients, no texture, no shading noise. Do not copy any object, ship, island or water from Image 1.")
STYLE_TWO = ("Image 1 (Kenney Pirate Pack, CC0) and Image 2 (a dolphin character) are style references only. Copy their flat vector game-art style exactly: "
             "flat solid colours, simple rounded chunky shapes, one thick dark brown outline around the whole object and around its parts, "
             "soft cheerful colours, no gradients, no texture, no shading noise. Do not copy any object, ship, island, water or the dolphin, "
             "and do NOT copy the pink background of Image 2: the new background is pure white.")

FOOTER = """
After each call, copy the saved image file into the directory "gen/raw/" as "<name>.<ext>" (keep the original extension, create the directory if needed, overwrite an existing file).
Then print the final paths. Do nothing else.
"""


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("batch")
    ap.add_argument("names", nargs="+")
    ap.add_argument("--no-dolphin", action="store_true", help="use only the Kenney reference")
    args = ap.parse_args()

    if args.no_dolphin:
        inputs, style = '[{ "path": "ref/kenney-pirate-sample.png" }]', STYLE_ONE
    else:
        inputs, style = '[{ "path": "ref/kenney-pirate-sample.png" }, { "path": "gen/dolphin.jpg" }]', STYLE_TWO
    parts = [HEADER.format(n=len(args.names), inputs=inputs, style=style)]
    for i, name in enumerate(args.names, 1):
        kind, subject = SUBJECTS[name]
        tail = FRIEND_TAIL if kind == "friend" else ITEM_TAIL
        parts.append(f'\nImage {i} (name: {name})\n- subject: "{subject}{tail}"\n')
    parts.append(FOOTER)
    out = ROOT / "gen" / f"{args.batch}.md"
    out.write_text("".join(parts))
    print(out)


if __name__ == "__main__":
    main()
