Generate 2 test images with the generate_image tool. Use model "xai-oauth/grok-imagine-image".
Pass the style reference as input: path "ref/kenney-pirate-sample.png". It is a CC0 Kenney Pirate Pack sample.

Style for both images: copy the flat vector style of the reference exactly. Flat colours, simple rounded shapes,
a thick dark outline, soft pastel colours, no gradients, no texture, no text, no shadows outside the object.
The object is cute and friendly for a 5-year-old child. One single object, centred, not cropped.
Background: one flat solid magenta colour (#FF00FF) that fills the whole image, so a script can remove it.

Image 1: a friendly smiling dolphin, seen from the side, swimming. aspect_ratio 1:1.
Image 2: a small wooden sailing boat with one white sail and no flag, no cannons, seen from directly above (top-down), bow pointing right, same view as the ships in the reference. aspect_ratio 1:1.

After each call, copy the saved image file into the directory "gen/" with the names "dolphin.<ext>" and "boat.<ext>".
Then print the two final paths. Do nothing else.
