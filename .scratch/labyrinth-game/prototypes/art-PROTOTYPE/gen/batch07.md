Generate 3 image(s) with the generate_image tool. Make exactly one tool call per image, one after the other. Use the exact wording below; do not shorten it.

Call settings for every image:
- model: "xai-oauth/grok-imagine-image"
- input: [{ "path": "ref/kenney-pirate-sample.png" }, { "path": "gen/dolphin.jpg" }]
- aspect_ratio: "1:1"
- style: "Image 1 (Kenney Pirate Pack, CC0) and Image 2 (a dolphin character) are style references only. Copy their flat vector game-art style exactly: flat solid colours, simple rounded chunky shapes, one thick dark brown outline around the whole object and around its parts, soft cheerful colours, no gradients, no texture, no shading noise. Do not copy any object, ship, island, water or the dolphin, and do NOT copy the pink background of Image 2: the new background is pure white."
- composition: "One single object only, centred, seen from the side or in three-quarter view (unless the subject says otherwise). The object is big: it fills about 80% of the image width or height, with a small white margin, and it is not cropped by the image edges. Background: plain flat pure white (#FFFFFF), the same white everywhere, nothing else in the background. No shadow under or behind the object, no water, no ground, no bubbles, no sparkles, no frame, no text, no letters, no numbers, no logo, no watermark."

Image 1 (name: spiral_shell)
- subject: "A spiral sea snail shell (a small conch) seen from the side, cream and peach colours with a soft pink opening. A collectable treasure object for a children's game. It is an object, not a character: no face, no eyes, no mouth."

Image 2 (name: starfish)
- subject: "A five-armed orange starfish seen from above, plump rounded arms, small lighter dots on its arms. A collectable treasure object for a children's game. It is an object, not a character: no face, no eyes, no mouth."

Image 3 (name: pearl)
- subject: "One big round shiny pearl, creamy white with a soft lavender-pink tint, one bright white highlight. Only the pearl, nothing else. A collectable treasure object for a children's game. It is an object, not a character: no face, no eyes, no mouth."

After each call, copy the saved image file into the directory "gen/raw/" as "<name>.<ext>" (keep the original extension, create the directory if needed, overwrite an existing file).
Then print the final paths. Do nothing else.
