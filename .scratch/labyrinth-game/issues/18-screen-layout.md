# Screen layout

Type: decision
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

What size is the Labyrinth on the laptop screen, and where are the Item row and the gear?

Recommendation: the Labyrinth plus a margin fills the screen height, and the Labyrinth stays in the middle. The square size comes from the Labyrinth size, so a 4 × 3 Labyrinth has big squares and a 10 × 7 Labyrinth has small squares. The Item row is at the top in the middle. The gear is small and in the top-right corner. The base resolution is 1920 × 1200, because Mac laptop screens are 16:10, for example 1512 × 982. The stretch mode is `canvas_items`, from [Clean sprite edges](14-clean-sprite-edges.md), and the stretch aspect is `expand`. Thus no screen gets black bars, and the Labyrinth stays in the middle of the space.

## Decision

The Parent accepted the recommendation on 2026-11-03.

The agent changed the base resolution from 1920 × 1080 to 1920 × 1200 after the Parent's answer, and added the stretch aspect `expand`. The Parent did not see the resolution in the question. It is a technical detail and changes nothing that the Parent sees.
