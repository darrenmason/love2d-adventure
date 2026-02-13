-- Hotspot System (clickable areas)
Hotspot = {}
Hotspot.__index = Hotspot

function Hotspot:new(name, x, y, width, height)
    local self = setmetatable({}, Hotspot)
    
    self.name = name
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.shape = "rectangle" -- or "circle", "polygon"
    
    -- For circle shape
    self.radius = nil
    
    -- For polygon shape
    self.polygon = nil
    
    -- Interaction callbacks
    self.interactions = {
        look = nil,
        use = nil,
        talk = nil,
        take = nil,
        walk = nil
    }
    
    -- Optional interaction point (where player walks to)
    self.interactionX = x + width / 2
    self.interactionY = y + height
    
    self.enabled = true
    
    return self
end

function Hotspot:setShape(shape, data)
    self.shape = shape
    
    if shape == "circle" then
        self.radius = data
    elseif shape == "polygon" then
        self.polygon = data
    end
end

function Hotspot:setInteractionPoint(x, y)
    self.interactionX = x
    self.interactionY = y
end

function Hotspot:getInteractionPoint()
    return self.interactionX, self.interactionY
end

function Hotspot:contains(px, py)
    if not self.enabled then
        return false
    end
    
    if self.shape == "rectangle" then
        return px >= self.x and px <= self.x + self.width and
               py >= self.y and py <= self.y + self.height
    elseif self.shape == "circle" then
        local dx = px - self.x
        local dy = py - self.y
        return (dx * dx + dy * dy) <= (self.radius * self.radius)
    elseif self.shape == "polygon" and self.polygon then
        return self:pointInPolygon(px, py, self.polygon)
    end
    
    return false
end

function Hotspot:pointInPolygon(x, y, polygon)
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

function Hotspot:onLook(callback)
    self.interactions.look = callback
    return self
end

function Hotspot:onUse(callback)
    self.interactions.use = callback
    return self
end

function Hotspot:onTalk(callback)
    self.interactions.talk = callback
    return self
end

function Hotspot:onTake(callback)
    self.interactions.take = callback
    return self
end

function Hotspot:onWalk(callback)
    self.interactions.walk = callback
    return self
end

function Hotspot:interact(verb, game)
    if not self.enabled then
        return
    end
    
    local callback = self.interactions[verb]
    
    if callback then
        callback(game)
    else
        -- Default messages
        if verb == "look" then
            game.dialogSystem:showMessage("You see " .. self.name:lower() .. ".")
        elseif verb == "use" then
            game.dialogSystem:showMessage("You can't use that.")
        elseif verb == "talk" then
            game.dialogSystem:showMessage("It doesn't respond.")
        elseif verb == "take" then
            game.dialogSystem:showMessage("You can't take that.")
        end
    end
end

function Hotspot:setEnabled(enabled)
    self.enabled = enabled
end

function Hotspot:drawDebug()
    love.graphics.setColor(1, 0, 0, 0.3)
    
    if self.shape == "rectangle" then
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    elseif self.shape == "circle" then
        love.graphics.circle("fill", self.x, self.y, self.radius)
    elseif self.shape == "polygon" and self.polygon then
        love.graphics.polygon("fill", self.polygon)
    end
    
    -- Draw interaction point
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill", self.interactionX, self.interactionY, 3)
    
    -- Draw name
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, self.x, self.y - 15, 0, 0.7, 0.7)
    
    love.graphics.setColor(1, 1, 1)
end

-- Item Hotspot (for items that can be taken)
ItemHotspot = {}
ItemHotspot.__index = ItemHotspot
setmetatable(ItemHotspot, {__index = Hotspot})

function ItemHotspot:new(item, x, y, width, height)
    local self = Hotspot:new(item.name, x, y, width, height)
    setmetatable(self, ItemHotspot)
    
    self.item = item
    
    -- Set default take behavior
    self:onTake(function(game)
        game.inventory:addItem(self.item)
        game.dialogSystem:showMessage("You took the " .. self.item.name:lower() .. ".")
        self:setEnabled(false) -- Remove from scene
    end)
    
    return self
end
