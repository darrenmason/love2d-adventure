# Quick Start Guide

## Installation

1. **Install LÖVE2D** (if not already installed):
   - **Ubuntu/Debian**: `sudo apt install love`
   - **Arch Linux**: `sudo pacman -S love`
   - **macOS**: `brew install love` or download from https://love2d.org/
   - **Windows**: Download installer from https://love2d.org/

2. **Run the game**:
   ```bash
   ./run.sh
   ```
   
   Or directly with LÖVE:
   ```bash
   love .
   ```

## First Time Playing

When you start the game, you'll be in a mysterious room. Here's what to do:

### Controls
- **Left Click**: Interact with objects using the current verb
- **Right Click**: Change verbs (Walk → Look → Use → Talk → Take)
- **Hold D**: Show debug overlay (useful for development)
- **ESC**: Quit

### Tutorial Walkthrough

1. **Look around**: Right-click until "LOOK" is selected, then click on various objects
2. **Take the note**: Right-click to "TAKE", click the note on the table
3. **Read the hint**: The note tells you "The key is behind the painting"
4. **Find the painting**: Use "LOOK" to examine the painting on the wall
5. **Move the painting**: Use "USE" on the painting to reveal the key
6. **Take the key**: Switch to "TAKE" and click the key
7. **Unlock the door**: Use "USE" on the door with the key in inventory
8. **Talk to the NPC**: Try "TALK" on the mysterious figure

### Tips
- Try different verbs on different objects
- Check your inventory (bottom of screen)
- Items in inventory can be selected and used on objects
- Pay attention to dialog - it often contains hints

## Development Mode

Press and hold **D** to see:
- Hotspot boundaries (red boxes)
- Walkable areas (green overlay)
- Character paths (red dots and lines)
- Interaction points (green dots)

This is useful when creating your own scenes!

## Next Steps

1. Read the full `README.md` for detailed documentation
2. Explore `scenes/room1.lua` to see how the example is built
3. Create your own scenes by copying and modifying `room1.lua`
4. Add your own assets to the `assets/` directory

## Troubleshooting

**Game won't start?**
- Make sure LÖVE2D 11.5 or higher is installed
- Check that you're running from the correct directory

**Nothing is clickable?**
- Hold D to see hotspot areas
- Make sure you're using the right verb for each action

**Character won't move?**
- The walkable area is defined - you can only click within it
- Hold D to see the walkable area in green

## Creating Your First Scene

1. Copy `scenes/room1.lua` to `scenes/myroom.lua`
2. Modify the room name, background, and hotspots
3. In `main.lua`, change the scene load:
   ```lua
   Game:loadScene("scenes.myroom")
   ```
4. Run and test!

Have fun creating your adventure! 🎮
