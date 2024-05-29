local PollutionTracker = {}
local pollution_tracker = {}

local function logger(msg)
    if config.pollution_tracker.logging then
        game.print(msg)
        game.write_file('pvp-td/pollution_tracker_logging.txt', msg..'\n', true)
    end
end

local function make_string(t)
    return tostring(t.x), tostring(t.y)
end

-- local chunks = game.player.surface.get_chunks() game.print(chunks()) game.print(chunks())

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

local function scan(chunk)
    local surface = game.surfaces[config.surface]
    local get_pollution = surface.get_pollution
    local find_entities = surface.find_entities_filtered
    logger('Scanning '..serpent.line({chunk.x, chunk.y})..': '..serpent.line(_C.get_surrounding_positions({x=chunk.x, y=chunk.y}, config.pollution_tracker.search_radius)))
    for i, position in pairs(_C.get_surrounding_positions({x=chunk.x, y=chunk.y}, config.pollution_tracker.search_radius)) do
        local real_position = _C.table_multiplication(position, 32)
        if get_pollution(real_position) > 0 then
            local posx, posy = make_string(position)
            if not pollution_tracker[posx] then pollution_tracker[posx] = {} end
            if not pollution_tracker[posx][posy] then pollution_tracker[posx][posy] = {} end
            
            pollution_tracker[posx][posy].amount = get_pollution(real_position)
            logger('Pollution found @ '..serpent.line(position)..': '..pollution_tracker[posx][posy].amount)
            
            if not pollution_tracker[posx][posy].owner then
                local forces = {}
                -- populating a table of player owned forces to reference when we search the chunks
                for _, force in pairs(game.forces) do
                    if force.name ~= "enemy" and force.name ~= "neutral" then
                        table.insert(forces, force.name)
                    end
                end
                if table_size(find_entities{force=forces, area=chunk.area}) > 0 then
                    for _, entity in pairs(find_entities{force=forces, area=chunk.area}) do
                        if entity.last_user then
                            pollution_tracker[posx][posy].owner = entity.last_user.name
                            logger('Owner found: '..entity.last_user.name)
                            break
                        end
                    end
                end
            end
        end
    end
end

local function scan_new_chunk()
    if not PollutionTracker.iterator then
        PollutionTracker.iterator = game.surfaces[config.surface].get_chunks()
    end
    local chunk = PollutionTracker.iterator()
    if chunk then
        logger(serpent.line(chunk))
        if game.surfaces[config.surface].is_chunk_generated({x=chunk.x, y=chunk.y}) then
            scan(chunk)
        end
    else
        PollutionTracker.iterator = game.surfaces[config.surface].get_chunks()
        chunk = PollutionTracker.iterator()
        if chunk then
            logger(serpent.line(chunk))
            if game.surfaces[config.surface].is_chunk_generated({x=chunk.x, y=chunk.y}) then
                scan(chunk)
            end
        end
    end
end
local function refresh_tracker()
    -- if game.tick > 0 then
    if pollution_tracker then
        PollutionTracker.iterator = game.surfaces[config.surface].get_chunks()
        logger('Refreshing tracker..')
        local chunks = unpack_chunk_table(pollution_tracker)
        logger(serpent.line(chunks))
        for i, chunk in pairs(chunks) do
            scan(chunk)
        end
    end
end
-- end
local function scan_all()
    -- since we can't index the chunk iterator (i suppose the correct term should be enumerate?), we keep count
    -- this is so we can provide a chunk, and surrounding chunks of an adjustable radius are also searched.
    -- then we skip a few chunks in our iterator so that when we search the next group of chunks, they will
    -- neighbor the last group. this way we can get data in bursts and ensure we're not repeating searches.
    -- 
    -- warning: this is going to search every generated chunk, so be prepared for the game to hang up.
    -- this should be used with caution. instead, we're going to scan the map slowly over time. only
    -- use this when you absolutely need to update the data.
    
    local count = 1
    for chunk in pairs(game.surfaces[config.surface].get_chunks()) do
        count = count + 1
        -- [c] = chunk, [r] = chunks in radius
        -- radius = 2
        --
        -- [c] [r] [r] | [r] [r] [c]
        --     (1 + 1) + (1 + 1)+ 1
        --        ^ r     r ^   + 1
        --           r * 2    +   1
        if count % ((config.pollution_tracker.search_radius*2)+1) == 0 then
            scan(chunk)
        end
    end
end

local function get_pollution_data(player)
    -- returns 2 values:
    -- count, total = get_pollution_data(game.player)
    -- 'count' is the number of tracked chunks for this player
    -- 'total' is the total pollution for each tracked chunk for this player
    local count = 0
    local total = 0
    for x, x_data in pairs(pollution_tracker) do
        for y, y_data in pairs(pollution_tracker[x]) do
            
            if (pollution_tracker[x][y].owner)
            and (pollution_tracker[x][y].owner == player.name) then
                count = count + 1
                total = total + pollution_tracker[x][y].amount
            end
        end
    end
    return count, total
end

commands.add_command('check',  'check chunk/pollution trackers', function(command)
    local player = game.players[command.player_index]
    local c, t = get_pollution_data(player)
    player.print(#unpack_chunk_table(pollution_tracker)..' pollution chunks being tracked.')
    player.print('You own '..c..' of those pollution chunks')
    player.print('Your total tracked pollution: '..t)
    player.print('Total pollution on map: '..player.surface.get_total_pollution())
    player.print('Your contribution to the pollution: '..((1/(player.surface.get_total_pollution()/t))*100)..'%')
    player.print('Your average pollution per chunk is '..(t/c))
end)

-- event handlers

PollutionTracker.on_init = function()
    game.write_file('pvp_td/pollution_tracker_logging.txt', '')
end

PollutionTracker.on_nth_tick =
{
    [config.pollution_tracker.time_between_scans] = scan_new_chunk,
    [config.pollution_tracker.time_until_refresh] = refresh_tracker
}

-- PollutionTracker.events =
-- {
--     [defines.events.on_chunk_generated] = function(event)
--         if chunkConfig.enabled then
--             if _C.get_table_count(chunk_tracker) >= chunkConfig.max_chunks_to_track then return end
--             local position = event.position
--             local area = event.area
--             logger('Chunk Generated @ '..serpent.line(position)..', checking chunk...')
--             check_chunk(position, area)

--             for _, force in pairs(game.forces) do
--                 force.chart_all()
--             end
--         end
--     end
-- }

return PollutionTracker