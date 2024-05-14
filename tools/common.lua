local config = require ('config')

local Common = {}

function Common.round(num, dp)
    local mult = 10 ^ (dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Common.table_length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

-- returns distance in tiles between 2 positions, will be used to get progress of the paths
function Common.get_distance(posA, posB)
    -- Get the length for each of the components x and y
    local xDist = posB.x - posA.x
    local yDist = posB.y - posA.y
    
    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) )
end

function Common.get_closest_position(pos, list)
    local x, y = pos.x or pos[1], pos.y or pos[2]
    local closest = 2147483647 -- max int
    local key
    for i, posenum in pairs(list) do
        local distance = Common.get_distance(pos, posenum)
        if distance < closest then
            x, y = posenum.x, posenum.y
            closest = distance
            key = i
        end
    end
    if closest == 2147483647 then return end
    return {x=x, y=y}, key
end

function Common.get_circle(radius, center, tile)
    local radius = radius
    local center = {x=center.x or center[1], y=center.y or center[2]}
    local results = {}
    local area = {top_left={x=center.x-radius, y=center.y-radius}, bottom_right={x=center.x+radius, y=center.y+radius}}
    
    for i = area.top_left.x, area.bottom_right.x, 1 do
        for j = area.top_left.y, area.bottom_right.y, 1 do
            local distance = _C.get_distance(center, {x=i, y=j})
            if (distance < radius) then
                if tile then
                    table.insert(results, {name=tile, position={i, j}})
                else
                    table.insert(results, {i, j})
                end
            end
        end
    end
    return results
end

function Common.protect_entity(entity)
    entity.minable = false
    entity.destructible = false
end

function Common.safe_position(entity, position, surface)
    local surface = surface or game.surfaces[config.surface]
    return surface.find_non_colliding_position(entity.name or entity, position, 16, 1) or position
end

function Common.safe_teleport(entity, position, surface)
    local surface = surface or game.surfaces[config.surface]
    entity.teleport(Common.safe_position(entity, position, surface))
end

return Common