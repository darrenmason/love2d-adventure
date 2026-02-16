# Depth Sorting & Layering System

The engine includes a sophisticated depth sorting system that allows characters to walk behind and in front of objects, creating a realistic 3D-like effect in your 2D point-and-click adventure game.

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Scene Objects](#scene-objects)
- [Layers](#layers)
- [Examples](#examples)
- [Best Practices](#best-practices)
- [API Reference](#api-reference)

---

## Overview

The depth sorting system automatically determines which objects, characters, and NPCs should be drawn in front of or behind each other based on their Y position. This creates the illusion of depth and allows for realistic interactions with the environment.

**Key Features:**
- ✅ Automatic depth sorting based on Y position
- ✅ Support for transparent sprites/images
- ✅ Multiple rendering layers (background, middle, foreground)
- ✅ Manual depth offset adjustment
- ✅ Works with player, NPCs, and scene objects
- ✅ Debug visualization (hold D key)

---

## How It Works

### Baseline Concept

Every drawable entity has a **baseline** Y position:
- For characters: typically at their feet
- For objects: typically at the bottom of the object
- Lower Y = further back in the scene
- Higher Y = closer to the camera

The engine sorts all entities by their baseline Y position and draws them from back to front (painter's algorithm).

### Example

```
┌─────────────────────────────┐
│         Back Wall           │  Y = 100
│                             │
│    [TABLE]                  │  Y = 400 (baseline)
│       |                     │
│    [PLAYER] ←── walking     │  Y = 450 (baseline)
│                             │
└─────────────────────────────┘

Drawing order:
1. Wall (background layer)
2. Table (baseline Y=400) ← drawn first
3. Player (baseline Y=450) ← drawn on top of table
```

When the player walks to Y=350 (above the table), they'll be drawn **behind** the table automatically!

---

## Scene Objects

`SceneObject` is the main class for creating depth-sorted props, furniture, and environmental objects.

### Creating a Scene Object

```lua
-- Create a simple object
local table = SceneObject:new("Table", x, y)

-- Add a sprite (supports transparency)
table:setSprite("assets/furniture/table.png")

-- Set the origin point (where x,y anchors to)
table:setOrigin(0.5, 1)  -- center-bottom (recommended for proper baseline)

-- Set baseline for depth sorting (usually the bottom Y of the object)
table:setBaseline(550)

-- Add to scene
scene:addObject(table)
```

### Using Canvas/Procedural Graphics

```lua
-- Create object with procedurally drawn graphics
local barrel = SceneObject:new("Barrel", 300, 400)

barrel:withCanvas(80, 100, function()
    -- Draw the barrel
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.ellipse("fill", 40, 20, 35, 15)
    love.graphics.rectangle("fill", 5, 20, 70, 65)
    love.graphics.ellipse("fill", 40, 85, 35, 15)
end)

barrel:setOrigin(0.5, 1)
barrel:setBaseline(400)
scene:addObject(barrel)
```

### Custom Draw Callback

```lua
local customObject = SceneObject:new("Custom", 500, 300)

customObject:setDrawCallback(function(self)
    -- Custom drawing code
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", self.x, self.y, 30)
    love.graphics.setColor(1, 1, 1)
end)

customObject:setBaseline(300)
scene:addObject(customObject)
```

---

## Layers

The system supports three rendering layers with different behaviors:

### 1. Background Layer

Objects in the background layer are **always drawn behind everything else**, regardless of Y position. Perfect for distant scenery, back walls, etc.

```lua
local backWall = SceneObject:new("Wall", 512, 200)
backWall:setSprite("assets/bg/wall.png")
backWall:setLayer("background")  -- Always behind
scene:addObject(backWall)
```

### 2. Middle Layer (Default)

Objects in the middle layer participate in **depth sorting** with characters and NPCs. This is the default layer and what you'll use most often.

```lua
local table = SceneObject:new("Table", 500, 400)
table:setSprite("assets/furniture/table.png")
table:setLayer("middle")  -- Depth sorted (this is the default)
table:setBaseline(400)
scene:addObject(table)
```

### 3. Foreground Layer

Objects in the foreground layer are **always drawn on top of everything else**. Useful for overhead objects, HUD elements integrated into the scene, etc.

```lua
local chandelier = SceneObject:new("Chandelier", 500, 100)
chandelier:setSprite("assets/props/chandelier.png")
chandelier:setLayer("foreground")  -- Always on top
scene:addObject(chandelier)
```

---

## Examples

### Example 1: Table with Depth Sorting

```lua
function MyRoom:createSceneObjects()
    -- Create table canvas with transparency
    local tableCanvas = love.graphics.newCanvas(200, 150)
    love.graphics.setCanvas(tableCanvas)
    love.graphics.clear(0, 0, 0, 0)  -- Transparent
    
    -- Draw table
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.rectangle("fill", 0, 0, 200, 100)  -- Top
    love.graphics.rectangle("fill", 10, 100, 30, 50)  -- Left leg
    love.graphics.rectangle("fill", 160, 100, 30, 50) -- Right leg
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    -- Create scene object
    local table = SceneObject:new("Table", 500, 500)
    table:setSpriteImage(tableCanvas)
    table:setOrigin(0.5, 1)      -- Center-bottom
    table:setBaseline(500)        -- Bottom of legs
    table:setLayer("middle")
    
    self:addObject(table)
end
```

Now the player can walk:
- **Above the table** (Y < 500): drawn behind table
- **Below the table** (Y > 500): drawn in front of table

### Example 2: Multiple Objects with Different Depths

```lua
function MyRoom:createSceneObjects()
    -- Near object (high Y = closer to camera)
    local barrel = SceneObject:new("Barrel", 400, 550)
    barrel:setSprite("assets/barrel.png")
    barrel:setBaseline(550)
    self:addObject(barrel)
    
    -- Middle object
    local chair = SceneObject:new("Chair", 500, 450)
    chair:setSprite("assets/chair.png")
    chair:setBaseline(450)
    self:addObject(chair)
    
    -- Far object (low Y = further from camera)
    local painting = SceneObject:new("Painting", 600, 300)
    painting:setSprite("assets/painting.png")
    painting:setBaseline(300)
    self:addObject(painting)
    
    -- These will automatically sort properly with the player!
end
```

### Example 3: Adjusting Depth with Offset

Sometimes you want to manually tweak the sorting order:

```lua
local plant = SceneObject:new("Plant", 300, 400)
plant:setSprite("assets/plant.png")
plant:setBaseline(400)

-- Make it render slightly higher in the depth order
-- (drawn later = appears on top)
plant:setDepthOffset(10)

self:addObject(plant)
```

### Example 4: NPCs with Depth Sorting

NPCs automatically participate in depth sorting:

```lua
local npc = {
    name = "Shopkeeper",
    x = 600,
    y = 450,
    baseline = 450,  -- Add baseline for depth sorting
    -- ... other NPC properties
}

function npc:draw()
    -- Draw NPC sprite
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.sprite, self.x, self.y)
end

scene:addNPC(npc)
-- NPC will now be sorted with player and objects!
```

---

## Best Practices

### 1. Set Proper Baselines

Always set the baseline at the **bottom** of the object where it "touches" the ground:

```lua
-- ❌ Wrong: baseline at object center
object:setBaseline(object.y - object.height / 2)

-- ✅ Correct: baseline at bottom
object:setBaseline(object.y)
```

### 2. Use Correct Origin

For proper baseline rendering, set origin to center-bottom:

```lua
object:setOrigin(0.5, 1)  -- ✅ Center-bottom (recommended)
-- Not: (0.5, 0.5) which is center-center
```

### 3. Group Related Objects

If multiple objects should always maintain a specific order relative to each other, use `setDepthOffset()`:

```lua
local table = SceneObject:new("Table", 500, 400)
table:setBaseline(400)

local tablecloth = SceneObject:new("Tablecloth", 500, 400)
tablecloth:setBaseline(400)
tablecloth:setDepthOffset(1)  -- Always on top of table
```

### 4. Use Appropriate Layers

- **Background**: Walls, distant scenery, background props
- **Middle**: Everything the player can walk around
- **Foreground**: Overhangs, ceiling elements, UI elements

### 5. Test with Debug Mode

Press and hold the **D** key to visualize:
- Object baselines (yellow dots)
- Object bounds (yellow outlines)
- Hotspot areas
- Walkable areas

This helps you verify depth sorting is working correctly.

### 6. Transparent Backgrounds

Always use transparent backgrounds for object sprites:

```lua
local canvas = love.graphics.newCanvas(width, height)
love.graphics.setCanvas(canvas)
love.graphics.clear(0, 0, 0, 0)  -- ✅ Transparent
-- ... draw object ...
love.graphics.setCanvas()
```

---

## API Reference

### SceneObject:new(name, x, y)

Creates a new scene object.

**Parameters:**
- `name` (string): Display name for debugging
- `x` (number): X position
- `y` (number): Y position (also initial baseline)

**Returns:** SceneObject instance

---

### SceneObject:setSprite(imagePath)

Load sprite from file path.

**Parameters:**
- `imagePath` (string): Path to image file

**Returns:** self (for chaining)

---

### SceneObject:setSpriteImage(image)

Set sprite directly (Image or Canvas).

**Parameters:**
- `image` (Image/Canvas): Pre-loaded image or canvas

**Returns:** self (for chaining)

---

### SceneObject:setOrigin(ox, oy)

Set origin point for positioning.

**Parameters:**
- `ox` (number): Origin X (0-1 range, 0.5 = center)
- `oy` (number): Origin Y (0-1 range, 1 = bottom)

**Returns:** self (for chaining)

**Common values:**
- `(0.5, 1)` - Center-bottom (recommended for depth sorting)
- `(0.5, 0.5)` - Center-center
- `(0, 0)` - Top-left

---

### SceneObject:setBaseline(y)

Set Y position for depth sorting.

**Parameters:**
- `y` (number): Baseline Y position (usually bottom of object)

**Returns:** self (for chaining)

---

### SceneObject:setLayer(layer)

Set rendering layer.

**Parameters:**
- `layer` (string): "background", "middle", or "foreground"

**Returns:** self (for chaining)

---

### SceneObject:setDepthOffset(offset)

Manual adjustment to sort order.

**Parameters:**
- `offset` (number): Offset value (higher = drawn later/on top)

**Returns:** self (for chaining)

---

### SceneObject:setScale(sx, sy)

Set sprite scale.

**Parameters:**
- `sx` (number): X scale
- `sy` (number, optional): Y scale (defaults to sx)

**Returns:** self (for chaining)

---

### SceneObject:setDrawCallback(callback)

Set custom draw function.

**Parameters:**
- `callback` (function): Function called as `callback(self)`

**Returns:** self (for chaining)

**Example:**
```lua
object:setDrawCallback(function(self)
    love.graphics.circle("fill", self.x, self.y, 20)
end)
```

---

### SceneObject:setVisible(visible)

Show or hide object.

**Parameters:**
- `visible` (boolean): Visibility state

**Returns:** self (for chaining)

---

### SceneObject:setAlpha(alpha)

Set transparency.

**Parameters:**
- `alpha` (number): Alpha value (0-1)

**Returns:** self (for chaining)

---

### SceneObject:setColor(r, g, b)

Set color tint.

**Parameters:**
- `r` (number): Red (0-1)
- `g` (number): Green (0-1)
- `b` (number): Blue (0-1)

**Returns:** self (for chaining)

---

### SceneObject:withCanvas(width, height, drawFunc)

Helper to create object with procedural graphics.

**Parameters:**
- `width` (number): Canvas width
- `height` (number): Canvas height
- `drawFunc` (function): Drawing function

**Returns:** self (for chaining)

**Example:**
```lua
object:withCanvas(100, 100, function()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 0, 0, 100, 100)
end)
```

---

### Scene:addObject(object)

Add scene object to the scene.

**Parameters:**
- `object` (SceneObject): Object to add

---

### Scene:setDepthSorting(enabled)

Enable or disable depth sorting.

**Parameters:**
- `enabled` (boolean): Depth sorting state

**Note:** Depth sorting is enabled by default. Disable for legacy rendering or special cases.

---

## Troubleshooting

### Player appears behind/in front when they shouldn't

**Solution:** Check the baseline values. Use debug mode (hold D) to visualize baselines.

```lua
-- Make sure baselines are at the bottom of objects
object:setBaseline(object.y)  -- where y is the bottom position
```

### Object appears cut off

**Solution:** Check the origin and ensure it's set correctly.

```lua
object:setOrigin(0.5, 1)  -- Center-bottom is usually correct
```

### Objects rendering in wrong layer

**Solution:** Verify the layer is set correctly.

```lua
object:setLayer("middle")  -- Should be "background", "middle", or "foreground"
```

### Depth sorting not working at all

**Solution:** Make sure depth sorting is enabled (it should be by default).

```lua
scene:setDepthSorting(true)
```

---

## Advanced: Dynamic Baseline

For moving objects or NPCs, you can update the baseline dynamically:

```lua
function npc:update(dt)
    -- Move the NPC
    self.y = self.y + self.speed * dt
    
    -- Update baseline for depth sorting
    self.baseline = self.y
end
```

---

## Summary

The depth sorting system makes it easy to create realistic, immersive point-and-click adventure games where characters can naturally interact with the environment. By setting proper baselines and using the three-layer system, you can create scenes with convincing depth and perspective.

**Quick Checklist:**
- ✅ Create objects with `SceneObject:new()`
- ✅ Set sprite with transparency
- ✅ Set origin to center-bottom `(0.5, 1)`
- ✅ Set baseline to bottom of object
- ✅ Choose appropriate layer
- ✅ Add to scene with `scene:addObject()`
- ✅ Test with debug mode (hold D)

Happy game making! 🎮
