-- Main Game Engine
GameEngine = {}
GameEngine.__index = GameEngine

function GameEngine:new()
    local self = setmetatable({}, GameEngine)
    
    self.currentScene = nil
    self.inventory = Inventory:new()
    self.cursor = Cursor:new()
    self.dialogSystem = DialogSystem:new()
    
    -- Game state
    self.flags = {} -- For storing game progress flags
    self.paused = false
    
    return self
end

function GameEngine:loadScene(scenePath)
    -- Unload current scene if exists
    if self.currentScene then
        if self.currentScene.onExit then
            self.currentScene:onExit()
        end
    end
    
    -- Load new scene
    local sceneModule = require(scenePath)
    self.currentScene = sceneModule:new(self)
    
    if self.currentScene.onEnter then
        self.currentScene:onEnter()
    end
end

function GameEngine:update(dt)
    if self.paused then
        return
    end
    
    if self.currentScene then
        self.currentScene:update(dt)
    end
    
    self.dialogSystem:update(dt)
    self.cursor:update(dt)
end

function GameEngine:draw()
    if self.currentScene then
        self.currentScene:draw()
    end
    
    -- Draw UI elements on top
    self.inventory:draw()
    self.dialogSystem:draw()
    self.cursor:draw()
end

function GameEngine:mousepressed(x, y, button)
    if button == 1 then -- Left click
        -- Check dialog first
        if self.dialogSystem:isActive() then
            self.dialogSystem:handleClick(x, y)
            return
        end
        
        -- Check inventory
        if self.inventory:handleClick(x, y) then
            return
        end
        
        -- Check scene
        if self.currentScene then
            self.currentScene:handleClick(x, y)
        end
    elseif button == 2 then -- Right click
        -- Cycle through verbs or cancel action
        self.cursor:cycleVerb()
    end
end

function GameEngine:mousemoved(x, y)
    self.cursor:setPosition(x, y)
    
    if self.currentScene then
        self.currentScene:handleMouseMove(x, y)
    end
end

function GameEngine:keypressed(key)
    if self.dialogSystem:isActive() then
        self.dialogSystem:handleKey(key)
    end
end

function GameEngine:setFlag(flag, value)
    self.flags[flag] = value
end

function GameEngine:getFlag(flag)
    return self.flags[flag]
end

function GameEngine:hasFlag(flag)
    return self.flags[flag] ~= nil and self.flags[flag] == true
end
