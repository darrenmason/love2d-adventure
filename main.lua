-- Point-and-Click Adventure Game Engine
-- Built with LÖVE2D

-- Require all engine modules
require("engine.cursor")
require("engine.inventory")
require("engine.dialog")
require("engine.hotspot")
require("engine.interaction")
require("engine.pathfinding")
require("engine.scene")
require("engine.game")

-- Global game state
Game = nil

function love.load()
    -- Initialize the game engine
    Game = GameEngine:new()
    
    -- Set up graphics
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(0, 0, 0)
    
    -- Load the first scene
    Game:loadScene("scenes.room1")
end

function love.update(dt)
    if Game then
        Game:update(dt)
    end
end

function love.draw()
    if Game then
        Game:draw()
    end
end

function love.mousepressed(x, y, button)
    if Game then
        Game:mousepressed(x, y, button)
    end
end

function love.mousemoved(x, y, dx, dy)
    if Game then
        Game:mousemoved(x, y)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if Game then
        Game:keypressed(key)
    end
end
