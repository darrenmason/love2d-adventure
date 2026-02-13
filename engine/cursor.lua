-- Cursor and Verb System
Cursor = {}
Cursor.__index = Cursor

function Cursor:new()
    local self = setmetatable({}, Cursor)
    
    self.x = 0
    self.y = 0
    self.hoverText = nil
    
    -- Available verbs
    self.verbs = {
        "walk",
        "look",
        "use",
        "talk",
        "take"
    }
    self.currentVerbIndex = 1
    self.currentVerb = "walk"
    
    -- Hide system cursor
    love.mouse.setVisible(false)
    
    return self
end

function Cursor:setPosition(x, y)
    self.x = x
    self.y = y
end

function Cursor:update(dt)
    -- Update cursor position
    self.x, self.y = love.mouse.getPosition()
end

function Cursor:draw()
    love.graphics.setColor(1, 1, 1)
    
    -- Draw cursor based on current verb
    if self.currentVerb == "walk" then
        -- Crosshair
        love.graphics.line(self.x - 5, self.y, self.x + 5, self.y)
        love.graphics.line(self.x, self.y - 5, self.x, self.y + 5)
    elseif self.currentVerb == "look" then
        -- Eye
        love.graphics.circle("line", self.x, self.y, 8)
        love.graphics.circle("fill", self.x, self.y, 3)
    elseif self.currentVerb == "use" then
        -- Hand
        love.graphics.circle("fill", self.x, self.y, 4)
        love.graphics.line(self.x, self.y, self.x + 10, self.y + 10)
    elseif self.currentVerb == "talk" then
        -- Speech bubble
        love.graphics.circle("line", self.x, self.y, 6)
        love.graphics.line(self.x - 3, self.y + 6, self.x - 5, self.y + 10)
    elseif self.currentVerb == "take" then
        -- Hand grabbing
        love.graphics.rectangle("line", self.x - 4, self.y - 4, 8, 8)
    else
        -- Default pointer
        love.graphics.polygon("fill", 
            self.x, self.y,
            self.x + 12, self.y + 4,
            self.x + 6, self.y + 6,
            self.x + 8, self.y + 12
        )
    end
    
    -- Draw hover text
    if self.hoverText then
        local text = self.currentVerb:upper() .. ": " .. self.hoverText
        local textWidth = love.graphics.getFont():getWidth(text)
        local textX = self.x + 15
        local textY = self.y - 10
        
        -- Background
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", textX - 2, textY - 2, textWidth + 4, 20)
        
        -- Text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(text, textX, textY)
    end
    
    -- Draw current verb in corner
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print("Verb: " .. self.currentVerb:upper(), 10, 10)
    
    love.graphics.setColor(1, 1, 1)
end

function Cursor:cycleVerb()
    self.currentVerbIndex = self.currentVerbIndex + 1
    if self.currentVerbIndex > #self.verbs then
        self.currentVerbIndex = 1
    end
    self.currentVerb = self.verbs[self.currentVerbIndex]
end

function Cursor:setVerb(verb)
    for i, v in ipairs(self.verbs) do
        if v == verb then
            self.currentVerb = verb
            self.currentVerbIndex = i
            return true
        end
    end
    return false
end

function Cursor:getCurrentVerb()
    return self.currentVerb
end

function Cursor:setHoverText(text)
    self.hoverText = text
end
