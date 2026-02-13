-- Dialog System
DialogSystem = {}
DialogSystem.__index = DialogSystem

function DialogSystem:new()
    local self = setmetatable({}, DialogSystem)
    
    self.active = false
    self.currentDialog = nil
    self.currentLine = 1
    self.choices = nil
    self.callback = nil
    
    -- UI settings
    self.x = 50
    self.y = love.graphics.getHeight() - 200
    self.width = love.graphics.getWidth() - 100
    self.height = 150
    
    -- Text settings
    self.displayedText = ""
    self.fullText = ""
    self.textSpeed = 50 -- characters per second
    self.textTimer = 0
    self.textComplete = false
    
    -- Speaker
    self.speaker = nil
    
    return self
end

function DialogSystem:showMessage(text, speaker)
    self.active = true
    self.fullText = text
    self.displayedText = ""
    self.speaker = speaker
    self.textTimer = 0
    self.textComplete = false
    self.choices = nil
end

function DialogSystem:showDialog(dialogTree, speaker)
    self.currentDialog = dialogTree
    self.currentLine = 1
    self.speaker = speaker
    self:displayCurrentLine()
end

function DialogSystem:displayCurrentLine()
    if not self.currentDialog then
        return
    end
    
    local line = self.currentDialog[self.currentLine]
    
    if type(line) == "string" then
        -- Simple text
        self:showMessage(line, self.speaker)
    elseif type(line) == "table" then
        -- Complex dialog with choices
        if line.text then
            self:showMessage(line.text, self.speaker)
        end
        
        if line.choices then
            self.choices = line.choices
        end
        
        if line.callback then
            self.callback = line.callback
        end
    end
end

function DialogSystem:showChoices(choices, callback)
    self.active = true
    self.choices = choices
    self.callback = callback
    self.fullText = ""
    self.displayedText = ""
    self.textComplete = true
end

function DialogSystem:update(dt)
    if not self.active then
        return
    end
    
    -- Animate text
    if not self.textComplete then
        self.textTimer = self.textTimer + dt
        local charsToShow = math.floor(self.textTimer * self.textSpeed)
        
        if charsToShow >= #self.fullText then
            self.displayedText = self.fullText
            self.textComplete = true
        else
            self.displayedText = self.fullText:sub(1, charsToShow)
        end
    end
end

function DialogSystem:draw()
    if not self.active then
        return
    end
    
    -- Draw dialog box
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw speaker name
    if self.speaker then
        love.graphics.setColor(1, 1, 0.5)
        love.graphics.print(self.speaker, self.x + 10, self.y - 20)
    end
    
    -- Draw text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        self.displayedText,
        self.x + 15,
        self.y + 15,
        self.width - 30,
        "left"
    )
    
    -- Draw continue indicator
    if self.textComplete and not self.choices then
        love.graphics.setColor(1, 1, 1, 0.5 + 0.5 * math.sin(love.timer.getTime() * 5))
        love.graphics.print("[Click to continue]", self.x + self.width - 150, self.y + self.height - 25, 0, 0.7, 0.7)
    end
    
    -- Draw choices
    if self.choices and self.textComplete then
        local choiceY = self.y + 60
        
        for i, choice in ipairs(self.choices) do
            local text = i .. ". " .. choice.text
            
            -- Highlight on hover
            local mouseX, mouseY = love.mouse.getPosition()
            if mouseY >= choiceY and mouseY <= choiceY + 20 then
                love.graphics.setColor(1, 1, 0)
            else
                love.graphics.setColor(0.8, 0.8, 0.8)
            end
            
            love.graphics.print(text, self.x + 20, choiceY, 0, 0.9, 0.9)
            choiceY = choiceY + 25
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DialogSystem:handleClick(x, y)
    if not self.active then
        return
    end
    
    -- Skip text animation
    if not self.textComplete then
        self.displayedText = self.fullText
        self.textComplete = true
        return
    end
    
    -- Handle choices
    if self.choices then
        local choiceY = self.y + 60
        
        for i, choice in ipairs(self.choices) do
            if y >= choiceY and y <= choiceY + 20 then
                -- Choice selected
                if choice.callback then
                    choice.callback()
                end
                
                if self.callback then
                    self.callback(i)
                end
                
                self:close()
                return
            end
            choiceY = choiceY + 25
        end
    else
        -- Continue to next line or close
        if self.currentDialog then
            self.currentLine = self.currentLine + 1
            if self.currentLine <= #self.currentDialog then
                self:displayCurrentLine()
            else
                self:close()
            end
        else
            self:close()
        end
    end
end

function DialogSystem:handleKey(key)
    if not self.active then
        return
    end
    
    -- Number keys for choices
    if self.choices and self.textComplete then
        local num = tonumber(key)
        if num and num >= 1 and num <= #self.choices then
            local choice = self.choices[num]
            
            if choice.callback then
                choice.callback()
            end
            
            if self.callback then
                self.callback(num)
            end
            
            self:close()
        end
    end
end

function DialogSystem:close()
    self.active = false
    self.currentDialog = nil
    self.choices = nil
    self.callback = nil
end

function DialogSystem:isActive()
    return self.active
end
