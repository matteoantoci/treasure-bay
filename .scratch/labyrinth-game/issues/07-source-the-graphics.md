# Source the graphics

Type: research
Status: superseded by [13 Polished sea look](13-polished-sea-look.md) on 2026-11-03
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

Where do nice-looking graphics come from, for both candidate themes (sea and space)?

The game needs a character, a Goal, walls and floor, collectible items, a background, and a reward animation. All graphics must have one consistent style that appeals to a 5-year-old girl.

Options to compare:

- Free asset packs with a permissive licence, for example CC0.
- Images from an AI image generator, then cleaned up.
- Vector graphics that an agent draws in code.
- Paid asset packs.

Criteria: the look, one consistent style, the licence, the cost, the work to add more items later, and the fit with the game engine.

Primary sources: the `create-game-assets` skill in `.claude/skills/` of this repo, then the web.

## Answer

Use Microsoft Fluent Emoji in the 3D style (MIT, free, 256 px PNG) for the character, the Goal, the items, and the reward. The game code draws the walls, the floor, and the background in a palette that matches the emoji.
One family covers both themes: a sailboat, an island, and shells for the sea; a rocket, a ringed planet, and stars for space. PNG fits Godot 4.7, Phaser 4, and SVG in the DOM.
Alternatives: Kenney Pirate Pack (CC0) for a top-down sea, the Kawaii Space pack ($20) for space, agent-drawn kawaii SVG, or AI images (low consistency).
Ticket 02 gets three style candidates for each theme. Details, links, and licences: [graphics research](../research/graphics.md).
