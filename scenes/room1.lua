-- Example Scene: A Simple Room
local Room1 = {}
setmetatable(Room1, {__index = Scene})

function Room1:new(game)
    local self = Scene:new(game)
    setmetatable(self, {__index = Room1})
    
    self.name = "Mysterious Room"
    
    -- Set player starting position
    self.player.x = 300
    self.player.y = 400
    
    -- Define walkable area (polygon)
    self.walkableArea = {
        100, 350,  -- top left
        900, 350,  -- top right
        900, 600,  -- bottom right
        100, 600   -- bottom left
    }
    
    -- Create background
    self:createBackground()
    
    -- Add scene objects (for depth sorting)
    self:createSceneObjects()
    
    -- Add hotspots and items
    self:createHotspots()
    
    -- Add NPCs
    self:createNPCs()
    
    return self
end

function Room1:createBackground()
    -- Create a simple background using shapes
    -- Note: The table is now a scene object for depth sorting
    local canvas = love.graphics.newCanvas(1024, 768)
    love.graphics.setCanvas(canvas)
    
    -- Sky/ceiling
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", 0, 0, 1024, 350)
    
    -- Floor
    love.graphics.setColor(0.4, 0.3, 0.2)
    love.graphics.rectangle("fill", 0, 350, 1024, 418)
    
    -- Back wall
    love.graphics.setColor(0.35, 0.35, 0.45)
    love.graphics.rectangle("fill", 100, 100, 800, 250)
    
    -- Door
    love.graphics.setColor(0.2, 0.15, 0.1)
    love.graphics.rectangle("fill", 800, 180, 80, 170)
    
    -- Window
    love.graphics.setColor(0.6, 0.7, 0.8)
    love.graphics.rectangle("fill", 200, 150, 100, 80)
    
    -- Shelf
    love.graphics.setColor(0.25, 0.2, 0.15)
    love.graphics.rectangle("fill", 150, 250, 150, 15)
    love.graphics.rectangle("fill", 150, 300, 150, 15)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    self.background = canvas
end

function Room1:createSceneObjects()
    -- Create the table as a scene object with depth sorting
    -- This allows the player to walk behind and in front of it
    
    -- Table sprite/canvas
    local tableCanvas = love.graphics.newCanvas(200, 130)
    love.graphics.setCanvas(tableCanvas)
    love.graphics.clear(0, 0, 0, 0)  -- Transparent background
    
    -- Table top
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.rectangle("fill", 0, 0, 200, 80)
    
    -- Add some shading for depth
    love.graphics.setColor(0.2, 0.15, 0.08)
    love.graphics.rectangle("fill", 0, 75, 200, 5)
    
    -- Table legs
    love.graphics.setColor(0.25, 0.18, 0.1)
    love.graphics.rectangle("fill", 20, 80, 20, 50)
    love.graphics.rectangle("fill", 160, 80, 20, 50)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    -- Create scene object for table
    -- Position it so the baseline is at the bottom of the legs
    local table = SceneObject:new("Table", 500, 550)
    table:setSpriteImage(tableCanvas)
    table:setOrigin(0.5, 1)  -- Center-bottom origin
    table:setBaseline(550)   -- Bottom of table legs = baseline for depth sorting
    table:setLayer("middle")
    
    self:addObject(table)
    
    -- Create a plant/vase as another depth-sorted object
    local plantCanvas = love.graphics.newCanvas(60, 100)
    love.graphics.setCanvas(plantCanvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- Pot
    love.graphics.setColor(0.5, 0.3, 0.2)
    love.graphics.rectangle("fill", 15, 70, 30, 30)
    
    -- Plant
    love.graphics.setColor(0.2, 0.5, 0.2)
    love.graphics.circle("fill", 20, 40, 15)
    love.graphics.circle("fill", 35, 35, 18)
    love.graphics.circle("fill", 40, 50, 12)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local plant = SceneObject:new("Plant", 700, 480)
    plant:setSpriteImage(plantCanvas)
    plant:setOrigin(0.5, 1)
    plant:setBaseline(480)
    plant:setLayer("middle")
    
    self:addObject(plant)
end

function Room1:createHotspots()
    -- Door hotspot
    local door = Hotspot:new("Door", 800, 180, 80, 170)
    door:setInteractionPoint(850, 400)
    door:onLook(function(game)
        game.dialogSystem:showMessage("It's a heavy wooden door. It looks locked.")
    end)
    door:onUse(function(game)
        if game.inventory:hasItem("key") then
            game.dialogSystem:showMessage("You unlock the door and step through...")
            -- In a real game, this would load a new scene
            game:setFlag("doorUnlocked", true)
        else
            game.dialogSystem:showMessage("The door is locked. You need a key.")
        end
    end)
    door:onItemUse("key", function(game)
        game.dialogSystem:showMessage("You use the key to unlock the door!")
        game.inventory:removeItem("key")
        game:setFlag("doorUnlocked", true)
    end)
    self:addHotspot(door)
    
    -- Window hotspot
    local window = Hotspot:new("Window", 200, 150, 100, 80)
    window:setInteractionPoint(250, 400)
    window:onLook(function(game)
        game.dialogSystem:showMessage("Through the window you see a dark forest. It's night time.")
    end)
    window:onUse(function(game)
        game.dialogSystem:showMessage("The window is stuck. You can't open it.")
    end)
    self:addHotspot(window)
    
    -- Table hotspot (matches the SceneObject position)
    local table = Hotspot:new("Table", 400, 470, 200, 80)
    table:setInteractionPoint(500, 560)
    table:onLook(function(game)
        if game:hasFlag("noteTaken") then
            game.dialogSystem:showMessage("An old wooden table. There's nothing interesting on it now.")
        else
            game.dialogSystem:showMessage("An old wooden table. There's a note on it.")
        end
    end)
    table:onUse(function(game)
        game.dialogSystem:showMessage("It's just a table.")
    end)
    self:addHotspot(table)
    
    -- Note item (on table) - adjusted to new table position
    if not self.game:hasFlag("noteTaken") then
        local noteItem = {
            id = "note",
            name = "Mysterious Note",
            description = "A yellowed piece of paper with strange writing.",
            stackable = false
        }
        local note = ItemHotspot:new(noteItem, 470, 485, 50, 30)
        note:setInteractionPoint(500, 560)
        note:onLook(function(game)
            game.dialogSystem:showMessage("A piece of paper with writing on it.")
        end)
        note:onTake(function(game)
            game.inventory:addItem(noteItem)
            game.dialogSystem:showMessage("You took the note. It reads: 'The key is behind the painting.'")
            game:setFlag("noteTaken", true)
            note:setEnabled(false)
        end)
        self:addHotspot(note)
    end
    
    -- Shelf hotspot
    local shelf = Hotspot:new("Shelf", 150, 230, 150, 85)
    shelf:setInteractionPoint(225, 400)
    shelf:onLook(function(game)
        game.dialogSystem:showMessage("Two dusty shelves. There's an old book on the top shelf.")
    end)
    self:addHotspot(shelf)
    
    -- Book item (on shelf)
    if not self.game:hasFlag("bookTaken") then
        local bookItem = {
            id = "book",
            name = "Ancient Book",
            description = "A leather-bound tome with mysterious symbols.",
            stackable = false
        }
        local book = ItemHotspot:new(bookItem, 200, 250, 40, 15)
        book:setInteractionPoint(225, 400)
        book:onLook(function(game)
            game.dialogSystem:showMessage("An ancient book. The title is unreadable.")
        end)
        book:onTake(function(game)
            game.inventory:addItem(bookItem)
            game.dialogSystem:showMessage("You took the ancient book.")
            game:setFlag("bookTaken", true)
            book:setEnabled(false)
        end)
        self:addHotspot(book)
    end
    
    -- Painting (hidden key behind it)
    local painting = Hotspot:new("Painting", 600, 200, 80, 100)
    painting:setInteractionPoint(640, 400)
    painting:onLook(function(game)
        game.dialogSystem:showMessage("A dark painting of a stormy sea.")
    end)
    painting:onUse(function(game)
        if not game:hasFlag("keyRevealed") then
            game.dialogSystem:showMessage("You move the painting aside and find a key hidden behind it!")
            game:setFlag("keyRevealed", true)
            
            -- Add key item hotspot
            local keyItem = {
                id = "key",
                name = "Old Key",
                description = "A rusty iron key.",
                stackable = false
            }
            local key = ItemHotspot:new(keyItem, 640, 250, 20, 30)
            key:setInteractionPoint(640, 400)
            self:addHotspot(key)
        else if game:hasFlag("keyTaken") then
            game.dialogSystem:showMessage("The painting hangs slightly askew.")
        else
            game.dialogSystem:showMessage("The key is behind the painting.")
        end
        end
    end)
    self:addHotspot(painting)
end

function Room1:createNPCs()
    -- Create a simple NPC
    local npc = {
        name = "Mysterious Figure",
        x = 750,
        y = 500,
        width = 40,
        height = 80,
        color = {0.5, 0, 0.5},
        conversationState = 0
    }
    
    function npc:draw()
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height, self.width, self.height)
        -- Head
        love.graphics.circle("fill", self.x, self.y - self.height - 15, 15)
        love.graphics.setColor(1, 1, 1)
    end
    
    function npc:contains(px, py)
        return px >= self.x - self.width/2 and px <= self.x + self.width/2 and
               py >= self.y - self.height - 30 and py <= self.y
    end
    
    function npc:interact(verb, game)
        if verb == "look" then
            game.dialogSystem:showMessage("A mysterious figure in a dark cloak.")
        elseif verb == "talk" then
            self.conversationState = self.conversationState + 1
            
            if self.conversationState == 1 then
                game.dialogSystem:showDialog({
                    "Hello, stranger. What brings you to this place?",
                    {
                        text = "I need to get out of here.",
                        choices = {
                            {text = "Can you help me?", callback = function()
                                game.dialogSystem:showMessage("Perhaps... if you can solve the riddle of this room.", "Mysterious Figure")
                            end},
                            {text = "Do you know the way out?", callback = function()
                                game.dialogSystem:showMessage("The door is your only exit, but you'll need the right key.", "Mysterious Figure")
                            end},
                            {text = "Never mind.", callback = function()
                                -- Do nothing
                            end}
                        }
                    }
                }, "Mysterious Figure")
            elseif self.conversationState == 2 then
                game.dialogSystem:showMessage("Have you found what you're looking for?", "Mysterious Figure")
            else
                game.dialogSystem:showMessage("Good luck on your journey.", "Mysterious Figure")
            end
        else
            game.dialogSystem:showMessage("The figure ignores you.")
        end
    end
    
    self:addNPC(npc)
end

function Room1:onEnter()
    print("Entered Room 1")
end

return Room1
