# Sound

Type: grilling
Status: resolved
Blocked by: 02
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

Which sounds does the game play? The game has no recorded voice.

- Music or no music?
- Which sound effects: a step, a wall bump, a collected item, the Goal?
- Does the Parent need a key to mute the sound?

## Context

From [Choose the tech stack](01-choose-tech-stack.md) (Godot 4.7): music can start when the game starts. Godot has sound buses for music and effects. All sound files must be in the project. A headless test run has no sound, so tests check only the sound calls.

From [Encouragement without losing](04-encouragement-without-losing.md): the game needs these sounds: a pop for each Item, a celebration of about 3 seconds at the Goal, and a sound when a new Sea friend arrives.

## Answer

- **Music:** each Area has its own calm music loop at low volume. The music changes when the Area changes.
- **Effects:** a soft water swish for each move, a soft "boing" at a wall (not a buzzer), a pop for each Item, a happy fanfare of about 3 seconds at the Goal, and a splash when a Sea friend arrives.
- **Animal sounds:** each Sea friend gets its own sound if a good real or cartoon sound exists for it. A Sea friend with no good sound uses the shared splash.
- **Volume:** the music and the effects have separate volumes. The volume and mute controls are buttons on the screen. The Child and the Parent can click them with the mouse. The Parent changed the fixed rule: the mouse is allowed for settings, and the keyboard stays the only input for play.
- **Source:** the agent finds the files. See [Source the sounds](10-source-the-sounds.md).

The Parent gave these answers in a talk.
