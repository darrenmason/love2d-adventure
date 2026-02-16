# Changelog

## [Current] - Depth Sorting & Collision Masks

### Version 2.0 - Complete Depth & Collision System

### Added

#### New Features

##### Depth Sorting System
- **Automatic z-ordering** for realistic depth perception
  - Characters can now walk behind and in front of objects
  - Supports transparent sprites/images
  - Three rendering layers: background, middle, foreground
  - Manual depth offset adjustment
  - Debug visualization with 'D' key

##### Collision Mask System
- **Flexible collision detection** for object blocking
  - Rectangle collision masks
  - Circle collision masks
  - Polygon collision masks (for irregular shapes)
  - Multiple masks per object (e.g., table legs only)
  - Optional collision (decorative objects)
  - Character collision radius support
  - Automatic pathfinding integration
  - Debug visualization with 'D' key (red areas)

#### New Files
- `engine/sceneobject.lua` - Scene object system with depth sorting and collision
- `DEPTH_SORTING.md` - Complete depth sorting documentation (400+ lines, 50+ examples)
- `COLLISION_MASKS.md` - Complete collision system documentation (600+ lines, 30+ examples)
- `examples/depth_sorting_example.lua` - Interactive depth sorting demo
- `examples/collision_example.lua` - Interactive collision masks demo
- `CHANGELOG.md` - This file

#### Updated Files
- `engine/sceneobject.lua` - Added complete collision system
  - Collision mask support (rectangle, circle, polygon)
  - Multiple masks per object
  - Collision checking methods
  - Debug visualization for collision masks
  
- `engine/scene.lua` - Added depth sorting and collision integration
  - New `objects` array for scene objects
  - `addObject()` method
  - `drawWithDepthSorting()` method
  - Automatic entity sorting by Y baseline
  - `checkCollisionAtPoint()` method
  - `findNearestWalkablePoint()` method
  - `getCollidingObjects()` method
  - Collision checking during player movement
  
- `scenes/room1.lua` - Updated with depth-sorted and collidable objects
  - Table rendered as SceneObject with leg collision masks
  - Added plant object with circular collision
  - Both objects participate in depth sorting and collision
  
- `main.lua` - Added require for sceneobject module
- `README.md` - Added depth sorting and collision sections

### API Changes

#### New SceneObject Class
```lua
-- Create depth-sorted objects with collision
local obj = SceneObject:new(name, x, y)

-- Visual/Depth methods
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

-- Collision methods
obj:addCollisionRectangle(x, y, w, h)    -- Add rectangle mask
obj:addCollisionCircle(x, y, radius)     -- Add circle mask
obj:addCollisionPolygon(points)          -- Add polygon mask
obj:clearCollisionMasks()                -- Remove all masks
obj:enableCollision()                    -- Enable collision
obj:disableCollision()                   -- Disable collision
obj:checkCollision(x, y, radius)         -- Check if point collides
```

#### New Scene Methods
```lua
-- Depth sorting
scene:addObject(object)                      -- Add scene object
scene:setDepthSorting(bool)                  -- Enable/disable depth sorting

-- Collision detection
scene:checkCollisionAtPoint(x, y, radius)    -- Check collision at point
scene:findNearestWalkablePoint(x, y, radius) -- Find nearest walkable point
scene:getCollidingObjects(x, y, radius)      -- Get all colliding objects
```

### How It Works

The depth sorting system works by:

1. **Baseline Positioning**: Every drawable entity (player, NPCs, objects) has a baseline Y position
2. **Automatic Sorting**: Before drawing, all entities are sorted by their baseline Y value
3. **Layer System**: Three layers allow fine control over rendering order
4. **Transparency Support**: All objects support transparent sprites via PNG or canvas with `clear(0,0,0,0)`

### Examples

#### Depth Sorting Example
```lua
-- Create a table with depth sorting
local table = SceneObject:new("Table", 500, 450)
table:setSprite("assets/table.png")
table:setOrigin(0.5, 1)      -- Center-bottom
table:setBaseline(450)        -- Foot of table
scene:addObject(table)

-- Player walking at Y=400 → behind table
-- Player walking at Y=500 → in front of table
```

#### Collision Masks Example
```lua
-- Create a table with leg collision
local table = SceneObject:new("Table", 500, 500)
table:setSprite("assets/table.png")
table:setBaseline(500)

-- Add collision ONLY for legs (not tabletop!)
table:addCollisionRectangle(440, 420, 30, 80)  -- Left leg
table:addCollisionRectangle(570, 420, 30, 80)  -- Right leg

scene:addObject(table)

-- Player can walk "under" table (Y < 420)
-- Player blocked by legs (collision zones)
```

#### Complex Collision Example
```lua
-- Solid crate (rectangle)
local crate = SceneObject:new("Crate", 300, 400)
crate:setSprite("assets/crate.png")
crate:addCollisionRectangle(260, 320, 80, 80)

-- Round barrel (circle)
local barrel = SceneObject:new("Barrel", 500, 400)
barrel:setSprite("assets/barrel.png")
barrel:addCollisionCircle(500, 400, 35)

-- Irregular rock (polygon)
local rock = SceneObject:new("Rock", 700, 400)
rock:setSprite("assets/rock.png")
rock:addCollisionPolygon({680, 360, 740, 355, 750, 390, 710, 420, 670, 415})

-- Decorative flower (no collision)
local flower = SceneObject:new("Flower", 600, 350)
flower:setSprite("assets/flower.png")
-- No collision masks added - player can walk through it!

scene:addObject(crate)
scene:addObject(barrel)
scene:addObject(rock)
scene:addObject(flower)
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
✅ **Automatic**: No manual z-order or collision management needed
✅ **Flexible**: 
  - Three rendering layers + manual depth offsets
  - Multiple collision mask types
  - Complex multi-mask objects (table legs)
✅ **Transparent**: Full alpha channel support for sprites
✅ **Realistic**: Characters walk around objects naturally
✅ **Debuggable**: Visual debug mode for depth and collision (hold D)
✅ **Easy to Use**: Simple, chainable API with sensible defaults
✅ **Well Documented**: 
  - 400+ lines depth sorting docs
  - 600+ lines collision docs
  - 80+ code examples total

### Testing

To see depth sorting and collision in action:

1. Run the game: `love /home/darren/Documents/love2d-adventure`
2. Walk around the table and plant in room1
3. Try walking through the table legs (blocked!)
4. Try walking "under" the table top (allowed!)
5. Hold 'D' to see debug visualization:
   - Yellow dots = baselines (depth sorting)
   - Yellow boxes = sprite bounds
   - Red areas = collision masks
6. Load examples:
   - `examples/depth_sorting_example.lua` - Depth demo
   - `examples/collision_example.lua` - Collision demo

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
