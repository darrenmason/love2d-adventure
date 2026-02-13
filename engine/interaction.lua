-- Interaction utilities for item combinations and complex actions
InteractionManager = {}
InteractionManager.__index = InteractionManager

function InteractionManager:new()
    local self = setmetatable({}, InteractionManager)
    
    -- Store combination recipes
    self.recipes = {}
    
    return self
end

function InteractionManager:addRecipe(item1Id, item2Id, resultItem, message)
    table.insert(self.recipes, {
        item1 = item1Id,
        item2 = item2Id,
        result = resultItem,
        message = message
    })
end

function InteractionManager:tryUseItemOnHotspot(item, hotspot, game)
    -- Check if hotspot has a specific handler for this item
    if hotspot.itemInteractions and hotspot.itemInteractions[item.id] then
        hotspot.itemInteractions[item.id](game)
        return true
    end
    
    return false
end

function InteractionManager:tryUseItemOnItem(item1, item2, game)
    -- Try to combine items
    for _, recipe in ipairs(self.recipes) do
        if (recipe.item1 == item1.id and recipe.item2 == item2.id) or
           (recipe.item1 == item2.id and recipe.item2 == item1.id) then
            
            -- Remove ingredients
            game.inventory:removeItem(item1.id)
            game.inventory:removeItem(item2.id)
            
            -- Add result
            if recipe.result then
                game.inventory:addItem(recipe.result)
            end
            
            -- Show message
            if recipe.message then
                game.dialogSystem:showMessage(recipe.message)
            end
            
            return true
        end
    end
    
    -- No valid combination
    game.dialogSystem:showMessage("These items don't work together.")
    return false
end

-- Helper function to add item interactions to hotspots
function Hotspot:onItemUse(itemId, callback)
    if not self.itemInteractions then
        self.itemInteractions = {}
    end
    self.itemInteractions[itemId] = callback
    return self
end
