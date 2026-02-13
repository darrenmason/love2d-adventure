-- Scene/Room System
Scene = {}
Scene.__index = Scene

function Scene:new(game)
    local self = setmetatable({}, Scene)
    
    self.game = game
    self.name = "Untitled Scene"
    self.background = nil
    self.hotspots = {}
    self.walkableArea = nil
    self.walkSpeed = 200 -- pixels per second
    
    -- Player character
    self.player = {
        x = 400,
        y = 400,
        targetX = nil,
        targetY = nil,
        path = nil,
        pathIndex = 1,
        sprite = nil,
        facingLeft = false
    }
    
    -- NPCs in the scene
    self.npcs = {}
    
    return self
end

function Scene:setBackground(imagePath)
    self.background = love.graphics.newImage(imagePath)
end

function Scene:setWalkableArea(polygon)
    -- Define the walkable area as a polygon
    self.walkableArea = polygon
end

function Scene:addHotspot(hotspot)
    table.insert(self.hotspots, hotspot)
end

function Scene:addNPC(npc)
    table.insert(self.npcs, npc)
end

function Scene:update(dt)
    -- Update player movement
    if self.player.path and #self.player.path > 0 then
        local target = self.player.path[self.player.pathIndex]
        
        if target then
            local dx = target.x - self.player.x
            local dy = target.y - self.player.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < 5 then
                -- Reached waypoint, move to next
                self.player.pathIndex = self.player.pathIndex + 1
                
                if self.player.pathIndex > #self.player.path then
                    -- Reached destination
                    self.player.path = nil
                    self.player.pathIndex = 1
                    
                    -- Execute any pending action
                    if self.player.pendingAction then
                        self.player.pendingAction()
                        self.player.pendingAction = nil
                    end
                end
            else
                -- Move towards waypoint
                local vx = (dx / distance) * self.walkSpeed * dt
                local vy = (dy / distance) * self.walkSpeed * dt
                
                self.player.x = self.player.x + vx
                self.player.y = self.player.y + vy
                
                -- Update facing direction
                self.player.facingLeft = dx < 0
            end
        end
    end
    
    -- Update NPCs
    for _, npc in ipairs(self.npcs) do
        if npc.update then
            npc:update(dt)
        end
    end
end

function Scene:draw()
    -- Draw background
    if self.background then
        love.graphics.draw(self.background, 0, 0)
    end
    
    -- Draw walkable area (debug)
    if self.walkableArea and love.keyboard.isDown("d") then
        love.graphics.setColor(0, 1, 0, 0.3)
        love.graphics.polygon("fill", self.walkableArea)
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Draw hotspots (debug)
    if love.keyboard.isDown("d") then
        for _, hotspot in ipairs(self.hotspots) do
            hotspot:drawDebug()
        end
    end
    
    -- Draw NPCs
    for _, npc in ipairs(self.npcs) do
        if npc.draw then
            npc:draw()
        end
    end
    
    -- Draw player
    self:drawPlayer()
end

function Scene:drawPlayer()
    love.graphics.setColor(1, 1, 1)
    
    if self.player.sprite then
        local scaleX = self.player.facingLeft and -1 or 1
        love.graphics.draw(
            self.player.sprite,
            self.player.x,
            self.player.y,
            0,
            scaleX,
            1,
            self.player.sprite:getWidth() / 2,
            self.player.sprite:getHeight()
        )
    else
        -- Draw simple placeholder
        love.graphics.circle("fill", self.player.x, self.player.y, 10)
        
        -- Draw direction indicator
        local dirX = self.player.facingLeft and -15 or 15
        love.graphics.line(self.player.x, self.player.y, self.player.x + dirX, self.player.y)
    end
    
    -- Draw path (debug)
    if self.player.path and love.keyboard.isDown("d") then
        love.graphics.setColor(1, 0, 0, 0.5)
        for i, point in ipairs(self.player.path) do
            love.graphics.circle("fill", point.x, point.y, 3)
            if i > 1 then
                local prev = self.player.path[i - 1]
                love.graphics.line(prev.x, prev.y, point.x, point.y)
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
end

function Scene:handleClick(x, y)
    local cursor = self.game.cursor
    local verb = cursor:getCurrentVerb()
    
    -- Check hotspots
    for _, hotspot in ipairs(self.hotspots) do
        if hotspot:contains(x, y) then
            hotspot:interact(verb, self.game)
            return
        end
    end
    
    -- Check NPCs
    for _, npc in ipairs(self.npcs) do
        if npc.contains and npc:contains(x, y) then
            if npc.interact then
                npc:interact(verb, self.game)
            end
            return
        end
    end
    
    -- Walk to position
    if verb == "walk" or verb == "none" then
        self:walkTo(x, y)
    end
end

function Scene:handleMouseMove(x, y)
    local cursor = self.game.cursor
    
    -- Check if hovering over hotspot
    local hoveredHotspot = nil
    for _, hotspot in ipairs(self.hotspots) do
        if hotspot:contains(x, y) then
            hoveredHotspot = hotspot
            break
        end
    end
    
    -- Check NPCs
    if not hoveredHotspot then
        for _, npc in ipairs(self.npcs) do
            if npc.contains and npc:contains(x, y) then
                cursor:setHoverText(npc.name or "Character")
                return
            end
        end
    end
    
    if hoveredHotspot then
        cursor:setHoverText(hoveredHotspot.name)
    else
        cursor:setHoverText(nil)
    end
end

function Scene:walkTo(x, y, callback)
    -- Find path to target
    if self.walkableArea then
        -- Simple direct path for now
        self.player.path = {{x = x, y = y}}
        self.player.pathIndex = 1
        self.player.pendingAction = callback
    else
        -- No walkable area defined, just teleport
        self.player.x = x
        self.player.y = y
        if callback then
            callback()
        end
    end
end

function Scene:walkToHotspot(hotspot, callback)
    local x, y = hotspot:getInteractionPoint()
    self:walkTo(x, y, callback)
end

function Scene:onEnter()
    -- Override in specific scenes
end

function Scene:onExit()
    -- Override in specific scenes
end
