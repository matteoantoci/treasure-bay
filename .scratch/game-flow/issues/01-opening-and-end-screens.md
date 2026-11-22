# 01: Opening screen and end screen

Type: prototype
Status: resolved
Blocked by: none

## Question

What do the opening screen and the end screen look like? What happens after the end screen?

## Decisions so far (Parent, 2026-11-22)

- **Chest:** the chest has a padlock until the Child collects all Items of the Labyrinth. When she arrives on the Goal square too early, the chest shakes, a "locked" sound plays, and the empty outlines in the Item row blink. After the last Item, the padlock pops off and the chest starts to sparkle. This replaces the ticket 04 rule "Items are optional" of the labyrinth-game map.
- **Game length:** the game has 20 Labyrinths and then ends. The random Labyrinths after Labyrinth 20 (build spec section 4.4) and the Sea friends that come back (section 6.4) go away. So the Child never gets a duplicate Sea friend.
- **Areas:** the 20 Labyrinths already use all 4 Areas, 5 Labyrinths each (`src/area.gd`). No change.
- **Labyrinths:** the 20 Labyrinths are random, sorted by difficulty. The game makes a new set of 20 when the game ends and when the Parent resets. Each slot uses the seed-search conditions of the play-improvements spec Part 3, but from a random start seed and not from seed 1. The save keeps the 20 seeds. Checks for the build: each small size, for example 4 × 3, must have enough different seeds, or the first Labyrinths repeat. The fixed table found each slot within the first 167 seeds, but that is not a worst case. Measure the tries for each slot from many random start seeds, mainly slots 15 to 20. The search must not make the opening screen wait.
- **End screen:** variant B of the first prototype round, "Friends on board". All 20 Sea friends make a ring around the open chest and do a wave. Confetti falls.
- **Opening screen:** variant B of the second prototype round, "Chest logo". The chest on its island is the logo, with the game name in an arc over it, and one wide green start button. Any arrow key, Space, or Enter presses the button.
- **Session limit:** no limit in the game. Ticket 17 of the labyrinth-game map stays.

## Prototype

[prototypes/screens-PROTOTYPE/index.html](../prototypes/screens-PROTOTYPE/index.html). Open the file in a browser. The arrow keys or the bottom bar change the opening variant. The "Name" button changes the game name. Space presses the button (opening) or replays the end. `?title=` adds one more name.

Round 1 (2026-11-22): three opening and end pairs (Sea map, Friends on board, Big number calm night). The Parent chose the "Friends on board" end and rejected all three openings.

Round 2 (2026-11-22), openings with a logo and a big button:

- A, Title on the sea: a large title, a round yellow button, and the boat that sails around the button.
- B, Chest logo: the chest on its island, the title in an arc, and a wide green button.
- C, Friends parade: the title on a wooden sign, a round coral button, and a parade of Sea friends.

## Answer

- **Name:** Treasure Bay. The logo is the chest on its island, with "Treasure Bay" in an arc over it. The spec builds the logo from the Kenney island, the chest sprite, and the title in a rounded font, so the art stays in one style.
- **After the end screen:** the Collection becomes empty for the new set of 20 Labyrinths. The total Item count stays.
