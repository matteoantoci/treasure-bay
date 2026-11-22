# 02: UI polish

Type: prototype
Status: resolved
Blocked by: none

## Question

Which UI polish fixes go into the game-flow spec, and what do they look like?

## Sources

- `~/Personal/beat-pals/research/game-ui.md`: rules C7 (contrast 3:1), C14 and C15 (only information moves), C18 (short end reward), C25 (one focal point).
- `~/Personal/pile-pals/research/native-feel/`: motion.md (flip in two halves, reduced motion), ai-sprites.md (one style, odd-one-out check on a contact sheet), README (idle hint).
- Current screenshots: `shots/area1.png`, `shots/area4.png`, `shots/settings.png`, and `shots/motion-sea-friend.png` (taken again on 2026-11-22).

## Decisions so far (Parent, 2026-11-22)

The Parent wants all ten fixes, after a mockup:

1. Item column at the left of the maze. The boat stays 85 % of a tile long and an Item stays 69 % of a tile, as in the play-improvements spec. Ticket 08 of that spec checked that an 85 % boat stays inside the channel when it turns. The tile has a cap of 121 px at a height of 1200 px, which is the Area 1 tile of the game now. So small Labyrinths keep their size, and large Labyrinths grow: in Area 4 the tile goes from about 65 px to about 80 px.
2. Still water background. A soft foam edge replaces the moving dashed line.
3. Item slots: a light disc with an outline, at a contrast of 3:1 or more.
4. A larger chest on a round Goal island, with the palm inside the coast and the padlock of ticket 01.
5. Sea friend reveal at the centre, large, with the maze dimmed. It flips in, then flies to its slot.
6. Collection strip with 20 empty slots, and the count in the rounded font with a shell icon.
7. A small, quiet gear. The settings panel in the cream-and-wood style, with the screen dimmed.
8. One style: one rounded font, one outline width, light from the top left, a static shadow under the boat and the Items.
9. Soft foam wake in place of the outlined ovals.
10. Idle hint: after about 6 s with no key press, the chest or the nearest Item hops one time.

The crab sprite leans to one side, and its claws are at different heights. Generate it again with xAI, front view and symmetric, and check it on the contact sheet.

## Prototype

[prototypes/polish-MOCKUP/index.html](../prototypes/polish-MOCKUP/index.html). Open the file in a browser. The bar changes the screen. "Now" and "New" (or the N key) switch between the current game and the mockup. The islands in the mockup are simple shapes. The game keeps the Kenney tiles with all their details: the textured coast, the grass dots, the rocks, and the bushes. The polish removes only the moving dashed foam and the drifting cloud shapes.

Real game shots, taken in a throwaway checkout: [real-layout-area1.png](../prototypes/polish-MOCKUP/real-layout-area1.png) and [real-layout-area4.png](../prototypes/polish-MOCKUP/real-layout-area4.png). They show fix 1 (Item column and tile cap), fix 2 (no cloud shapes, no dashed foam; the soft foam edge is not drawn yet), fix 3 (Item slots), the 20 empty slots of fix 6, and the quiet gear of fix 7. They do not show fixes 4, 5, 8, 9, and 10.

Parent feedback on the shots: the circles have no margin. The spec must give each circle group a clear gap: in the Collection strip, a gap of at least 12 px between slots and at least 24 px from the screen edges; in the Item column, at least 16 px between slots. With 8 Items, 8 discs of 120 px and 7 gaps of 16 px need 1072 px, and the free height at 1200 px is 1051 px. So the disc diameter is min(120 px, (free height − (count − 1) × 16 px) / count), about 117 px for 8 Items. The build must check the gaps on the screenshots.

## Open

- The Parent reviewed the mockup on 2026-11-22 and likes the new UI.
- The party end stays the loop that the Parent chose. The 5 s version with a still Collection (beat-pals C18) goes in only if the Parent asks for it.
