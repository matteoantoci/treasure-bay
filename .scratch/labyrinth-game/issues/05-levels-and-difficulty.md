# Levels and difficulty

Type: grilling
Status: resolved
Blocked by: 03, 04
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

- Are the Labyrinths hand-made or generated?
- What is the size of the first Labyrinth?
- How does the size or the difficulty increase?
- Does the Child choose a Labyrinth, or does the game give the next one?

## Context

From [Choose the tech stack](01-choose-tech-stack.md) (Godot 4.7) and [Source the graphics](07-source-the-graphics.md):

- The generator gives long paths, about 19% of the cells, so the Labyrinths must stay small. To add loops, remove some walls. This makes a Labyrinth easier.
- Keep each Labyrinth as plain data. Hand-made Labyrinths use the same format and the same reachability check. A headless GDScript runner tests them.
- The code draws the walls, so any size needs no new art. Keep a cell at or below about 128 px, so the 256 px emoji stay sharp.

From [Encouragement without losing](04-encouragement-without-losing.md): decide the number of Items for each Labyrinth, and where they go. Put some Items in dead ends. The boat stops on each Item square. A row of outlines shows the Items, so the number must fit in one row at the top of the screen.

## Answer

- **Fixed Labyrinths:** the game generates each Labyrinth from a fixed seed. Labyrinth 1 is always the same Labyrinth, then Labyrinth 2, and so on. After the last fixed Labyrinth, the game continues with random Labyrinths at the largest size.
- **Size:** the first Labyrinth is 4 × 3 squares. The size increases by one column or one row after every 2 Labyrinths, to a maximum of 10 × 7.
- **Groups:** 20 fixed Labyrinths in 4 Areas, with 5 Labyrinths in each Area, for example a lagoon or a coral reef. 20 Labyrinths need 20 different Sea friends.
- **Next Labyrinth:** after the Sea friend arrives, the game starts the next Labyrinth by itself. The Child does not choose.
- **Items:** 1 Item for each 6 squares, with a minimum of 2 and a maximum of 8. At least one Item is in a dead end.

The Parent accepted all five recommendations.

Sea friends (checked on 2026-11-03: each Fluent Emoji 3D PNG link returns HTTP 200): Crab, Octopus, Spouting whale, Whale, Dolphin, Fish, Blowfish, Shark, Squid, Lobster, Shrimp, Oyster, Seal, Turtle, Jellyfish, Otter, Penguin, Duck, Swan, Flamingo. Spares: Snail, Frog. Tropical fish is not on this list, because it is an Item.
