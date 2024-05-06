local config = require ('config')

local Common = {}

function Common.round(num, dp)
    local mult = 10 ^ (dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- returns distance in tiles between 2 positions, will be used to get progress of the paths
function Common.getDistance(posA, posB)
    -- Get the length for each of the components x and y
    local xDist = posB.x - posA.x
    local yDist = posB.y - posA.y
    
    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) )
end

function Common.getCircle(radius, center, tile)
    local radius = radius
    local center = center
    local results = {}
    local area = {top_left={x=center.x-radius, y=center.y-radius}, bottom_right={x=center.x+radius, y=center.y+radius}}
    
    for i = area.top_left.x, area.bottom_right.x, 1 do
        for j = area.top_left.y, area.bottom_right.y, 1 do
            local distance = _C.getDistance(center, {x=i, y=j})
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

function Common.safe_teleport(entity, position, surface)
    local surface = surface or game.surfaces[config.surface]
    local safe_position = surface.find_non_colliding_position(entity.name, position, 16, 1) or position
    entity.teleport(safe_position)
end


return Common