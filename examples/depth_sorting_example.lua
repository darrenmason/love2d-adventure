-- Example: Using Depth Sorting in Your Scene
-- This shows how to create a scene with objects that characters can walk around

local DepthExample = {}
setmetatable(DepthExample, {__index = Scene})

function DepthExample:new(game)
    local self = Scene:new(game)
    setmetatable(self, {__index = DepthExample})
    
    self.name = "Depth Sorting Demo"
    
    -- Player starting position
    self.player.x = 300
    self.player.y = 500
    
    -- Walkable area
    self.walkableArea = {
        100, 300,
        900, 300,
        900, 600,
        100, 600
    }
    
    -- Create scene
    self:createSimpleBackground()
    self:createDepthSortedObjects()
    
    return self
end

function DepthExample:createSimpleBackground()
    local canvas = love.graphics.newCanvas(1024, 768)
    love.graphics.setCanvas(canvas)
    
    -- Floor
    love.graphics.setColor(0.4, 0.5, 0.3)
    love.graphics.rectangle("fill", 0, 0, 1024, 768)
    
    -- Back wall
    love.graphics.setColor(0.5, 0.4, 0.3)
    love.graphics.rectangle("fill", 0, 0, 1024, 300)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    self.background = canvas
end

function DepthExample:createDepthSortedObjects()
    -- Example 1: A table the player can walk around
    -- Create table with transparent background
    local tableCanvas = love.graphics.newCanvas(180, 120)
    love.graphics.setCanvas(tableCanvas)
    love.graphics.clear(0, 0, 0, 0)  -- IMPORTANT: Transparent background
    
    -- Table top with shadow
    love.graphics.setColor(0.4, 0.25, 0.15)
    love.graphics.ellipse("fill", 90, 30, 85, 25)
    love.graphics.setColor(0.5, 0.3, 0.2)
    love.graphics.ellipse("fill", 90, 28, 85, 25)
    
    -- Table legs
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.rectangle("fill", 20, 30, 15, 90)
    love.graphics.rectangle("fill", 145, 30, 15, 90)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    -- Create the SceneObject
    local table = SceneObject:new("Round Table", 400, 450)
    table:setSpriteImage(tableCanvas)
    table:setOrigin(0.5, 1)          -- Center-bottom origin (important!)
    table:setBaseline(450)            -- Bottom of table legs
    table:setLayer("middle")          -- Participates in depth sorting
    
    self:addObject(table)
    
    -- Example 2: A barrel (closer to camera)
    local barrelCanvas = love.graphics.newCanvas(60, 80)
    love.graphics.setCanvas(barrelCanvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- Barrel body
    love.graphics.setColor(0.5, 0.3, 0.2)
    love.graphics.ellipse("fill", 30, 10, 28, 10)
    love.graphics.rectangle("fill", 2, 10, 56, 60)
    love.graphics.ellipse("fill", 30, 70, 28, 10)
    
    -- Barrel bands
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.rectangle("fill", 2, 25, 56, 5)
    love.graphics.rectangle("fill", 2, 50, 56, 5)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local barrel = SceneObject:new("Barrel", 600, 520)
    barrel:setSpriteImage(barrelCanvas)
    barrel:setOrigin(0.5, 1)
    barrel:setBaseline(520)
    barrel:setLayer("middle")
    
    self:addObject(barrel)
    
    -- Example 3: A plant (far from camera)
    local plantCanvas = love.graphics.newCanvas(80, 120)
    love.graphics.setCanvas(plantCanvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- Pot
    love.graphics.setColor(0.6, 0.35, 0.2)
    love.graphics.polygon("fill", 25, 90, 55, 90, 60, 120, 20, 120)
    
    -- Plant leaves
    love.graphics.setColor(0.2, 0.6, 0.3)
    for i = 1, 8 do
        local angle = (i / 8) * math.pi * 2
        local x = 40 + math.cos(angle) * 20
        local y = 50 + math.sin(angle) * 15
        love.graphics.circle("fill", x, y, 12)
    end
    
    -- Center
    love.graphics.setColor(0.3, 0.7, 0.4)
    love.graphics.circle("fill", 40, 50, 15)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local plant = SceneObject:new("Plant", 250, 380)
    plant:setSpriteImage(plantCanvas)
    plant:setOrigin(0.5, 1)
    plant:setBaseline(380)
    plant:setLayer("middle")
    
    self:addObject(plant)
    
    -- Example 4: Using a custom draw callback
    local customObject = SceneObject:new("Glowing Orb", 700, 400)
    customObject:setBaseline(400)
    customObject:setLayer("middle")
    
    local time = 0
    customObject:setDrawCallback(function(self)
        -- Animated glowing effect
        time = time + 0.05
        local pulse = math.sin(time) * 0.3 + 0.7
        
        -- Glow
        love.graphics.setColor(0.5, 0.3, 1, 0.3 * pulse)
        love.graphics.circle("fill", self.x, self.y - 40, 40 * pulse)
        
        -- Core
        love.graphics.setColor(0.8, 0.6, 1)
        love.graphics.circle("fill", self.x, self.y - 40, 20)
        
        love.graphics.setColor(1, 1, 1)
    end)
    
    self:addObject(customObject)
    
    -- Example 5: Foreground layer (always on top)
    local overheadSign = SceneObject:new("Sign", 512, 250)
    overheadSign:setLayer("foreground")  -- Always drawn on top
    
    overheadSign:setDrawCallback(function(self)
        love.graphics.setColor(0.6, 0.5, 0.3)
        love.graphics.rectangle("fill", self.x - 100, self.y, 200, 40)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Walk around the objects!", self.x - 90, self.y + 12)
        love.graphics.setColor(1, 1, 1)
    end)
    
    self:addObject(overheadSign)
    
    -- Add hotspots for interactions
    self:createHotspots()
end

function DepthExample:createHotspots()
    -- Add a hotspot for the table
    local tableHotspot = Hotspot:new("Round Table", 310, 360, 180, 90)
    tableHotspot:setInteractionPoint(400, 460)
    tableHotspot:onLook(function(game)
        game.dialogSystem:showMessage("A round wooden table. Notice how you can walk behind and in front of it!")
    end)
    tableHotspot:onUse(function(game)
        game.dialogSystem:showMessage("It's a sturdy table. Try walking around it to see the depth sorting in action.")
    end)
    self:addHotspot(tableHotspot)
    
    -- Add hotspot for barrel
    local barrelHotspot = Hotspot:new("Barrel", 570, 440, 60, 80)
    barrelHotspot:setInteractionPoint(600, 530)
    barrelHotspot:onLook(function(game)
        game.dialogSystem:showMessage("An old wooden barrel. Walk above and below it to see the sorting!")
    end)
    self:addHotspot(barrelHotspot)
end

function DepthExample:onEnter()
    print("Entered Depth Sorting Example")
    print("Press and hold 'D' to see debug visualization!")
    print("Walk around the objects to see depth sorting in action.")
    
    -- Show tutorial message
    self.game.dialogSystem:showMessage(
        "Welcome to the Depth Sorting Demo!\n\n" ..
        "Walk around the objects with left-click.\n" ..
        "Hold 'D' to see debug info.\n" ..
        "Right-click to cycle verbs."
    )
end

return DepthExample
