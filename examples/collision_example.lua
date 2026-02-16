-- Example: Collision Masks
-- This demonstrates different types of collision masks for scene objects

local CollisionExample = {}
setmetatable(CollisionExample, {__index = Scene})

function CollisionExample:new(game)
    local self = Scene:new(game)
    setmetatable(self, {__index = CollisionExample})
    
    self.name = "Collision Demo"
    
    -- Player starting position
    self.player.x = 300
    self.player.y = 550
    
    -- Walkable area
    self.walkableArea = {
        50, 300,
        974, 300,
        974, 650,
        50, 650
    }
    
    -- Create scene
    self:createBackground()
    self:createCollidableObjects()
    
    return self
end

function CollisionExample:createBackground()
    local canvas = love.graphics.newCanvas(1024, 768)
    love.graphics.setCanvas(canvas)
    
    -- Floor (checkerboard pattern)
    for y = 0, 15 do
        for x = 0, 20 do
            if (x + y) % 2 == 0 then
                love.graphics.setColor(0.4, 0.5, 0.3)
            else
                love.graphics.setColor(0.35, 0.45, 0.25)
            end
            love.graphics.rectangle("fill", x * 50, y * 50 + 300, 50, 50)
        end
    end
    
    -- Back wall
    love.graphics.setColor(0.5, 0.4, 0.3)
    love.graphics.rectangle("fill", 0, 0, 1024, 300)
    
    -- Title on wall
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.print("COLLISION DEMO - Hold 'D' to see collision masks (red)", 250, 20, 0, 1.2, 1.2)
    love.graphics.print("Try walking around the objects!", 340, 50, 0, 1, 1)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    self.background = canvas
end

function CollisionExample:createCollidableObjects()
    -- Example 1: Simple solid box (rectangle collision)
    local boxCanvas = love.graphics.newCanvas(80, 80)
    love.graphics.setCanvas(boxCanvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- Draw crate
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.rectangle("fill", 0, 0, 80, 80)
    love.graphics.setColor(0.4, 0.3, 0.15)
    love.graphics.rectangle("line", 10, 10, 60, 60)
    love.graphics.line(10, 10, 70, 70)
    love.graphics.line(70, 10, 10, 70)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local crate = SceneObject:new("Solid Crate", 150, 450)
    crate:setSpriteImage(boxCanvas)
    crate:setOrigin(0.5, 1)
    crate:setBaseline(450)
    crate:setLayer("middle")
    
    -- Add solid rectangular collision (entire box is solid)
    crate:addCollisionRectangle(110, 370, 80, 80)
    
    self:addObject(crate)
    
    -- Example 2: Round barrel (circle collision)
    local barrelCanvas = love.graphics.newCanvas(70, 90)
    love.graphics.setCanvas(barrelCanvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- Barrel body
    love.graphics.setColor(0.5, 0.3, 0.2)
    love.graphics.ellipse("fill", 35, 15, 33, 12)
    love.graphics.rectangle("fill", 2, 15, 66, 60)
    love.graphics.ellipse("fill", 35, 75, 33, 12)
    
    -- Barrel bands
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.rectangle("fill", 2, 30, 66, 6)
    love.graphics.rectangle("fill", 2, 55, 66, 6)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local barrel = SceneObject:new("Round Barrel", 300, 480)
    barrel:setSpriteImage(barrelCanvas)
    barrel:setOrigin(0.5, 1)
    barrel:setBaseline(480)
    barrel:setLayer("middle")
    
    -- Add circular collision (round objects)
    barrel:addCollisionCircle(300, 445, 35)
    
    self:addObject(barrel)
    
    -- Example 3: Table with leg collision (complex shape)
    local tableCanvas = love.graphics.newCanvas(220, 140)
    love.graphics.setCanvas(tableCanvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- Table top
    love.graphics.setColor(0.4, 0.25, 0.15)
    love.graphics.ellipse("fill", 110, 35, 105, 30)
    love.graphics.setColor(0.5, 0.3, 0.2)
    love.graphics.ellipse("fill", 110, 32, 105, 30)
    
    -- Table legs
    love.graphics.setColor(0.35, 0.22, 0.12)
    love.graphics.rectangle("fill", 25, 32, 22, 108)
    love.graphics.rectangle("fill", 173, 32, 22, 108)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local table = SceneObject:new("Table with Legs", 520, 520)
    table:setSpriteImage(tableCanvas)
    table:setOrigin(0.5, 1)
    table:setBaseline(520)
    table:setLayer("middle")
    
    -- Add collision ONLY for the legs (not the top!)
    -- Left leg
    table:addCollisionRectangle(435, 412, 22, 108)
    -- Right leg
    table:addCollisionRectangle(583, 412, 22, 108)
    -- Player can walk "under" the table top but not through legs!
    
    self:addObject(table)
    
    -- Example 4: Polygon collision (irregular shape)
    local rockCanvas = love.graphics.newCanvas(100, 80)
    love.graphics.setCanvas(rockCanvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- Draw irregular rock
    local rockPoints = {30, 20, 70, 15, 90, 40, 85, 65, 50, 75, 15, 70, 10, 40}
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.polygon("fill", rockPoints)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.polygon("line", rockPoints)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local rock = SceneObject:new("Irregular Rock", 750, 450)
    rock:setSpriteImage(rockCanvas)
    rock:setOrigin(0.5, 1)
    rock:setBaseline(450)
    rock:setLayer("middle")
    
    -- Add polygon collision matching the rock shape
    -- Offset points to world coordinates
    local worldRockPoints = {}
    for i = 1, #rockPoints, 2 do
        table.insert(worldRockPoints, rockPoints[i] + 700)
        table.insert(worldRockPoints, rockPoints[i + 1] + 370)
    end
    rock:addCollisionPolygon(worldRockPoints)
    
    self:addObject(rock)
    
    -- Example 5: Multiple collision masks (complex object)
    local benchCanvas = love.graphics.newCanvas(180, 70)
    love.graphics.setCanvas(benchCanvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- Bench seat
    love.graphics.setColor(0.5, 0.35, 0.2)
    love.graphics.rectangle("fill", 10, 20, 160, 25)
    
    -- Bench legs
    love.graphics.setColor(0.4, 0.25, 0.15)
    love.graphics.rectangle("fill", 15, 45, 15, 25)
    love.graphics.rectangle("fill", 150, 45, 15, 25)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local bench = SceneObject:new("Bench (Multi-Mask)", 200, 600)
    bench:setSpriteImage(benchCanvas)
    bench:setOrigin(0.5, 1)
    bench:setBaseline(600)
    bench:setLayer("middle")
    
    -- Add multiple collision masks (one for each leg)
    bench:addCollisionRectangle(155, 575, 15, 25)  -- Left leg
    bench:addCollisionRectangle(340, 575, 15, 25)  -- Right leg
    -- No collision for the seat! Player can walk "under" it
    
    self:addObject(bench)
    
    -- Example 6: Decorative object (NO collision)
    local flowerCanvas = love.graphics.newCanvas(40, 60)
    love.graphics.setCanvas(flowerCanvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- Flower
    love.graphics.setColor(1, 0.3, 0.5)
    for i = 1, 6 do
        local angle = (i / 6) * math.pi * 2
        local x = 20 + math.cos(angle) * 8
        local y = 15 + math.sin(angle) * 8
        love.graphics.circle("fill", x, y, 5)
    end
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.circle("fill", 20, 15, 4)
    
    -- Stem
    love.graphics.setColor(0.2, 0.6, 0.2)
    love.graphics.rectangle("fill", 18, 15, 4, 45)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local flower = SceneObject:new("Flower (No Collision)", 880, 530)
    flower:setSpriteImage(flowerCanvas)
    flower:setOrigin(0.5, 1)
    flower:setBaseline(530)
    flower:setLayer("middle")
    
    -- NO collision added - this is purely decorative
    -- Player can walk right through it
    
    self:addObject(flower)
    
    -- Add labels to help identify collision types
    self:addLabels()
end

function CollisionExample:addLabels()
    -- Add floating labels above objects
    local function createLabel(text, x, y)
        local label = SceneObject:new(text, x, y)
        label:setLayer("foreground")
        label:setDrawCallback(function(self)
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle("fill", self.x - 60, self.y - 20, 120, 18)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(text, self.x - 60, self.y - 17, 120, "center", 0, 0.7, 0.7)
        end)
        return label
    end
    
    self:addObject(createLabel("SOLID BOX", 150, 350))
    self:addObject(createLabel("CIRCLE", 300, 380))
    self:addObject(createLabel("TABLE LEGS", 520, 360))
    self:addObject(createLabel("POLYGON", 750, 350))
    self:addObject(createLabel("MULTI-MASK", 200, 520))
    self:addObject(createLabel("NO COLLISION", 880, 460))
end

function CollisionExample:onEnter()
    print("Entered Collision Example")
    print("Hold 'D' to see collision masks (red areas)")
    
    self.game.dialogSystem:showMessage(
        "Collision Masks Demo!\n\n" ..
        "• Red areas = collision masks\n" ..
        "• Walk around to test collisions\n" ..
        "• Hold 'D' to see all masks\n" ..
        "• Notice: table has leg collision only!"
    )
end

return CollisionExample
