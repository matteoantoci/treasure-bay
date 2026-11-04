# Visual change between Labyrinths

Type: prototype
Status: resolved
Blocked by: 05
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

What changes in the graphics from one Labyrinth to the next, so that the Child sees progress, as in real games?

Options to compare:

- Sea areas that change after some Labyrinths, for example a lagoon, a coral reef, the open sea, and the sea at night. Each area has its own colours and items.
- A new boat or a new decoration after some Labyrinths.
- The time of day changes from morning to sunset to night.
- Small changes for each Labyrinth: the colour of the walls and the floor.

Make a rough prototype that shows three or four steps of the change. The Parent chooses one option.

## Context

From [Pick the theme: sea or space](02-pick-the-theme.md): the theme is sea. The "Sea (light)" and "Sea (sand paths)" variants are possible looks for two areas. From [Source the graphics](07-source-the-graphics.md): Fluent Emoji 3D has many sea images, for example a dolphin, a whale, an octopus, a crab, coral, and a ship. The code draws the walls and the floor, so a colour change costs no new art.

From [Levels and difficulty](05-levels-and-difficulty.md): the game has 4 Areas, with 5 Labyrinths in each Area. The start of a new Area is the main point where the look changes.

From [Source the sounds](10-source-the-sounds.md): the 4 music tracks use placeholder Areas (lagoon, coral reef, open sea, sea at night). If this ticket names other Areas, change the music choice in [research/sounds.md](../research/sounds.md).

## Answer

Option A: Sea Areas. The Parent chose it after a look at [the prototype](../prototypes/areas-PROTOTYPE/index.html).

The look changes at the start of each Area, that is, every 5 Labyrinths. The boat (sailboat) and the Goal (desert island) stay the same in all Areas.

| Area | Labyrinths | Background | Floor | Walls | Items | Decoration |
|---|---|---|---|---|---|---|
| 1 Lagoon | 1-5 | `#bfe9ff` to `#7cc8f0` | `#d9f3ff` | `#2f8fd0` | Spiral shell, Tropical fish | Water wave |
| 2 Coral reef | 6-10 | `#ffe9c4` to `#ffc9a8` | `#fff4dc` | `#e0708a` | Coral, Tropical fish | Bubbles |
| 3 Open sea | 11-15 | `#5fa8e0` to `#1f5f9e` | `#cfe6f7` | `#16497a` | Gem stone, Spiral shell | Droplet |
| 4 Sea at night | 16-20 | `#2c3f7a` to `#0d1533` | `#2a3a66` | `#9fd4ff` | Glowing star, Star | Crescent moon, small stars |

- Areas 1 to 3 use a vertical gradient for the background. Area 4 uses a radial gradient, as in the prototype. All colours, Items, and decorations in this table are provisional: [Polished sea look](13-polished-sea-look.md) changes them to match the new art.
- No Sea friend from [Levels and difficulty](05-levels-and-difficulty.md) appears as an Item or a decoration. A Sea friend appears only as the reward, so each Sea friend stays new for the Child. Each image link returned HTTP 200 on 2026-11-03.
- The Area names match the music placeholders in [research/sounds.md](../research/sounds.md), so the music choice does not change.
- Random Labyrinths after Labyrinth 20 are not decided here. The open question "Reward after Labyrinth 20" in the map can also decide their Area look.
- The transition into a new Area is part of [Motion and animation](11-motion-and-animation.md).
