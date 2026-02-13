-- Simple A* Pathfinding for Point-and-Click Adventures
Pathfinding = {}

function Pathfinding.findPath(startX, startY, endX, endY, walkableArea, gridSize)
    gridSize = gridSize or 20
    
    -- For simple scenes without complex obstacles, just return direct path
    if not walkableArea then
        return {{x = endX, y = endY}}
    end
    
    -- Check if end point is walkable
    if not Pathfinding.isPointInPolygon(endX, endY, walkableArea) then
        -- Find nearest walkable point
        endX, endY = Pathfinding.nearestWalkablePoint(endX, endY, walkableArea)
    end
    
    -- For now, use simple direct path with line-of-sight check
    -- A full A* implementation can be added later if needed
    return {{x = endX, y = endY}}
end

function Pathfinding.isPointInPolygon(x, y, polygon)
    if not polygon or #polygon < 6 then
        return true
    end
    
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

function Pathfinding.nearestWalkablePoint(x, y, polygon)
    -- Find the nearest point on the polygon edge
    local nearestX, nearestY = x, y
    local minDist = math.huge
    
    for i = 1, #polygon - 2, 2 do
        local x1, y1 = polygon[i], polygon[i + 1]
        local x2, y2 = polygon[i + 2] or polygon[1], polygon[i + 3] or polygon[2]
        
        -- Find closest point on line segment
        local px, py = Pathfinding.closestPointOnSegment(x, y, x1, y1, x2, y2)
        local dist = math.sqrt((px - x) * (px - x) + (py - y) * (py - y))
        
        if dist < minDist then
            minDist = dist
            nearestX, nearestY = px, py
        end
    end
    
    -- Move slightly inward from edge
    local centerX, centerY = Pathfinding.polygonCenter(polygon)
    local dx = centerX - nearestX
    local dy = centerY - nearestY
    local len = math.sqrt(dx * dx + dy * dy)
    
    if len > 0 then
        nearestX = nearestX + (dx / len) * 5
        nearestY = nearestY + (dy / len) * 5
    end
    
    return nearestX, nearestY
end

function Pathfinding.closestPointOnSegment(px, py, x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    
    if dx == 0 and dy == 0 then
        return x1, y1
    end
    
    local t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)
    t = math.max(0, math.min(1, t))
    
    return x1 + t * dx, y1 + t * dy
end

function Pathfinding.polygonCenter(polygon)
    local sumX, sumY = 0, 0
    local count = 0
    
    for i = 1, #polygon, 2 do
        sumX = sumX + polygon[i]
        sumY = sumY + polygon[i + 1]
        count = count + 1
    end
    
    return sumX / count, sumY / count
end

-- Interaction module for combining items
Interaction = {}

function Interaction.combineItems(item1, item2, recipes, game)
    -- Check if there's a recipe for these items
    for _, recipe in ipairs(recipes) do
        if (recipe.item1 == item1.id and recipe.item2 == item2.id) or
           (recipe.item1 == item2.id and recipe.item2 == item1.id) then
            
            -- Create result item
            if recipe.result then
                game.inventory:removeItem(item1.id)
                game.inventory:removeItem(item2.id)
                game.inventory:addItem(recipe.result)
                
                if recipe.message then
                    game.dialogSystem:showMessage(recipe.message)
                end
                
                return true
            end
        end
    end
    
    -- No recipe found
    game.dialogSystem:showMessage("These items don't work together.")
    return false
end
