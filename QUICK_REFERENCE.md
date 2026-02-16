# Quick Reference Guide

Quick reference for the most common tasks in the point-and-click adventure engine.

## Table of Contents

- [Creating Scenes](#creating-scenes)
- [Depth Sorting](#depth-sorting)
- [Collision Masks](#collision-masks)
- [Hotspots](#hotspots)
- [Inventory](#inventory)
- [Dialog](#dialog)
- [Game State](#game-state)

---

## Creating Scenes

### Basic Scene Template

```lua
local MyScene = {}
setmetatable(MyScene, {__index = Scene})

function MyScene:new(game)
    local self = Scene:new(game)
    setmetatable(self, {__index = MyScene})
    
    self.name = "My Scene"
    self.player.x = 400
    self.player.y = 500
    
    self.walkableArea = {
        100, 300, 900, 300, 900, 600, 100, 600
    }
    
    self:setBackground("assets/bg.png")
    
    return self
end

return MyScene
```

---

## Depth Sorting

### Create Object with Depth

```lua
-- Create object
local table = SceneObject:new("Table", 500, 500)
table:setSprite("assets/table.png")
table:setOrigin(0.5, 1)           -- Center-bottom
table:setBaseline(500)             -- Bottom Y position
table:setLayer("middle")           -- "background", "middle", "foreground"

scene:addObject(table)
```

### Layers

- **background**: Always behind everything
- **middle**: Depth sorted with player/NPCs
- **foreground**: Always on top

---

## Collision Masks

### Solid Object (Rectangle)

```lua
local crate = SceneObject:new("Crate", 300, 400)
crate:setSprite("assets/crate.png")
crate:setBaseline(400)

-- Add solid collision
crate:addCollisionRectangle(260, 320, 80, 80)

scene:addObject(crate)
```

### Round Object (Circle)

```lua
local barrel = SceneObject:new("Barrel", 500, 400)
barrel:setSprite("assets/barrel.png")
barrel:setBaseline(400)

-- Add circular collision
barrel:addCollisionCircle(500, 400, 35)

scene:addObject(barrel)
```

### Complex Object (Multiple Masks)

```lua
local table = SceneObject:new("Table", 500, 500)
table:setSprite("assets/table.png")
table:setBaseline(500)

-- Add collision for legs only (not tabletop)
table:addCollisionRectangle(440, 420, 30, 80)  -- Left leg
table:addCollisionRectangle(570, 420, 30, 80)  -- Right leg

scene:addObject(table)
```

### Irregular Shape (Polygon)

```lua
local rock = SceneObject:new("Rock", 600, 400)
rock:setSprite("assets/rock.png")
rock:setBaseline(400)

-- Add polygon collision
rock:addCollisionPolygon({
    580, 360,  -- Point 1
    640, 355,  -- Point 2
    650, 390,  -- Point 3
    630, 420,  -- Point 4
    590, 415,  -- Point 5
    575, 380   -- Point 6
})

scene:addObject(rock)
```

### No Collision (Decorative)

```lua
local flower = SceneObject:new("Flower", 700, 400)
flower:setSprite("assets/flower.png")
flower:setBaseline(400)

-- Don't add any collision masks!
scene:addObject(flower)
```

---

## Hotspots

### Basic Hotspot

```lua
local door = Hotspot:new("Door", 400, 200, 80, 150)
door:setInteractionPoint(440, 400)

door:onLook(function(game)
    game.dialogSystem:showMessage("A wooden door.")
end)

door:onUse(function(game)
    game.dialogSystem:showMessage("The door is locked.")
end)

scene:addHotspot(door)
```

### Pickable Item

```lua
local keyItem = {
    id = "key",
    name = "Old Key",
    description = "A rusty key.",
    stackable = false
}

local key = ItemHotspot:new(keyItem, 500, 300, 30, 20)
key:onTake(function(game)
    game.inventory:addItem(keyItem)
    game.dialogSystem:showMessage("You took the key.")
    game:setFlag("keyTaken", true)
    key:setEnabled(false)
end)

scene:addHotspot(key)
```

### Item Combination

```lua
door:onItemUse("key", function(game)
    game.dialogSystem:showMessage("You unlock the door!")
    game.inventory:removeItem("key")
    game:setFlag("doorUnlocked", true)
end)
```

---

## Inventory

### Add Item

```lua
local item = {
    id = "coin",
    name = "Gold Coin",
    description = "A shiny coin.",
    stackable = true
}

game.inventory:addItem(item)
```

### Remove Item

```lua
game.inventory:removeItem("coin")
```

### Check Item

```lua
if game.inventory:hasItem("coin") then
    -- Player has coin
end
```

---

## Dialog

### Simple Message

```lua
game.dialogSystem:showMessage("Hello, world!")
```

### Message with Speaker

```lua
game.dialogSystem:showMessage("Welcome, traveler.", "Innkeeper")
```

### Conversation with Choices

```lua
game.dialogSystem:showDialog({
    "What can I help you with?",
    {
        text = "Choose an option:",
        choices = {
            {
                text = "Tell me about this place.",
                callback = function()
                    game.dialogSystem:showMessage("This is a small village.", "Innkeeper")
                end
            },
            {
                text = "Do you have a room?",
                callback = function()
                    game.dialogSystem:showMessage("Yes, 10 gold per night.", "Innkeeper")
                end
            },
            {
                text = "Goodbye.",
                callback = function()
                    -- End conversation
                end
            }
        }
    }
}, "Innkeeper")
```

---

## Game State

### Set Flag

```lua
game:setFlag("puzzleSolved", true)
```

### Check Flag

```lua
if game:hasFlag("puzzleSolved") then
    -- Do something
end
```

### Get Flag Value

```lua
local value = game:getFlag("health")
```

---

## Common Patterns

### Table with Collision

```lua
-- Visual object
local table = SceneObject:new("Table", 500, 500)
table:setSprite("assets/table.png")
table:setOrigin(0.5, 1)
table:setBaseline(500)
table:addCollisionRectangle(440, 420, 30, 80)  -- Left leg
table:addCollisionRectangle(570, 420, 30, 80)  -- Right leg
scene:addObject(table)

-- Interactive hotspot
local tableHotspot = Hotspot:new("Table", 400, 420, 200, 80)
tableHotspot:setInteractionPoint(500, 510)
tableHotspot:onLook(function(game)
    game.dialogSystem:showMessage("An old wooden table.")
end)
scene:addHotspot(tableHotspot)
```

### Conditional Item

```lua
if not game:hasFlag("keyTaken") then
    local key = ItemHotspot:new(keyItem, 500, 300, 30, 20)
    key:onTake(function(game)
        game.inventory:addItem(keyItem)
        game:setFlag("keyTaken", true)
        key:setEnabled(false)
    end)
    scene:addHotspot(key)
end
```

### Locked Door

```lua
local door = Hotspot:new("Door", 400, 200, 80, 150)

door:onUse(function(game)
    if game:hasFlag("doorUnlocked") then
        game.dialogSystem:showMessage("The door is unlocked.")
        -- Load next scene
    else
        game.dialogSystem:showMessage("The door is locked.")
    end
end)

door:onItemUse("key", function(game)
    game.dialogSystem:showMessage("You unlock the door!")
    game.inventory:removeItem("key")
    game:setFlag("doorUnlocked", true)
end)

scene:addHotspot(door)
```

---

## Debug Mode

**Hold 'D' key to see:**
- Yellow dots = object baselines (depth sorting)
- Yellow boxes = sprite bounds
- Red areas = collision masks
- Green area = walkable area
- Red path = player movement path
- Hotspot names and areas

---

## Performance Tips

1. **Use rectangles** for collision when possible (fastest)
2. **Minimize polygons** (use only for irregular shapes)
3. **Combine simple shapes** instead of complex polygons
4. **Disable collision** for purely decorative objects
5. **Use background layer** for non-interactive distant objects

---

## Common Issues

### Player walks through objects
→ Check collision masks are added and enabled

### Object appears behind when it shouldn't
→ Check baseline values (lower Y = further back)

### Collision too large/small
→ Use debug mode (D) to visualize and adjust

### Player gets stuck
→ Check collision masks don't overlap walkable paths

---

## Full Documentation

- **[README.md](README.md)** - Main documentation
- **[DEPTH_SORTING.md](DEPTH_SORTING.md)** - Complete depth sorting guide
- **[COLLISION_MASKS.md](COLLISION_MASKS.md)** - Complete collision guide
- **[examples/](examples/)** - Working example scenes
