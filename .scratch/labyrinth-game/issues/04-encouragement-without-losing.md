# Encouragement without losing

Type: grilling
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

Which reward gives the Child a reason to continue, and obeys the rule that the Child cannot lose?

Options to discuss:

- Items to collect on the path, for example stars or shells.
- A count of the collected items.
- A collection screen with stickers.
- A celebration at the Goal.
- A score that only increases.

How does the Child see the reward with no text?

## Context

From [Source the graphics](07-source-the-graphics.md) and [Choose the tech stack](01-choose-tech-stack.md): Fluent Emoji has many reward images, for example a trophy, medals, a party popper, confetti, a rainbow, sparkles, and gems. A Godot `CPUParticles2D` one-shot burst can show a celebration. Set `emitting` to off until the reward, because it is on by default.

Open question from [Arrow-key movement](03-arrow-key-movement.md) (see its Answer): one press moves the boat to the next junction. Does the boat stop on each item square, or does it collect the item as it moves past? In the prototype, it moves past.

## Answer

- **Items:** each Labyrinth has Items on the path, for example shells and fish. Some Items are in dead ends, so a dead end gives a small reward. The Child does not need all Items to finish. The number of Items depends on the Labyrinth structure: [Levels and difficulty](05-levels-and-difficulty.md) decides it, and it can be more than 3.
- **Stop on an Item:** in mode B, the boat also stops on each Item square. The Item makes a pop sound and a sparkle. Then the Child presses a key again.
- **Score in the Labyrinth:** a row of empty outlines at the top of the screen, one for each Item. Each collected Item fills one outline. The row never becomes smaller. The Child knows numbers well, so the Collection screen also shows the total count of Items as a number.
- **Reward at the Goal:** a party celebration of about 3 seconds with confetti and sparkles. Then a new Sea friend, for example a dolphin, a crab, or an octopus, swims onto the island. The game adds it to the Collection.
- **Collection:** a screen with pictures only, that shows all the Sea friends that the Child found. The question "the Collection stays after the game closes" stays in the map fog item "Saved progress".

The Parent accepted these answers in a talk. For the score, the Parent let the agent choose.
