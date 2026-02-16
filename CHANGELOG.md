# Changelog

## [Current] - Depth Sorting System

### Added

#### New Features
- **Depth Sorting System**: Automatic z-ordering for realistic depth perception
  - Characters can now walk behind and in front of objects
  - Supports transparent sprites/images
  - Three rendering layers: background, middle, foreground
  - Manual depth offset adjustment
  - Debug visualization with 'D' key

#### New Files
- `engine/sceneobject.lua` - Scene object system for depth-sorted props
- `DEPTH_SORTING.md` - Complete depth sorting documentation (50+ examples)
- `examples/depth_sorting_example.lua` - Interactive depth sorting demo
- `CHANGELOG.md` - This file

#### Updated Files
- `engine/scene.lua` - Added depth sorting rendering system
  - New `objects` array for scene objects
  - `addObject()` method
  - `drawWithDepthSorting()` method
  - Automatic entity sorting by Y baseline
- `scenes/room1.lua` - Updated with depth-sorted objects
  - Table now rendered as SceneObject
  - Added plant object
  - Both objects participate in depth sorting
- `main.lua` - Added require for sceneobject module
- `README.md` - Added depth sorting section and updated features list

### API Changes

#### New SceneObject Class
```lua
-- Create depth-sorted objects
local obj = SceneObject:new(name, x, y)
obj:setSprite(path)           -- Load sprite from file
obj:setSpriteImage(image)     -- Set sprite directly
obj:setOrigin(ox, oy)         -- Set origin (0-1 range)
obj:setBaseline(y)            -- Set depth sorting position
obj:setLayer(layer)           -- "background", "middle", "foreground"
obj:setDepthOffset(offset)    -- Manual sort adjustment
obj:setScale(sx, sy)          -- Scale sprite
obj:setVisible(visible)       -- Show/hide
obj:setAlpha(alpha)           -- Transparency
obj:setColor(r, g, b)         -- Color tint
obj:setDrawCallback(func)     -- Custom drawing
obj:withCanvas(w, h, func)    -- Helper for procedural graphics
```

#### New Scene Methods
```lua
scene:addObject(object)       -- Add scene object
scene:setDepthSorting(bool)   -- Enable/disable depth sorting
```

### How It Works

The depth sorting system works by:

1. **Baseline Positioning**: Every drawable entity (player, NPCs, objects) has a baseline Y position
2. **Automatic Sorting**: Before drawing, all entities are sorted by their baseline Y value
3. **Layer System**: Three layers allow fine control over rendering order
4. **Transparency Support**: All objects support transparent sprites via PNG or canvas with `clear(0,0,0,0)`

### Examples

#### Basic Usage
```lua
-- Create a table
local table = SceneObject:new("Table", 500, 450)
table:setSprite("assets/table.png")
table:setOrigin(0.5, 1)      -- Center-bottom
table:setBaseline(450)        -- Foot of table
scene:addObject(table)

-- Player walking at Y=400 → behind table
-- Player walking at Y=500 → in front of table
```

#### With Canvas
```lua
local barrel = SceneObject:new("Barrel", 300, 400)
barrel:withCanvas(60, 80, function()
    love.graphics.clear(0, 0, 0, 0)  -- Transparent
    love.graphics.setColor(0.5, 0.3, 0.2)
    love.graphics.rectangle("fill", 0, 0, 60, 80)
end)
barrel:setBaseline(400)
scene:addObject(barrel)
```

### Benefits

✅ **Generic**: Works for any type of point-and-click adventure game
✅ **Automatic**: No manual z-order management needed
✅ **Flexible**: Three layers + manual offsets for full control
✅ **Transparent**: Full alpha channel support
✅ **Debuggable**: Visual debug mode (hold D)
✅ **Easy to Use**: Simple API with sensible defaults
✅ **Well Documented**: 50+ examples in DEPTH_SORTING.md

### Testing

To see depth sorting in action:

1. Run the game: `love /home/darren/Documents/love2d-adventure`
2. Walk around the table and plant in room1
3. Hold 'D' to see debug visualization
4. Load the example: Change main.lua to load `scenes/depth_sorting_example`

### Breaking Changes

None. The system is backward compatible. Scenes without objects work exactly as before.

---

## Previous Version

Initial release with:
- Scene management
- Inventory system
- Verb-based interactions
- Dialog system
- Hotspot system
- Pathfinding
- NPC system
- Game state management
