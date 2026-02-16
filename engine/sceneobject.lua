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
    
    -- Draw name
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, self.x - 20, self.baseline - 30, 0, 0.6, 0.6)
    
    love.graphics.setColor(1, 1, 1, 1)
end

-- Helper function to create object with sprite
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
