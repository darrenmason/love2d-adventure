# LÖVE2D Point-and-Click Adventure Game Engine

A traditional point-and-click adventure game engine built with [LÖVE2D](https://love2d.org/). This engine provides all the classic features you'd expect from games like Monkey Island, Day of the Tentacle, and other LucasArts/Sierra classics.

## Features

### Core Systems

- **Scene Management**: Create multiple rooms/scenes with seamless transitions
- **Inventory System**: Pick up, combine, and use items
- **Verb-Based Interactions**: Classic SCUMM-style verbs (Look, Use, Talk, Take, Walk)
- **Dialog System**: Animated text with conversation trees and dialog choices
- **Hotspot System**: Define clickable areas with different shapes (rectangle, circle, polygon)
- **Pathfinding**: Character movement with walkable areas
- **NPC System**: Interactive characters with conversations
- **Game State**: Persistent flags for tracking progress
- **Depth Sorting System**: Automatic z-ordering so characters can walk behind and in front of objects with transparency support

### Interaction Types

- **Look**: Examine objects and get descriptions
- **Use**: Interact with objects in the environment
- **Talk**: Converse with NPCs
- **Take**: Pick up items and add them to inventory
- **Walk**: Move character to locations
- **Item Combinations**: Combine inventory items or use items on hotspots

## Installation

1. Install LÖVE2D from https://love2d.org/ (version 11.5 recommended)
2. Clone or download this repository
3. Run the game:
   ```bash
   love /path/to/love2d-isometric
   ```

## Controls

### Mouse

- **Left Click**: Interact with objects using the current verb
- **Right Click**: Cycle through available verbs
- **Inventory**: Click items to select them for use

### Keyboard

- **ESC**: Quit the game
- **D** (hold): Show debug overlays (hotspots, walkable areas, paths)
- **Number Keys (1-9)**: Quick select dialog choices

### Verbs

- **Walk**: Move character to location
- **Look**: Examine objects
- **Use**: Interact with objects
- **Talk**: Speak with NPCs
- **Take**: Pick up items

## Quick Start Guide

### Creating a New Scene

```lua
-- scenes/myroom.lua
local MyRoom = {}
setmetatable(MyRoom, {__index = Scene})

function MyRoom:new(game)
    local self = Scene:new(game)
    setmetatable(self, {__index = MyRoom})
    
    self.name = "My Room"
    
    -- Set player position
    self.player.x = 300
    self.player.y = 400
    
    -- Define walkable area
    self.walkableArea = {
        100, 300,  -- top left
        900, 300,  -- top right
        900, 600,  -- bottom right
        100, 600   -- bottom left
    }
    
    -- Load background
    self:setBackground("assets/myroom.png")
    
    return self
end

return MyRoom
```

### Adding Hotspots

```lua
-- Simple hotspot
local door = Hotspot:new("Door", 400, 200, 100, 150)
door:setInteractionPoint(450, 400)

door:onLook(function(game)
    game.dialogSystem:showMessage("A wooden door.")
end)

door:onUse(function(game)
    game.dialogSystem:showMessage("The door is locked.")
end)

self:addHotspot(door)
```

### Creating Pickable Items

```lua
-- Define item
local keyItem = {
    id = "key",
    name = "Rusty Key",
    description = "An old key",
    stackable = false
}

-- Create item hotspot
local key = ItemHotspot:new(keyItem, 300, 400, 30, 30)
key:setInteractionPoint(300, 450)

self:addHotspot(key)
```

### Item-Based Interactions

```lua
-- Use specific item on hotspot
door:onItemUse("key", function(game)
    game.dialogSystem:showMessage("You unlock the door!")
    game.inventory:removeItem("key")
    game:setFlag("doorUnlocked", true)
end)
```

### Creating NPCs

```lua
local npc = {
    name = "Guard",
    x = 500,
    y = 400,
    width = 40,
    height = 80
}

function npc:draw()
    love.graphics.setColor(0.2, 0.5, 0.8)
    love.graphics.rectangle("fill", self.x - 20, self.y - 80, 40, 80)
    love.graphics.setColor(1, 1, 1)
end

function npc:contains(px, py)
    return px >= self.x - 20 and px <= self.x + 20 and
           py >= self.y - 80 and py <= self.y
end

function npc:interact(verb, game)
    if verb == "talk" then
        game.dialogSystem:showDialog({
            "Halt! Who goes there?",
            {
                text = "I'm just passing through.",
                choices = {
                    {text = "Can I pass?", callback = function()
                        game.dialogSystem:showMessage("Not without a permit!", "Guard")
                    end},
                    {text = "Never mind.", callback = function() end}
                }
            }
        }, "Guard")
    end
end

self:addNPC(npc)
```

### Dialog System

```lua
-- Simple message
game.dialogSystem:showMessage("Hello, world!")

-- With speaker
game.dialogSystem:showMessage("Welcome!", "Narrator")

-- Conversation tree
game.dialogSystem:showDialog({
    "First line of dialog...",
    "Second line...",
    {
        text = "What do you want to do?",
        choices = {
            {text = "Option 1", callback = function()
                -- Handle choice
            end},
            {text = "Option 2", callback = function()
                -- Handle choice
            end}
        }
    }
}, "NPC Name")
```

### Using Game Flags

```lua
-- Set a flag
game:setFlag("metGuard", true)

-- Check a flag
if game:hasFlag("metGuard") then
    -- Do something
end

-- Get flag value
local value = game:getFlag("puzzleSolved")
```

## Depth Sorting System

The engine includes automatic depth sorting that allows characters to walk behind and in front of objects naturally, creating a 3D-like effect.

### Quick Example

```lua
-- Create a table the player can walk around
local tableCanvas = love.graphics.newCanvas(200, 150)
love.graphics.setCanvas(tableCanvas)
love.graphics.clear(0, 0, 0, 0)  -- Transparent background

-- Draw table
love.graphics.setColor(0.6, 0.4, 0.2)
love.graphics.rectangle("fill", 0, 0, 200, 100)
love.graphics.rectangle("fill", 10, 100, 30, 50)   -- Left leg
love.graphics.rectangle("fill", 160, 100, 30, 50)  -- Right leg

love.graphics.setCanvas()
love.graphics.setColor(1, 1, 1)

-- Create scene object with depth sorting
local table = SceneObject:new("Table", 500, 500)
table:setSpriteImage(tableCanvas)
table:setOrigin(0.5, 1)        -- Center-bottom origin
table:setBaseline(500)          -- Bottom Y for depth sorting
table:setLayer("middle")        -- Participates in depth sorting

scene:addObject(table)
```

### How It Works

- Objects, NPCs, and the player are sorted by their **baseline** Y position
- Lower Y = further back (drawn first)
- Higher Y = closer to front (drawn later/on top)
- When player walks above object (lower Y), they appear behind it
- When player walks below object (higher Y), they appear in front

### Layers

- **background**: Always behind everything (walls, distant scenery)
- **middle**: Participates in depth sorting (default)
- **foreground**: Always on top (overhangs, ceiling elements)

### See Full Documentation

For complete documentation, examples, and API reference, see:
- **[DEPTH_SORTING.md](DEPTH_SORTING.md)** - Complete depth sorting guide
- **[examples/depth_sorting_example.lua](examples/depth_sorting_example.lua)** - Working example scene

## Project Structure

```
love2d-adventure/
├── main.lua                      # Entry point
├── conf.lua                      # LÖVE configuration
├── README.md                     # This file
├── DEPTH_SORTING.md              # Depth sorting documentation
├── engine/                       # Core engine modules
│   ├── game.lua                 # Main game engine
│   ├── scene.lua                # Scene/room system
│   ├── sceneobject.lua          # Depth-sorted objects
│   ├── inventory.lua            # Inventory management
│   ├── dialog.lua               # Dialog system
│   ├── cursor.lua               # Cursor and verbs
│   ├── hotspot.lua              # Clickable areas
│   ├── pathfinding.lua          # A* pathfinding
│   └── interaction.lua          # Item combinations
├── scenes/                      # Game scenes/rooms
│   └── room1.lua                # Example room with depth sorting
├── examples/                    # Example scenes
│   └── depth_sorting_example.lua # Depth sorting demo
└── assets/                      # Images, sounds, etc.
```

## Example Scene

The engine includes a complete example scene (`scenes/room1.lua`) demonstrating:

- Multiple hotspots with different interaction types
- Pickable items (note, book, key)
- Item-based puzzle (finding key behind painting)
- NPC with conversation system
- Door that requires a key to unlock
- Walkable areas
- Debug visualization

### Try This in the Demo

1. **Right-click** to cycle through verbs
2. **Look** at everything to explore
3. **Take** the note from the table
4. Read the hint in the dialog
5. **Use** the painting to reveal the hidden key
6. **Take** the key
7. **Use** the key on the door to unlock it
8. **Talk** to the mysterious figure

## Extending the Engine

### Adding New Verbs

Edit `engine/cursor.lua`:

```lua
self.verbs = {
    "walk",
    "look",
    "use",
    "talk",
    "take",
    "push",  -- Add new verb
    "pull"   -- Add new verb
}
```

Add corresponding interaction handlers in hotspots:

```lua
hotspot:onPush(function(game)
    -- Handle push action
end)
```

### Creating Custom Hotspot Shapes

```lua
-- Circle hotspot
local hotspot = Hotspot:new("Object", 400, 300, 50, 50)
hotspot:setShape("circle", 50) -- radius 50

-- Polygon hotspot
local hotspot = Hotspot:new("Object", 0, 0, 0, 0)
hotspot:setShape("polygon", {
    300, 200,
    400, 250,
    350, 350,
    250, 300
})
```

### Item Combination System

```lua
-- In your scene initialization
local interactionMgr = InteractionManager:new()

-- Add recipe
interactionMgr:addRecipe(
    "rope",           -- item 1
    "hook",           -- item 2
    {                 -- result item
        id = "grapplinghook",
        name = "Grappling Hook",
        stackable = false
    },
    "You combine the rope and hook to make a grappling hook!"
)
```

## Tips for Game Development

1. **Use Flags Liberally**: Track game state with flags to make puzzles and interactions conditional
2. **Set Interaction Points**: Always set logical interaction points for hotspots so the character walks to appropriate locations
3. **Test with Debug Mode**: Hold 'D' to visualize hotspots and walkable areas
4. **Write Clear Descriptions**: Good descriptions enhance the player experience
5. **Design Logical Puzzles**: Make sure puzzles have clear hints and logical solutions
6. **Use Dialog Trees**: Create branching conversations for interesting NPC interactions

## Performance Notes

- The engine is optimized for 1024x768 resolution
- Hotspot checks are O(n) - keep the number of hotspots reasonable per scene
- Background images are cached
- Consider using sprite atlases for animated characters

## Credits

Built with [LÖVE2D](https://love2d.org/) - Free 2D Game Engine

## License

This engine is provided as-is for learning and game development purposes. Feel free to modify and use it in your projects!

## Troubleshooting

### Game won't start
- Make sure you have LÖVE2D 11.5 installed
- Check that all files are in the correct directory structure

### Hotspots not clickable
- Enable debug mode (hold D) to visualize hotspot areas
- Check that hotspot coordinates match your background
- Ensure hotspot is enabled

### Character won't move
- Check that walkable area is defined
- Ensure target point is within walkable area
- Enable debug mode to see the path

### Items not appearing in inventory
- Verify item has a unique `id` field
- Check that `addItem` is called correctly
- Make sure the item hotspot's take callback is set up

## Future Enhancements

Possible additions to the engine:

- Save/load system
- Sound effects and music integration
- Animated sprites and characters
- Camera system for larger scenes
- Transition effects between scenes
- More sophisticated pathfinding with obstacles
- Parallax backgrounds
- Controller support

Happy adventuring! 🎮
