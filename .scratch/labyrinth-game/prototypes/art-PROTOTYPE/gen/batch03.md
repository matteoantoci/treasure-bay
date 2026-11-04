Generate 4 image(s) with the generate_image tool. Make exactly one tool call per image, one after the other. Use the exact wording below; do not shorten it.

Call settings for every image:
- model: "xai-oauth/grok-imagine-image"
- input: [{ "path": "ref/kenney-pirate-sample.png" }, { "path": "gen/dolphin.jpg" }]
- aspect_ratio: "1:1"
- style: "Image 1 (Kenney Pirate Pack, CC0) and Image 2 (a dolphin character) are style references only. Copy their flat vector game-art style exactly: flat solid colours, simple rounded chunky shapes, one thick dark brown outline around the whole object and around its parts, soft cheerful colours, no gradients, no texture, no shading noise. Do not copy any object, ship, island, water or the dolphin, and do NOT copy the pink background of Image 2: the new background is pure white."
- composition: "One single object only, centred, seen from the side or in three-quarter view (unless the subject says otherwise). The object is big: it fills about 80% of the image width or height, with a small white margin, and it is not cropped by the image edges. Background: plain flat pure white (#FFFFFF), the same white everywhere, nothing else in the background. No shadow under or behind the object, no water, no ground, no bubbles, no sparkles, no frame, no text, no letters, no numbers, no logo, no watermark."

Image 1 (name: spouting_whale)
- subject: "A cute friendly light blue whale seen from the side, round chubby body, white belly, tail fin raised, with a small fountain of water spouting up from the top of its head. A sticker-like children's game character for a 5-year-old, cute and friendly, big round eyes, happy smile."

Image 2 (name: whale)
- subject: "A cute friendly dark navy-blue humpback whale seen from the side, long round body with a pale striped throat, long side flipper, tail fin raised. No water spout. A sticker-like children's game character for a 5-year-old, cute and friendly, big round eyes, happy smile."

Image 3 (name: shark)
- subject: "A cute friendly blue-grey shark seen from the side, white belly, closed smiling mouth with no teeth showing, rounded fins, not scary at all. A sticker-like children's game character for a 5-year-old, cute and friendly, big round eyes, happy smile."

Image 4 (name: squid)
- subject: "A cute friendly mint-green squid standing upright, pointed head with two small triangle fins on top, ten short tentacles at the bottom. A sticker-like children's game character for a 5-year-old, cute and friendly, big round eyes, happy smile."

After each call, copy the saved image file into the directory "gen/raw/" as "<name>.<ext>" (keep the original extension, create the directory if needed, overwrite an existing file).
Then print the final paths. Do nothing else.
