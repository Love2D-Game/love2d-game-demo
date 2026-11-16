# love2d-game-demo

## Interactable objects in Tiled

Create an **Object Layer** named `Interactions`. Place an unrotated rectangle
over an entrance, chest, or sign (point objects also work). Add custom properties:

| Property | Tiled type | Purpose |
| --- | --- | --- |
| `prompt` | string | Text shown nearby, e.g. `E: Enter cave` |
| `range` | int | Interaction distance from the rectangle, default 80 pixels |
| `message` | string | Text displayed for four seconds when E is pressed |
| `destination` | string | Optional map name without extension, e.g. `cave` |
| `spawnX` / `spawnY` | int | Player position in destination pixels; default 64 for 32px tiles |

Save your editable `.tmx` source and export maps as Lua into `maps/`, with image
paths relative to that folder. For `destination = cave`, export `maps/cave.lua`.
The game loads the destination's own `Interactions` layer, so add an exit with
`destination = village_map` and suitable spawn coordinates to return.
NPCs take priority over map objects when both are nearby. Map objects do not
add collision or artwork; paint their appearance in tile layers.

The village export includes an entrance rectangle at (900, 1100), connected to
the imported cave. Walk near it and press E, then use the cave's bottom exit
to return to the village.
Recreate this object in your Tiled source before exporting over the village map.

## Imported cultivation cave

The cave's editable source is `maps/cave/cave.tmx`, with embedded tilesets.
Its runtime export is `maps/cave.lua`; export there when updating the map.
Both use `maps/cave/scene_tiles.png` and `maps/cave/editor_helpers.png`.
The TMX includes the runtime collision layer name and village return properties.

The cave's original `interactionRadius` and `dialogue` properties are supported,
including its four named objects and return passage. These display descriptive
messages; they do not yet add inventory, item consumption, or cultivation stats.
The hidden `Collision` layer blocks the player's feet.
Keep this name when editing the cave. The artwork is an illustrated scene
split into unique tiles, rather than a reusable terrain tileset.

The supplied spawn marks the player's feet. The village entrance uses top-left
sprite coordinates `(689.11, 1290.47)` to put the feet at that spawn. The return
exit places the player at `(920, 1160)` in the village.


