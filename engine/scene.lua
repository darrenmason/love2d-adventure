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
        facingLeft = false,
        baseline = nil  -- If nil, uses player.y for depth sorting
    }
    
    -- NPCs in the scene
    self.npcs = {}
    
    -- Scene objects (props, furniture with depth sorting)
    self.objects = {}
    
    -- Depth sorting enabled by default
    self.depthSortingEnabled = true
    
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

function Scene:addObject(object)
    -- Add a scene object (for depth sorting)
    table.insert(self.objects, object)
end

function Scene:setDepthSorting(enabled)
    self.depthSortingEnabled = enabled
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
                
                -- Calculate new position
                local newX = self.player.x + vx
                local newY = self.player.y + vy
                
                -- Check collision at new position
                if not self:checkCollisionAtPoint(newX, newY, 10) then
                    self.player.x = newX
                    self.player.y = newY
                else
                    -- Hit an obstacle, stop movement
                    self.player.path = nil
                    self.player.pathIndex = 1
                end
                
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
    
    -- Depth sorting: Draw objects, NPCs, and player in correct order
    if self.depthSortingEnabled then
        self:drawWithDepthSorting()
    else
        -- Legacy rendering (no depth sorting)
        self:drawObjectsLayer("background")
        self:drawObjectsLayer("middle")
        
        for _, npc in ipairs(self.npcs) do
            if npc.draw then
                npc:draw()
            end
        end
        
        self:drawPlayer()
        self:drawObjectsLayer("foreground")
    end
end

function Scene:drawObjectsLayer(layer)
    -- Draw objects of a specific layer (without depth sorting)
    for _, obj in ipairs(self.objects) do
        if obj.layer == layer then
            obj:draw()
        end
    end
end

function Scene:drawWithDepthSorting()
    -- Gather all entities that need depth sorting
    local entities = {}
    
    -- Add background layer objects (always behind everything)
    for _, obj in ipairs(self.objects) do
        if obj.layer == "background" then
            table.insert(entities, {
                type = "object",
                data = obj,
                depth = -999999  -- Always behind
            })
        end
    end
    
    -- Add middle layer objects (depth sorted)
    for _, obj in ipairs(self.objects) do
        if obj.layer == "middle" then
            table.insert(entities, {
                type = "object",
                data = obj,
                depth = obj:getDepthValue()
            })
        end
    end
    
    -- Add NPCs
    for _, npc in ipairs(self.npcs) do
        local depth = npc.baseline or npc.y
        table.insert(entities, {
            type = "npc",
            data = npc,
            depth = depth
        })
    end
    
    -- Add player
    local playerDepth = self.player.baseline or self.player.y
    table.insert(entities, {
        type = "player",
        data = self.player,
        depth = playerDepth
    })
    
    -- Add foreground layer objects (always on top)
    for _, obj in ipairs(self.objects) do
        if obj.layer == "foreground" then
            table.insert(entities, {
                type = "object",
                data = obj,
                depth = 999999  -- Always on top
            })
        end
    end
    
    -- Sort by depth (lower depth = drawn first = behind)
    table.sort(entities, function(a, b)
        return a.depth < b.depth
    end)
    
    -- Draw all entities in sorted order
    for _, entity in ipairs(entities) do
        if entity.type == "object" then
            entity.data:draw()
            
            -- Debug
            if love.keyboard.isDown("d") then
                entity.data:drawDebug()
            end
        elseif entity.type == "npc" then
            if entity.data.draw then
                entity.data:draw()
            end
        elseif entity.type == "player" then
            self:drawPlayer()
        end
    end
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
    -- Check if destination collides with any object
    if self:checkCollisionAtPoint(x, y, 10) then
        -- Find nearest non-colliding point
        x, y = self:findNearestWalkablePoint(x, y)
    end
    
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

function Scene:checkCollisionAtPoint(x, y, radius)
    -- Check if a point (with radius) collides with any scene object
    radius = radius or 0
    
    for _, obj in ipairs(self.objects) do
        if obj:checkCollision(x, y, radius) then
            return true, obj
        end
    end
    
    return false, nil
end

function Scene:findNearestWalkablePoint(x, y, searchRadius)
    -- Find nearest point that doesn't collide with objects
    searchRadius = searchRadius or 50
    local bestX, bestY = x, y
    local bestDist = math.huge
    
    -- Try points in a spiral pattern
    local angles = 16
    local rings = 5
    
    for ring = 1, rings do
        local r = (ring / rings) * searchRadius
        
        for i = 0, angles - 1 do
            local angle = (i / angles) * math.pi * 2
            local testX = x + math.cos(angle) * r
            local testY = y + math.sin(angle) * r
            
            if not self:checkCollisionAtPoint(testX, testY, 10) then
                local dist = math.sqrt((testX - x) * (testX - x) + (testY - y) * (testY - y))
                if dist < bestDist then
                    bestDist = dist
                    bestX, bestY = testX, testY
                end
            end
        end
        
        -- If we found a valid point, return it
        if bestDist < math.huge then
            return bestX, bestY
        end
    end
    
    -- Fallback: return original point
    return x, y
end

function Scene:getCollidingObjects(x, y, radius)
    -- Get all objects that collide at this point
    radius = radius or 0
    local colliding = {}
    
    for _, obj in ipairs(self.objects) do
        if obj:checkCollision(x, y, radius) then
            table.insert(colliding, obj)
        end
    end
    
    return colliding
end

function Scene:onEnter()
    -- Override in specific scenes
end

function Scene:onExit()
    -- Override in specific scenes
end
