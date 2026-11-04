Generate 1 image with the generate_image tool. Make exactly one tool call per image. Do not change the wording below.

Call settings for every image:
- model: "xai-oauth/grok-imagine-image"
- input: [{ "path": "ref/kenney-pirate-sample.png" }]
- aspect_ratio: "1:1"
- style: "Image 1 is a style reference only (Kenney Pirate Pack, CC0). Copy its flat vector game-art style exactly: flat solid colours, simple rounded chunky shapes, one thick dark brown outline around the whole object and around its parts, soft cheerful colours, no gradients, no texture, no shading noise. Do not copy any object, ship, island or water from Image 1."
- composition: "One single object only, centred, seen from the side or in three-quarter view. The object fills about 80% of the image width or height and is not cropped by the image edges. Background: plain flat pure white (#FFFFFF), the same white everywhere, nothing else in the background. No shadow under or behind the object, no water, no ground, no frame, no text, no letters, no numbers, no logo, no watermark."

Image 1 (name: crab)
- subject: "A cute friendly red crab with a big happy smile, two big round eyes on short stalks, two raised claws as if waving hello, small legs. A sticker-like children's game character for a 5-year-old."

After each call, copy the saved image file into the directory "gen/raw/" as "<name>.<ext>" (keep the original extension, create the directory if needed).
Then print the final paths. Do nothing else.
