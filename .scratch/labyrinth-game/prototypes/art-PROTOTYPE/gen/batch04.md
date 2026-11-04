Generate 4 image(s) with the generate_image tool. Make exactly one tool call per image, one after the other. Use the exact wording below; do not shorten it.

Call settings for every image:
- model: "xai-oauth/grok-imagine-image"
- input: [{ "path": "ref/kenney-pirate-sample.png" }, { "path": "gen/dolphin.jpg" }]
- aspect_ratio: "1:1"
- style: "Image 1 (Kenney Pirate Pack, CC0) and Image 2 (a dolphin character) are style references only. Copy their flat vector game-art style exactly: flat solid colours, simple rounded chunky shapes, one thick dark brown outline around the whole object and around its parts, soft cheerful colours, no gradients, no texture, no shading noise. Do not copy any object, ship, island, water or the dolphin, and do NOT copy the pink background of Image 2: the new background is pure white."
- composition: "One single object only, centred, seen from the side or in three-quarter view (unless the subject says otherwise). The object is big: it fills about 80% of the image width or height, with a small white margin, and it is not cropped by the image edges. Background: plain flat pure white (#FFFFFF), the same white everywhere, nothing else in the background. No shadow under or behind the object, no water, no ground, no bubbles, no sparkles, no frame, no text, no letters, no numbers, no logo, no watermark."

Image 1 (name: lobster)
- subject: "A cute friendly orange lobster in three-quarter view, two big claws, long thin antennae, segmented body, fan-shaped tail. A sticker-like children's game character for a 5-year-old, cute and friendly, big round eyes, happy smile."

Image 2 (name: shrimp)
- subject: "A cute friendly light pink shrimp seen from the side, curved segmented body, small legs, long thin antennae, fan tail. A sticker-like children's game character for a 5-year-old, cute and friendly, big round eyes, happy smile."

Image 3 (name: oyster)
- subject: "A cute friendly oyster: a rough grey-lavender oval shell, slightly open, with a pink inside, big eyes and a smile on the top shell. No pearl. A sticker-like children's game character for a 5-year-old, cute and friendly, big round eyes, happy smile."

Image 4 (name: seal)
- subject: "A cute friendly light grey seal with small dark spots, lying on its belly in three-quarter view, round head, whiskers, front flippers, tail flippers. A sticker-like children's game character for a 5-year-old, cute and friendly, big round eyes, happy smile."

After each call, copy the saved image file into the directory "gen/raw/" as "<name>.<ext>" (keep the original extension, create the directory if needed, overwrite an existing file).
Then print the final paths. Do nothing else.
