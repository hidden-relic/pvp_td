local sec = 60
local min = sec*60
local hour = min*60
local day = hour*24

local chunk_tracker = {}

local chunkConfig = {
    enabled = false,
    entities_chunks = 16,
    pollution_chunks = 32,
    time_between_scans = min*10,
    time_until_removal = hour*2,
    max_chunks_to_track = 10000
}

-- used mostly to get positions surrounding a position 
local function table_addition(t, n)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v+n
    end
    return new
end

-- used mostly to convert positions into chunk positions
local function table_multiplication(t, n)
    local new = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then game.print(serpent.block(t)) end
        new[k] = v*n
    end
    return new
end

-- used to increase an area by a given chunk amount
local function expand_area_by_chunk(area, chunks)
    local lt = area.left_top
    local rb = area.right_bottom
    return {left_top=table_addition(lt, -chunks*32), right_bottom=table_addition(rb, chunks*32)}
end

-- used to get a list of positions surrounding a position
local function get_surrounding_positions(position, n)
    local t = {}
    for x=position.x-n, position.x+n do
        for y=position.y-n, position.y+n do
            table.insert(t, {x=x, y=y})
        end
    end
    return t
end

local function check_chunk(position, area)
    local surface = game.surfaces[1]
    local entities_chunks = chunkConfig.entities_chunks
    local pollution_chunks = chunkConfig.pollution_chunks
    local forces = {}
    local find_entities = surface.find_entities_filtered
    local get_pollution = surface.get_pollution
    
    -- keep track of chunks in this table
    if not chunk_tracker then chunk_tracker = {} end
    
    local px, py = tostring(position.x), tostring(position.y)
    
    -- populating a table of player owned forces to reference when we search the chunks
    for name, force in pairs(game.forces) do
        if name ~= "enemy" and name ~= "neutral" then
            table.insert(forces, name)
        end
    end
    
    -- search surrounding chunks for pollution. if no pollution
    -- in a chunk then we can add that chunk to the list
    for _, pos in pairs(get_surrounding_positions(position, pollution_chunks)) do
        if get_pollution(table_multiplication(pos, 32)) ~= 0 then
            if chunk_tracker[px] then
                if chunk_tracker[px][py] then
                    chunk_tracker[px][py] = nil
                end
            end
            return
        end
    end
    
    -- search surrounding chunks for entities. if no player
    -- owned entities are found, we can add chunk to the list
    if table_size(find_entities{force=forces, area=expand_area_by_chunk(area, entities_chunks)}) == 0 then
        
        if not chunk_tracker[px] then
            chunk_tracker[px] = {}
        end
        if not chunk_tracker[px][py] then
            chunk_tracker[px][py] = game.tick
        end

        -- in case this chunk was already in the list, lets check how long its been there
        -- if past the expiration time, let's delete the chunk
        if chunk_tracker[px][py] then
            if (game.tick - chunk_tracker[px][py]) > chunkConfig.time_until_removal then
                surface.delete_chunk(position)
                chunk_tracker[px][py] = nil
                return position
            end
        end
    else

        -- if we did find player owned entities and this chunk was in the list,
        -- remove it from the list to mark it safe
        if chunk_tracker[px] then
            if chunk_tracker[px][py] then
                chunk_tracker[px][py] = nil
            end
        end
    end
end

-- used to get the number of values inside our table of positions
-- chunk positions are stored like so:
-- chunk_tracker[position.x][position.y] = tick_it_was_added_to_the_list
local function get_table_count(t)
    local count = 0
    for _, x in pairs(t) do
        for _, y in pairs(x) do
            count = count + 1
        end
    end
    return count
end

-- used to get a list of keys from a table where the key becomes the value indexed by number in the new table
local function generate_key_list(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys+1] = k
    end
    return keys
end

-- event handlers
local events =
{
[on_chunk_generated] = function(event)
    if chunkConfig.enabled then
        if get_table_count(chunk_tracker) >= chunkConfig.max_chunks_to_track then return end
        local surface = event.surface
        local position = event.position
        local area = event.area
        check_chunk(surface, position, area)
    end
end,

[on_nth_tick(chunkConfig.time_between_scans)] = function()
    if chunkConfig.enabled then
        local t = {}
        local xs = generate_key_list(chunk_tracker)
        for _, x in pairs(xs) do
            local ys = generate_key_list(chunk_tracker[x])
            for _, y in pairs(ys) do
                table.insert(t, {x=tonumber(x), y=tonumber(y)})
            end
        end
        local count = 0
        for _, position in pairs(t) do
            local area = {left_top=table_multiplication(position, 32), right_bottom=table_addition(table_multiplication(position, 32), 32)}
            if check_chunk(position, area) then
                count = count + 1
            end
        end
    end
end
}