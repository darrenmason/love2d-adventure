# Collision Masks System

The engine includes a flexible collision mask system that allows you to control which objects block player movement and how. This enables realistic interactions where players can walk around solid objects, under table tops (but not through legs), or through purely decorative elements.

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Collision Mask Types](#collision-mask-types)
- [Examples](#examples)
- [Best Practices](#best-practices)
- [API Reference](#api-reference)

---

## Overview

Collision masks define the areas where a scene object blocks player movement. You have complete control over:

- **What blocks movement**: Add collision masks only where needed
- **Shape of collision**: Rectangle, circle, or polygon
- **Complex objects**: Multiple masks per object (e.g., table legs but not tabletop)
- **No collision**: Decorative objects the player can walk through

**Key Features:**
- ✅ Multiple collision mask types (rectangle, circle, polygon)
- ✅ Multiple masks per object for complex shapes
- ✅ Optional collision (objects without masks are passable)
- ✅ Character collision radius support
- ✅ Debug visualization (hold D key)
- ✅ Automatic pathfinding integration

---

## How It Works

### Collision Detection

When a player tries to move to a position, the engine:

1. **Checks destination**: Is the target point inside any collision mask?
2. **Checks path**: During movement, continuously checks for collisions
3. **Stops on collision**: Movement stops if hitting an obstacle
4. **Finds alternatives**: Automatically finds nearest walkable point if needed

### Character Radius

The player character has a collision radius (default 10 pixels) that's checked against all object collision masks. This prevents the character from getting too close to solid objects.

---

## Collision Mask Types

### 1. Rectangle Collision

Best for: Boxes, crates, walls, rectangular furniture

```lua
object:addCollisionRectangle(x, y, width, height)
```

**Parameters:**
- `x`, `y`: Top-left corner position
- `width`, `height`: Rectangle dimensions

**Example:**
```lua
-- Create a crate
local crate = SceneObject:new("Crate", 400, 450)
crate:setSprite("assets/crate.png")
crate:setBaseline(450)

-- Add rectangular collision mask
crate:addCollisionRectangle(360, 370, 80, 80)

scene:addObject(crate)
-- Player cannot walk through the crate
```

### 2. Circle Collision

Best for: Barrels, pillars, round objects

```lua
object:addCollisionCircle(x, y, radius)
```

**Parameters:**
- `x`, `y`: Center position
- `radius`: Circle radius

**Example:**
```lua
-- Create a barrel
local barrel = SceneObject:new("Barrel", 500, 400)
barrel:setSprite("assets/barrel.png")
barrel:setBaseline(400)

-- Add circular collision mask
barrel:addCollisionCircle(500, 400, 35)

scene:addObject(barrel)
-- Player cannot walk through the barrel
```

### 3. Polygon Collision

Best for: Irregular shapes, rocks, complex objects

```lua
object:addCollisionPolygon({x1, y1, x2, y2, x3, y3, ...})
```

**Parameters:**
- `points`: Table of coordinates {x1, y1, x2, y2, ...}

**Example:**
```lua
-- Create an irregular rock
local rock = SceneObject:new("Rock", 600, 450)
rock:setSprite("assets/rock.png")
rock:setBaseline(450)

-- Add polygon collision matching rock shape
local points = {
    580, 390,  -- Point 1
    640, 385,  -- Point 2
    650, 420,  -- Point 3
    630, 445,  -- Point 4
    590, 440,  -- Point 5
    575, 410   -- Point 6
}
rock:addCollisionPolygon(points)

scene:addObject(rock)
```

### 4. Multiple Masks (Complex Objects)

You can add **multiple collision masks** to a single object for complex shapes.

**Perfect for:**
- Tables (legs only, not the top)
- Chairs (legs only, not the seat)
- Arches (sides only, not the opening)

**Example:**
```lua
-- Create a table
local table = SceneObject:new("Table", 500, 500)
table:setSprite("assets/table.png")
table:setBaseline(500)

-- Add collision ONLY for the legs
table:addCollisionRectangle(440, 420, 25, 80)  -- Left front leg
table:addCollisionRectangle(555, 420, 25, 80)  -- Right front leg

scene:addObject(table)
-- Player can walk "under" the table top but not through legs!
```

### 5. No Collision (Decorative)

Simply **don't add any collision masks** for decorative objects.

**Example:**
```lua
-- Create a flower
local flower = SceneObject:new("Flower", 700, 400)
flower:setSprite("assets/flower.png")
flower:setBaseline(400)

-- NO collision masks added!
scene:addObject(flower)
-- Player can walk right through the flower
```

---

## Examples

### Example 1: Solid Crate

```lua
-- Complete solid object example
local crate = SceneObject:new("Wooden Crate", 300, 450)

-- Create sprite
local canvas = love.graphics.newCanvas(80, 80)
love.graphics.setCanvas(canvas)
love.graphics.clear(0, 0, 0, 0)

love.graphics.setColor(0.6, 0.4, 0.2)
love.graphics.rectangle("fill", 0, 0, 80, 80)

love.graphics.setCanvas()
love.graphics.setColor(1, 1, 1)

crate:setSpriteImage(canvas)
crate:setOrigin(0.5, 1)
crate:setBaseline(450)

-- Add solid collision (entire crate)
crate:addCollisionRectangle(260, 370, 80, 80)

scene:addObject(crate)
```

### Example 2: Table with Leg Collision

```lua
-- Table where player can walk under top but not through legs
local table = SceneObject:new("Dining Table", 500, 550)
table:setSprite("assets/table.png")
table:setOrigin(0.5, 1)
table:setBaseline(550)

-- Add collision for EACH leg separately
-- Left front leg
table:addCollisionRectangle(430, 470, 30, 80)
-- Right front leg
table:addCollisionRectangle(570, 470, 30, 80)

scene:addObject(table)

-- Result: Player can walk at Y < 470 (under the table)
--         but cannot walk through the leg areas
```

### Example 3: Circular Pillar

```lua
-- Round pillar with circular collision
local pillar = SceneObject:new("Stone Pillar", 600, 400)
pillar:setSprite("assets/pillar.png")
pillar:setBaseline(400)

-- Add circular collision
pillar:addCollisionCircle(600, 370, 40)

scene:addObject(pillar)
```

### Example 4: L-Shaped Wall (Polygon)

```lua
-- Complex L-shaped obstacle
local wall = SceneObject:new("L-Wall", 400, 500)
wall:setSprite("assets/wall.png")
wall:setBaseline(500)

-- Define L-shape polygon
local lShape = {
    350, 400,  -- Top-left
    450, 400,  -- Top-right
    450, 450,  -- Inner corner top
    400, 450,  -- Inner corner left
    400, 500,  -- Bottom-left inner
    350, 500   -- Bottom-left
}
wall:addCollisionPolygon(lShape)

scene:addObject(wall)
```

### Example 5: Enabling/Disabling Collision

```lua
-- Create object with collision
local gate = SceneObject:new("Gate", 500, 400)
gate:setSprite("assets/gate.png")
gate:setBaseline(400)
gate:addCollisionRectangle(460, 320, 80, 80)

scene:addObject(gate)

-- Later: disable collision when gate opens
gate:disableCollision()

-- Re-enable when gate closes
gate:enableCollision()
```

### Example 6: Dynamic Collision (Moving Objects)

```lua
-- For moving objects, update collision masks when position changes
local movingCrate = SceneObject:new("Moving Crate", 300, 400)
movingCrate:setSprite("assets/crate.png")
movingCrate:setBaseline(400)

-- Initial collision
movingCrate:addCollisionRectangle(260, 320, 80, 80)

-- When object moves to new position
function moveCrate(newX, newY)
    movingCrate.x = newX
    movingCrate.y = newY
    movingCrate.baseline = newY
    
    -- Update collision masks
    movingCrate:clearCollisionMasks()
    movingCrate:addCollisionRectangle(newX - 40, newY - 80, 80, 80)
end
```

---

## Best Practices

### 1. Match Collision to Visual

Collision masks should roughly match the visual appearance of solid parts:

```lua
-- ✅ Good: Collision matches visible solid parts
table:addCollisionRectangle(leftLegX, leftLegY, legWidth, legHeight)

-- ❌ Bad: Collision extends beyond visible object
table:addCollisionRectangle(0, 0, 1000, 1000)
```

### 2. Use Appropriate Shapes

Choose the simplest shape that works:

- **Rectangle**: Most objects (fast, simple)
- **Circle**: Round objects (pillars, barrels)
- **Polygon**: Only for truly irregular shapes (more complex)

### 3. Don't Over-Collide

Only add collision where needed:

```lua
-- ✅ Good: Only legs block movement
table:addCollisionRectangle(leftLegX, leftLegY, legW, legH)
table:addCollisionRectangle(rightLegX, rightLegY, legW, legH)

-- ❌ Bad: Entire table blocks movement (unrealistic)
table:addCollisionRectangle(tableX, tableY, tableW, tableH)
```

### 4. Test with Debug Mode

Always test collision masks with debug visualization:

```
Press and hold 'D' to see:
- Red filled areas = collision masks
- Red outlines = collision boundaries
```

### 5. Consider Character Radius

Remember the player has a collision radius (default 10px):

```lua
-- Character can't get closer than 10px to any collision mask
-- Plan your masks accordingly
```

### 6. Layer Decorative Objects

Objects without collision don't need to be in the "middle" layer:

```lua
-- Decorative background element
local flower = SceneObject:new("Flower", 500, 400)
flower:setSprite("assets/flower.png")
flower:setLayer("background")  -- Behind everything
-- No collision needed

scene:addObject(flower)
```

---

## API Reference

### SceneObject Collision Methods

#### enableCollision()

Enable collision detection for this object.

```lua
object:enableCollision()
```

**Returns:** self (for chaining)

---

#### disableCollision()

Disable collision detection for this object.

```lua
object:disableCollision()
```

**Returns:** self (for chaining)

---

#### addCollisionRectangle(x, y, width, height)

Add a rectangular collision mask.

**Parameters:**
- `x` (number): Top-left X position
- `y` (number): Top-left Y position
- `width` (number): Rectangle width
- `height` (number): Rectangle height

**Returns:** self (for chaining)

**Example:**
```lua
object:addCollisionRectangle(100, 200, 50, 80)
```

---

#### addCollisionCircle(x, y, radius)

Add a circular collision mask.

**Parameters:**
- `x` (number): Center X position
- `y` (number): Center Y position
- `radius` (number): Circle radius

**Returns:** self (for chaining)

**Example:**
```lua
object:addCollisionCircle(400, 300, 40)
```

---

#### addCollisionPolygon(points)

Add a polygon collision mask.

**Parameters:**
- `points` (table): Polygon vertices {x1, y1, x2, y2, x3, y3, ...}

**Returns:** self (for chaining)

**Example:**
```lua
object:addCollisionPolygon({
    100, 100,
    200, 120,
    180, 200,
    90, 180
})
```

---

#### clearCollisionMasks()

Remove all collision masks from this object.

```lua
object:clearCollisionMasks()
```

**Returns:** self (for chaining)

---

#### checkCollision(x, y, radius)

Check if a point (with optional radius) collides with this object.

**Parameters:**
- `x` (number): Point X position
- `y` (number): Point Y position
- `radius` (number, optional): Check radius (default 0)

**Returns:** boolean (true if collision detected)

**Example:**
```lua
if object:checkCollision(playerX, playerY, 10) then
    print("Player is colliding with object!")
end
```

---

### Scene Collision Methods

#### checkCollisionAtPoint(x, y, radius)

Check if a point collides with any object in the scene.

**Parameters:**
- `x` (number): Point X position
- `y` (number): Point Y position
- `radius` (number, optional): Check radius

**Returns:** 
- `collides` (boolean): True if collision detected
- `object` (SceneObject or nil): The colliding object

**Example:**
```lua
local collides, obj = scene:checkCollisionAtPoint(500, 400, 10)
if collides then
    print("Collision with: " .. obj.name)
end
```

---

#### getCollidingObjects(x, y, radius)

Get all objects that collide at a point.

**Parameters:**
- `x` (number): Point X position
- `y` (number): Point Y position
- `radius` (number, optional): Check radius

**Returns:** table of SceneObjects

**Example:**
```lua
local objects = scene:getCollidingObjects(500, 400, 10)
for _, obj in ipairs(objects) do
    print("Colliding with: " .. obj.name)
end
```

---

#### findNearestWalkablePoint(x, y, searchRadius)

Find the nearest point that doesn't collide with any objects.

**Parameters:**
- `x` (number): Target X position
- `y` (number): Target Y position
- `searchRadius` (number, optional): Search radius (default 50)

**Returns:** 
- `x` (number): Nearest walkable X
- `y` (number): Nearest walkable Y

**Example:**
```lua
local walkableX, walkableY = scene:findNearestWalkablePoint(500, 400)
scene:walkTo(walkableX, walkableY)
```

---

## Troubleshooting

### Player walks through objects

**Solution:** Make sure you've added collision masks:

```lua
-- Check if hasCollision is true
print(object.hasCollision)  -- Should be true

-- Check if masks exist
print(#object.collisionMasks)  -- Should be > 0
```

### Collision area too large/small

**Solution:** Use debug mode (hold D) to visualize collision masks and adjust coordinates:

```lua
-- Visualize and adjust
object:clearCollisionMasks()
object:addCollisionRectangle(newX, newY, newWidth, newHeight)
```

### Player gets stuck

**Solution:** Ensure collision masks don't overlap walkable areas:

```lua
-- Make sure collision rectangles are within scene bounds
-- and don't overlap important walkable paths
```

### Complex shape not working

**Solution:** Break it into multiple simpler shapes:

```lua
-- Instead of complex polygon
-- Use multiple rectangles/circles
object:addCollisionRectangle(x1, y1, w1, h1)
object:addCollisionRectangle(x2, y2, w2, h2)
object:addCollisionCircle(x3, y3, r)
```

---

## Performance Notes

- **Rectangle collision**: Fastest (use when possible)
- **Circle collision**: Fast
- **Polygon collision**: Slower (use sparingly for complex shapes)
- **Multiple masks**: Slightly slower but still fast for reasonable counts

The collision system is optimized for typical point-and-click adventure games with dozens of objects. Performance should not be an issue for most games.

---

## Summary

The collision mask system gives you complete control over movement blocking:

✅ **Simple solid objects**: One rectangle/circle mask
✅ **Complex furniture**: Multiple masks (e.g., table legs only)
✅ **Irregular shapes**: Polygon masks
✅ **Decorative items**: No masks (walkthrough)
✅ **Dynamic objects**: Can be enabled/disabled/updated

**Quick Checklist:**
- ✅ Add collision masks to solid objects
- ✅ Use multiple masks for complex shapes (table legs)
- ✅ Skip masks for decorative objects
- ✅ Test with debug mode (hold D)
- ✅ Match collision to visual appearance
- ✅ Use simplest shape that works

Happy game making! 🎮
