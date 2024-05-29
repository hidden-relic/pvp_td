------------------------------------
-- Chunk Tracking by hidden_relic --
------------------------------------

-- Whenever the game generates a new chunk, we check that chunk and
-- surrounding chunks within an adjustable range for pollution and
-- player-built entities. if neither pollution nor player-built entities
-- are found, we add the new chunk to the chunk tracker table.
-- the chunk tracker table is checked on adjustable time, where
-- each chunk and its surrounding chunks are checked again. if pollution
-- or a player-built entity is found, the chunk is removed from the chunk tracker.
-- if, after an adjustable total lifetime, a chunk still has no pollution
-- and no player-built-entities, and thus is still in the list,
-- we deem it 'unused' and delete the chunk from the map
-- and make it 'nil' in our tracker.

-- If pollution was the cause of removal from the chunk tracker table,
-- that chunk is moved to the pollution chunk tracker table instead.
-- here we can hopefully run some functions to try and determine:
-- -- how much pollution a player may be creating in all the places
-- that they are creating it by keeping count of the chunks containing
-- a player-built entity built by that player,
-- -- how big of a slice of the total pollution a player is creating
-- by dividing the total pollution by their total pollution,
-- -- a player's actual affect on the pollution in the map, by
-- comparing their pollution output against their pollution footprint
-- by dividing their total pollution by their chunk count

-- the most compact way to store the positions as far as i can tell,
-- is to store them all inside 1 table like this:

-- chunk_tracker[x][y] = tick_it_was_added

-- 'chunks' will only have as many tables as there are different x positions,
-- and similarly those tables will only have as many tables as there are y positions
-- corresponding to that x position. i think this is also the most efficient way
-- to access them, for human and machine. but when a table uses numerical indexing 'n',
-- it is because that item was the 'n'th item added. we aren't working like that, but
-- we can do a similar thing by converting the positions to string values to use
-- as indexes, and converting the keys back to number if we need the position:

-- chunk_tracker["x"]["y"] = tick_it_was_added

-- this works the same for indexing pollution_chunk_tracker, although the values will be different

local sec = 60
local min = sec*60
local hour = min*60
local day = hour*24

local ChunkTracker = {}
local chunk_tracker = {}
local pollution_chunk_tracker = {}
local tag_tracker = {
    tracked = {},
    current = {}
}

local chunkConfig = {
    enabled = true,
    deletion = false,
    entities_chunks = 2,
    pollution_chunks = 3,
    time_between_scans = min*2,
    time_until_removal = min*20,
    max_chunks_to_track = 10000,
    logging = true
}

local function logger(msg)
    if chunkConfig.logging then
        -- game.print(msg)
        game.write_file('pvp_td/chunk_logging.txt', msg..'\n', true)
    end
end

-- used to get each position in a chunk position
local function get_positions_in_chunk(chunk_position)
    local t = {}
    local pos_x = chunk_position.x/32
    local pos_y = chunk_position.y/32
    for x = (pos_x-32), pos_x do
        for y = (pos_y-32), pos_y do
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
    if not pollution_chunk_tracker then pollution_chunk_tracker = {} end
    
    local px, py = tostring(position.x), tostring(position.y)
    
    -- populating a table of player owned forces to reference when we search the chunks
    for _, force in pairs(game.forces) do
        if force.name ~= "enemy" and force.name ~= "neutral" then
            table.insert(forces, force.name)
        end
    end
    
    -- search surrounding chunks for pollution
    -- if pollution is found in a chunk, that chunk is moved to the pollution tracker
    logger('Checking surrounding chunks targetting '..serpent.line(position))
    for _, pos in pairs(_C.get_surrounding_positions(position, pollution_chunks)) do
        
        local str_pos_x = tostring(pos.x)
        local str_pos_y = tostring(pos.y)
        local pollution = get_pollution(_C.table_multiplication(pos, 32))
        if pollution ~= 0 then
            
            if not pollution_chunk_tracker[str_pos_x] then
                pollution_chunk_tracker[str_pos_x] = {}
            end
            if not pollution_chunk_tracker[str_pos_x][str_pos_y] then
                pollution_chunk_tracker[str_pos_x][str_pos_y] = {pollution=pollution}
                logger(serpent.line(pos)..' added to pollution tracker.')
                game.forces['player'].add_chart_tag(game.surfaces[1], {position=_C.table_addition(_C.table_multiplication(pos, 32), 16), icon={type='virtual', name='signal-dot'}, text='P'})
            end
            if pollution_chunk_tracker[str_pos_x][str_pos_y].pollution then
                pollution_chunk_tracker[str_pos_x][str_pos_y].pollution = pollution
            end
            local chunk_area = {_C.table_multiplication(pos, 32), _C.table_addition(_C.table_multiplication(pos, 32), 32)}
            if not pollution_chunk_tracker[str_pos_x][str_pos_y].owner then
                if table_size(find_entities{force=forces, area=chunk_area}) > 0 then
                    for _, entity in pairs(find_entities{force=forces, area=chunk_area}) do
                        if entity.last_user then
                            pollution_chunk_tracker[str_pos_x][str_pos_y].owner = entity.last_user.name
                            logger('Owner of pollution found: '..entity.last_user.name)
                            break
                        end
                    end
                end
            end
            
            
            if chunk_tracker[px] then
                if chunk_tracker[px][py] then
                    chunk_tracker[px][py] = nil
                    logger('Removed from chunk tracker')
                    if tag_tracker.tracked[px] and tag_tracker.tracked[px][py] then
                        tag_tracker.tracked[px][py].destroy()
                    end
                end
            end
        end
    end
    
    -- search surrounding chunks for entities. if no player
    -- owned entities are found, we can add chunk to the list
    if chunkConfig.deletion then
        if table_size(find_entities{force=forces, area=_C.expand_area_by_chunk(area, entities_chunks)}) == 0 then
            
            logger('No entities found.')
            if not chunk_tracker[px] then
                chunk_tracker[px] = {}
            end
            if not chunk_tracker[px][py] then
                chunk_tracker[px][py] = game.tick
                logger(serpent.line(position)..' added to chunk tracker.')
            end
            if not tag_tracker.tracked[px] then
                tag_tracker.tracked[px] = {}
            end
            if not tag_tracker.tracked[px][py] then
                tag_tracker.tracked[px][py] = {}
                tag_tracker.tracked[px][py] = game.forces['player'].add_chart_tag(game.surfaces[1], {position=_C.table_addition(_C.table_multiplication(position, 32), 16), icon={type='virtual', name='signal-check'}, text='C'})
            end
            
            -- in case this chunk was already in the list, lets check how long its been there
            -- if past the expiration time, let's delete the chunk
            if chunk_tracker[px][py] then
                local chunk_tracked_lifetime = game.tick - chunk_tracker[px][py]
                logger('Chunk has been tracked for '..chunk_tracked_lifetime..' ticks. It will expire in '..(chunkConfig.time_until_removal-chunk_tracked_lifetime)..' ticks.')
                if (chunk_tracked_lifetime) > chunkConfig.time_until_removal then
                    surface.delete_chunk(position)
                    chunk_tracker[px][py] = nil
                    logger('Chunk has expired and been deleted from game and removed from chunk tracker')
                    return position
                end
            end
        else
            
            -- if we did find player owned entities and this chunk was in the list,
            -- remove it from the list to mark it safe
            logger('Entities found.')
            local entity = find_entities{force=forces, area=_C.expand_area_by_chunk(area, entities_chunks)}[1]
            logger(entity.name..' ('..entity.force.name..') @ '..serpent.line(entity.position))
            if chunk_tracker[px] then
                if chunk_tracker[px][py] then
                    chunk_tracker[px][py] = nil
                    logger('Removed from chunk tracker')
                end
            end
        end
    end
end

local function unpack_chunk_table(t)
    -- goes through a chunk tracker table, gathering and pairing
    -- the string indexes (positions) of the table so that they will
    -- be converted back to numerical values and returned as a table of {x=,y=} positions
    -- returns a table of chunk positions:
    -- {{x=1, y=2}, {x=1, y=3}, {x=2, y=3}, {x=2, y=4}}
    local ret = {}
    -- get a table of x positions by getting all keys
    local xs = _C.generate_key_list(t)
    -- iterate x positions
    for _, x in pairs(xs) do
        -- get a table of y positions by getting all keys within this x position entry
        local ys = _C.generate_key_list(t[x])
        -- iterate y positions while iterating x positions
        for _, y in pairs(ys) do
            -- convert our string indexes back to numbers and add correct position to returned table 
            table.insert(ret, {x=tonumber(x), y=tonumber(y)})
        end
    end
    return ret
end

-- event handlers

ChunkTracker.on_init = function()
    game.write_file('pvp_td/chunk_logging.txt', '')
end

ChunkTracker.on_nth_tick =
{
    [chunkConfig.time_between_scans] = function()
        if chunkConfig.enabled then
            local t = unpack_chunk_table(chunk_tracker)
            for _, position in pairs(t) do
                local area = {left_top=_C.table_multiplication(position, 32), right_bottom=_C.table_addition(_C.table_multiplication(position, 32), 32)}
                check_chunk(position, area)
            end
            t = unpack_chunk_table(pollution_chunk_tracker)
            for _, position in pairs(t) do
                local area = {left_top=_C.table_multiplication(position, 32), right_bottom=_C.table_addition(_C.table_multiplication(position, 32), 32)}
                check_chunk(position, area)
            end
        end
    end
}

ChunkTracker.events =
{
    [defines.events.on_chunk_generated] = function(event)
        if chunkConfig.enabled then
            if _C.get_table_count(chunk_tracker) >= chunkConfig.max_chunks_to_track then return end
            local position = event.position
            local area = event.area
            logger('Chunk Generated @ '..serpent.line(position)..', checking chunk...')
            check_chunk(position, area)
            
            for _, force in pairs(game.forces) do
                force.chart_all()
            end
        end
    end
}

return ChunkTracker