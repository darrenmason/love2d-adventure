-- Inventory System
Inventory = {}
Inventory.__index = Inventory

function Inventory:new()
    local self = setmetatable({}, Inventory)
    
    self.items = {}
    self.visible = true
    self.selectedItem = nil
    
    -- UI settings
    self.x = 10
    self.y = love.graphics.getHeight() - 60
    self.width = love.graphics.getWidth() - 20
    self.height = 50
    self.slotSize = 45
    self.slotPadding = 5
    
    return self
end

function Inventory:addItem(item)
    -- Check if item already exists
    for _, invItem in ipairs(self.items) do
        if invItem.id == item.id then
            -- Stack if stackable
            if item.stackable and invItem.stackable then
                invItem.count = (invItem.count or 1) + (item.count or 1)
                return
            end
        end
    end
    
    -- Add new item
    item.count = item.count or 1
    table.insert(self.items, item)
end

function Inventory:removeItem(itemId)
    for i, item in ipairs(self.items) do
        if item.id == itemId then
            if item.count and item.count > 1 then
                item.count = item.count - 1
            else
                table.remove(self.items, i)
            end
            
            -- Deselect if this was selected
            if self.selectedItem and self.selectedItem.id == itemId then
                self.selectedItem = nil
            end
            return true
        end
    end
    return false
end

function Inventory:hasItem(itemId)
    for _, item in ipairs(self.items) do
        if item.id == itemId then
            return true
        end
    end
    return false
end

function Inventory:getItem(itemId)
    for _, item in ipairs(self.items) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

function Inventory:selectItem(item)
    if self.selectedItem == item then
        self.selectedItem = nil
    else
        self.selectedItem = item
    end
end

function Inventory:draw()
    if not self.visible then
        return
    end
    
    -- Draw inventory background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw items
    local slotX = self.x + self.slotPadding
    local slotY = self.y + self.slotPadding
    
    for i, item in ipairs(self.items) do
        -- Draw slot
        if item == self.selectedItem then
            love.graphics.setColor(0.8, 0.8, 0.2, 0.9)
        else
            love.graphics.setColor(0.3, 0.3, 0.3, 0.9)
        end
        love.graphics.rectangle("fill", slotX, slotY, self.slotSize, self.slotSize)
        
        -- Draw item icon or name
        love.graphics.setColor(1, 1, 1)
        if item.icon then
            love.graphics.draw(item.icon, slotX + 2, slotY + 2)
        else
            -- Draw text
            love.graphics.printf(
                item.name:sub(1, 4),
                slotX,
                slotY + 15,
                self.slotSize,
                "center"
            )
        end
        
        -- Draw count if stackable
        if item.count and item.count > 1 then
            love.graphics.print(tostring(item.count), slotX + 30, slotY + 30, 0, 0.7, 0.7)
        end
        
        -- Move to next slot
        slotX = slotX + self.slotSize + self.slotPadding
        if slotX + self.slotSize > self.x + self.width then
            slotX = self.x + self.slotPadding
            slotY = slotY + self.slotSize + self.slotPadding
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Inventory:handleClick(x, y)
    if not self.visible then
        return false
    end
    
    -- Check if click is within inventory area
    if x < self.x or x > self.x + self.width or
       y < self.y or y > self.y + self.height then
        return false
    end
    
    -- Check which item was clicked
    local slotX = self.x + self.slotPadding
    local slotY = self.y + self.slotPadding
    
    for i, item in ipairs(self.items) do
        if x >= slotX and x <= slotX + self.slotSize and
           y >= slotY and y <= slotY + self.slotSize then
            self:selectItem(item)
            return true
        end
        
        -- Move to next slot position
        slotX = slotX + self.slotSize + self.slotPadding
        if slotX + self.slotSize > self.x + self.width then
            slotX = self.x + self.slotPadding
            slotY = slotY + self.slotSize + self.slotPadding
        end
    end
    
    return true
end

function Inventory:toggle()
    self.visible = not self.visible
end
