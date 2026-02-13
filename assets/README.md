# Assets Directory

Place your game assets in this directory:

- **images/** - Background images, sprites, icons
- **sounds/** - Sound effects
- **music/** - Background music tracks
- **fonts/** - Custom fonts

The engine currently generates a simple background programmatically in the example scene, but you can replace it by adding your own images and using:

```lua
self:setBackground("assets/images/myroom.png")
```

## Recommended Asset Specifications

- **Background Images**: 1024x768 pixels
- **Character Sprites**: ~40-60 pixels width
- **Item Icons**: 32x32 or 45x45 pixels
- **Audio**: OGG format recommended for music, WAV for short sound effects
