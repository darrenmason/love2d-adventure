-- Scene Object System (for depth-sorted props, furniture, etc.)
-- Objects with sprites that need depth sorting with characters

SceneObject = {}
SceneObject.__index = SceneObject

function SceneObject:new(name, x, y)
    local self = setmetatable({}, SceneObject)
    
    self.name = name
    self.x = x                  -- Position X
    self.y = y                  -- Position Y (used for depth sorting)
    self.baseline = y           -- Y position used for depth sorting (foot/bottom of object)
    
    -- Visual representation
    self.sprite = nil           -- Image/sprite (supports transparency)
    self.originX = 0.5          -- Origin X (0-1, for positioning)
    self.originY = 1            -- Origin Y (0-1, default at bottom for baseline)
    self.scaleX = 1
    self.scaleY = 1
    self.rotation = 0
    
    -- Alternative: draw callback for custom rendering
    self.drawCallback = nil
    
    -- Depth/layer settings
    self.layer = "middle"       -- "background", "middle", "foreground"
    self.depthOffset = 0        -- Manual adjustment to sort order
    
    -- State
    self.visible = true
    self.alpha = 1
    self.color = {1, 1, 1}
    
    -- Optional hotspot reference (for making objects interactive)
    self.hotspot = nil
    
    -- Collision system
    self.hasCollision = false       -- Whether this object blocks movement
    self.collisionMasks = {}        -- Array of collision shapes
    
    return self
end

function SceneObject:setSprite(imagePath)
    -- Load sprite from path
    if type(imagePath) == "string" then
        self.sprite = love.graphics.newImage(imagePath)
    else
        -- Assume it's already a loaded image
        self.sprite = imagePath
    end
    return self
end

function SceneObject:setSpriteImage(image)
    -- Set sprite directly (can be Image or Canvas)
    self.sprite = image
    return self
end

function SceneObject:setOrigin(ox, oy)
    -- Set origin point (0-1 range)
    -- (0.5, 1) = center-bottom (default, for proper baseline)
    -- (0.5, 0.5) = center-center
    self.originX = ox
    self.originY = oy
    return self
end

function SceneObject:setBaseline(y)
    -- Set the Y position for depth sorting
    -- This is typically the bottom/foot of the object
    self.baseline = y
    return self
end

function SceneObject:setScale(sx, sy)
    self.scaleX = sx
    self.scaleY = sy or sx
    return self
end

function SceneObject:setLayer(layer)
    -- Set rendering layer: "background", "middle", "foreground"
    self.layer = layer
    return self
end

function SceneObject:setDepthOffset(offset)
    -- Manual adjustment to sort order (higher = drawn later/on top)
    self.depthOffset = offset
    return self
end

function SceneObject:setDrawCallback(callback)
    -- Custom draw function: callback(self)
    self.drawCallback = callback
    return self
end

function SceneObject:setAlpha(alpha)
    self.alpha = alpha
    return self
end

function SceneObject:setColor(r, g, b)
    self.color = {r, g, b}
    return self
end

function SceneObject:setVisible(visible)
    self.visible = visible
    return self
end

function SceneObject:getDepthValue()
    -- Return the value used for depth sorting
    return self.baseline + self.depthOffset
end

function SceneObject:draw()
    if not self.visible then
        return
    end
    
    -- Use custom draw callback if provided
    if self.drawCallback then
        self.drawCallback(self)
        return
    end
    
    -- Draw sprite if available
    if self.sprite then
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
        
        local originPixelX = self.sprite:getWidth() * self.originX
        local originPixelY = self.sprite:getHeight() * self.originY
        
        love.graphics.draw(
            self.sprite,
            self.x,
            self.y,
            self.rotation,
            self.scaleX,
            self.scaleY,
            originPixelX,
            originPixelY
        )
        
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function SceneObject:drawDebug()
    if not self.visible then
        return
    end
    
    -- Draw baseline position
    love.graphics.setColor(1, 1, 0, 0.8)
    love.graphics.circle("fill", self.x, self.baseline, 4)
    
    -- Draw object bounds (if sprite exists)
    if self.sprite then
        local w = self.sprite:getWidth() * self.scaleX
        local h = self.sprite:getHeight() * self.scaleY
        local ox = w * self.originX
        local oy = h * self.originY
        
        love.graphics.setColor(1, 1, 0, 0.3)
        love.graphics.rectangle("line", self.x - ox, self.y - oy, w, h)
    end
    
    -- Draw collision masks
    if self.hasCollision then
        for _, mask in ipairs(self.collisionMasks) do
            if mask.type == "rectangle" then
                love.graphics.setColor(1, 0, 0, 0.4)
                love.graphics.rectangle("fill", mask.x, mask.y, mask.width, mask.height)
                love.graphics.setColor(1, 0, 0, 0.8)
                love.graphics.rectangle("line", mask.x, mask.y, mask.width, mask.height)
            elseif mask.type == "circle" then
                love.graphics.setColor(1, 0, 0, 0.4)
                love.graphics.circle("fill", mask.x, mask.y, mask.radius)
                love.graphics.setColor(1, 0, 0, 0.8)
                love.graphics.circle("line", mask.x, mask.y, mask.radius)
            elseif mask.type == "polygon" then
                love.graphics.setColor(1, 0, 0, 0.4)
                love.graphics.polygon("fill", mask.points)
                love.graphics.setColor(1, 0, 0, 0.8)
                love.graphics.polygon("line", mask.points)
            end
        end
    end
    
    -- Draw name
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, self.x - 20, self.baseline - 30, 0, 0.6, 0.6)
    
    love.graphics.setColor(1, 1, 1, 1)
end

-- ===========================
-- Collision System
-- ===========================

function SceneObject:enableCollision()
    self.hasCollision = true
    return self
end

function SceneObject:disableCollision()
    self.hasCollision = false
    return self
end

function SceneObject:addCollisionRectangle(x, y, width, height)
    -- Add a rectangular collision mask
    -- x, y is top-left corner
    table.insert(self.collisionMasks, {
        type = "rectangle",
        x = x,
        y = y,
        width = width,
        height = height
    })
    self.hasCollision = true
    return self
end

function SceneObject:addCollisionCircle(x, y, radius)
    -- Add a circular collision mask
    -- x, y is center
    table.insert(self.collisionMasks, {
        type = "circle",
        x = x,
        y = y,
        radius = radius
    })
    self.hasCollision = true
    return self
end

function SceneObject:addCollisionPolygon(points)
    -- Add a polygon collision mask
    -- points = {x1, y1, x2, y2, x3, y3, ...}
    table.insert(self.collisionMasks, {
        type = "polygon",
        points = points
    })
    self.hasCollision = true
    return self
end

function SceneObject:clearCollisionMasks()
    self.collisionMasks = {}
    self.hasCollision = false
    return self
end

function SceneObject:checkCollision(px, py, radius)
    -- Check if a point (with optional radius) collides with this object
    -- radius is optional, for checking if a character (circle) would collide
    radius = radius or 0
    
    if not self.hasCollision or not self.visible then
        return false
    end
    
    for _, mask in ipairs(self.collisionMasks) do
        if mask.type == "rectangle" then
            if self:checkRectangleCollision(px, py, radius, mask) then
                return true
            end
        elseif mask.type == "circle" then
            if self:checkCircleCollision(px, py, radius, mask) then
                return true
            end
        elseif mask.type == "polygon" then
            if self:checkPolygonCollision(px, py, radius, mask) then
                return true
            end
        end
    end
    
    return false
end

function SceneObject:checkRectangleCollision(px, py, radius, rect)
    -- Check collision between point/circle and rectangle
    if radius == 0 then
        -- Simple point-in-rectangle test
        return px >= rect.x and px <= rect.x + rect.width and
               py >= rect.y and py <= rect.y + rect.height
    else
        -- Circle-rectangle collision
        -- Find closest point on rectangle to circle center
        local closestX = math.max(rect.x, math.min(px, rect.x + rect.width))
        local closestY = math.max(rect.y, math.min(py, rect.y + rect.height))
        
        -- Calculate distance between circle center and closest point
        local dx = px - closestX
        local dy = py - closestY
        local distSquared = dx * dx + dy * dy
        
        return distSquared < (radius * radius)
    end
end

function SceneObject:checkCircleCollision(px, py, radius, circle)
    -- Check collision between two circles (or point and circle)
    local dx = px - circle.x
    local dy = py - circle.y
    local distSquared = dx * dx + dy * dy
    local totalRadius = radius + circle.radius
    
    return distSquared < (totalRadius * totalRadius)
end

function SceneObject:checkPolygonCollision(px, py, radius, polygon)
    -- Check collision between point/circle and polygon
    if radius == 0 then
        -- Simple point-in-polygon test
        return self:pointInPolygon(px, py, polygon.points)
    else
        -- Check if point is inside polygon (expanded by radius)
        -- For simplicity, check if circle center is inside or close to edges
        if self:pointInPolygon(px, py, polygon.points) then
            return true
        end
        
        -- Check distance to polygon edges
        local points = polygon.points
        for i = 1, #points - 2, 2 do
            local x1, y1 = points[i], points[i + 1]
            local x2, y2 = points[i + 2] or points[1], points[i + 3] or points[2]
            
            local dist = self:pointToSegmentDistance(px, py, x1, y1, x2, y2)
            if dist < radius then
                return true
            end
        end
        
        -- Check last edge (closing the polygon)
        local x1, y1 = points[#points - 1], points[#points]
        local x2, y2 = points[1], points[2]
        local dist = self:pointToSegmentDistance(px, py, x1, y1, x2, y2)
        if dist < radius then
            return true
        end
        
        return false
    end
end

function SceneObject:pointInPolygon(x, y, polygon)
    -- Ray casting algorithm for point-in-polygon test
    local inside = false
    local j = #polygon
    
    for i = 1, #polygon, 2 do
        local xi, yi = polygon[i], polygon[i + 1]
        local xj, yj = polygon[j - 1], polygon[j]
        
        if ((yi > y) ~= (yj > y)) and 
           (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then
            inside = not inside
        end
        
        j = i
    end
    
    return inside
end

function SceneObject:pointToSegmentDistance(px, py, x1, y1, x2, y2)
    -- Calculate distance from point to line segment
    local dx = x2 - x1
    local dy = y2 - y1
    
    if dx == 0 and dy == 0 then
        -- Segment is a point
        local dpx = px - x1
        local dpy = py - y1
        return math.sqrt(dpx * dpx + dpy * dpy)
    end
    
    -- Calculate projection of point onto line
    local t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)
    t = math.max(0, math.min(1, t))
    
    -- Find closest point on segment
    local closestX = x1 + t * dx
    local closestY = y1 + t * dy
    
    -- Calculate distance
    local dpx = px - closestX
    local dpy = py - closestY
    return math.sqrt(dpx * dpx + dpy * dpy)
end

-- ===========================
-- Helper Functions
-- ===========================

function SceneObject:withSprite(imagePath)
    self:setSprite(imagePath)
    return self
end

-- Helper function to create object with canvas/procedural graphics
function SceneObject:withCanvas(width, height, drawFunc)
    local canvas = love.graphics.newCanvas(width, height)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    drawFunc()
    love.graphics.setCanvas()
    
    self.sprite = canvas
    return self
end
