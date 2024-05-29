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

-- used mostly to get positions surrounding a position 
function Common.table_addition(t, n)
    local new = {}
    if t.x and t.y then
        new.x = t.x+n
        new.y = t.y+n
    else
        for k, v in pairs(t) do
            new[k] = v+n
        end
    end
    return new
end

-- used mostly to turn a chunk position into a regular position
function Common.table_multiplication(t, n)
    local new = {}
    if t.x and t.y then
        new.x = t.x*n
        new.y = t.y*n
    else
        for k, v in pairs(t) do
            new[k] = v*n
        end
    end
    return new
end

-- used to get the number of positions inside our table of positions
-- chunk positions are stored like so:
-- chunk_tracker[position.x][position.y] = tick_it_was_added_to_the_list
function Common.get_table_count(t)
    local count = 0
    for _, x in pairs(t) do
        for _, y in pairs(x) do
            count = count + 1
        end
    end
    return count
end

-- used to get a list of keys from a table where the key becomes the value indexed by number in the new table
-- {['a'] = 1, ['b'] = 2, ['c'] = 3} becomes {'a', 'b', 'c'}
function Common.generate_key_list(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys+1] = k
    end
    return keys
end

-- used to increase an area by a given chunk amount
function Common.expand_area_by_chunk(area, chunks)
    local lt = area.left_top
    local rb = area.right_bottom
    return {left_top=Common.table_addition(lt, -chunks*32), right_bottom=Common.table_addition(rb, chunks*32)}
end

-- used to get a list of positions surrounding a position
function Common.get_surrounding_positions(position, n)
    local t = {}
    for x=position.x-n, position.x+n do
        for y=position.y-n, position.y+n do
            table.insert(t, {x=x, y=y})
        end
    end
    return t
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

function Common.floating_text(surface, position, text, color)
    color = color or {r=1, g=1, b=1, a=1}
    return surface.create_entity {
        name = 'tutorial-flying-text',
        color = color,
        text = text,
        position = position
    }
end

return Common