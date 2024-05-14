-- local config = require ('config')
local bresenham = require ('bresenham')
local WaveControl = require ('waves')

local PathBuilder = {}

-- create a path builder instance:
-- -- local path = PathBuilder:new({position = origin, tick = game.tick})
-- get a list of the tile positions in a line:
-- -- local tiles = path:get_path(destination)
-- queue a tile in the builder
-- -- path:add{tick=config.ticks_between_tiles, position={x=tile.x, y=tile.y}}

-- create a new path object
function PathBuilder.init_path(definition)
    local obj = {}
    obj.actions = {}
    obj.index = 1
    obj.position = definition.position
    obj.last_tick = definition.tick
    return obj
end

-- function PathBuilder.get_nth_positions(path, n)
--     local n = n or 1
--     local positions = {}
--     for i = 1, #path do
--         if ((i % n) == 0) then
--             table.insert(positions, {x=path.x, y=path.y})
--         end
--     end
--     return positions
-- end

-- add an instruction to the path object's tasks
function PathBuilder.queue(path, data)
    path.actions[#path.actions + 1] = data
end

-- to be used as the handler for on_tick event
function PathBuilder.update(path, player_name)
    -- are we out of instructions?
    local action = path.actions[path.index]
    if not action then
        return
    end
    -- get our current instruction
    if game.tick < action.tick + path.last_tick then return end
    -- is it time to run this instruction yet?
    
    -- perform action
    path.index = path.index + 1
    path.position = action.position
    -- update our position
    local surface = game.surfaces[config.surface]
    local entities = surface.find_entities_filtered{position=path.position, radius=2, type={'cliff', 'tree', 'simple-entity'}}
    if entities then
        for _, entity in pairs(entities) do entity.destroy() end
    end
    surface.set_tiles{
        tiles = {name = config.path_tile, position = path.position}
    }
    
    -- animation attempt
    if global.origins[player_name].spawner.health then
        surface.create_entity{name="cluster-nuke-explosion", position=path.position, target=global.origins[player_name].spawner}
    end
    
    path.last_tick = path.last_tick + action.tick
    
    if path.index > #path.actions then
        global.player_timers[player_name] = WaveControl.init_player_timer{tick=game.tick, player_name = player_name, wave = 1}
        WaveControl.queue_player_timer(global.player_timers[player_name], {tick=60*5, wave=1})
        -- if no more tiles for this path, clear it from global table
        path = nil
        if config.logging then
            game.print('Path complete. '..#global.paths..' left.')
        end
    end
end

function PathBuilder.new_path(origin)
    local ret = {}
    -- collect tile positions in a table
    
    if config.logging then
        game.write_file('path_tiles.lua', 'Path from '..serpent.line(origin)..' to '..serpent.line(target.position)..'\n', true)
    end
    
    local path = PathBuilder.init_path({position = origin.position, tick = game.tick})
    
    table.insert(origin.paths, path)
    -- create a PathBuilder instance
    
    -- keep track of instance for on_tick handler
    
    -- bresenham.line usage: success, counter = bresenham.line(ox, oy, ex, ey, callback)
    -- the callback function is passed each tile's position and the current count.
    -- the callback must return true to continue the path,
    -- this is how you can say that you've hit something and need to stop the path.
    -- returns 2 values, a boolean success, and the total tile count number
    -- if no callback is provided, just returns the total tile count number
    
    local success, counter = bresenham.line(origin.position.x, origin.position.y, origin.target_position.x, origin.target_position.y, function( x, y, counter )
        -- checking that the line has not grown past our destination
        if ((origin.target_position.x >= origin.position.x) and (x >= origin.target_position.x)) then
            if ((origin.target_position.y >= origin.position.y) and (y >= origin.target_position.y))
            or ((origin.target_position.y <= origin.position.y) and (y <= origin.target_position.y))
            then
                -- returning false stops the path
                return false
            end
        end
        if ((origin.target_position.x <= origin.position.x) and (x <= origin.target_position.x)) then
            if ((origin.target_position.y >= origin.position.y) and (y >= origin.target_position.y))
            or ((origin.target_position.y <= origin.position.y) and (y <= origin.target_position.y))
            then
                -- returning false stops the path
                return false
            end
        end
        
        -- adding our build to the queue
        PathBuilder.queue(path, {tick=config.ticks_between_tiles, position={x=x, y=y}})
        table.insert(ret, {x=x, y=y})
        if math.abs(origin.target_position.x-origin.position.x) >= math.abs(origin.target_position.y-origin.position.y) then
            -- add another tile above to create 2x2
            PathBuilder.queue(path, {tick=config.ticks_between_tiles, position={x=x, y=y+1}})
            table.insert(ret, {x=x, y=y+1})
            PathBuilder.queue(path, {tick=config.ticks_between_tiles, position={x=x, y=y-1}})
            table.insert(ret, {x=x, y=y-1})
        else
            -- add another tile to the right to create 2x2
            PathBuilder.queue(path, {tick=config.ticks_between_tiles, position={x=x+1, y=y}})
            table.insert(ret, {x=x+1, y=y})
            PathBuilder.queue(path, {tick=config.ticks_between_tiles, position={x=x-1, y=y}})
            table.insert(ret, {x=x-1, y=y})
        end
        
        
        -- add tile position to table
        
        if config.logging then
            game.write_file('path_tiles.lua', counter..': x'..x..', y'..y..'\n', true)
        end
        
        -- returning true continues the path
        return true
    end)
    -- counter can be used within the callback above as well to get the count as you go
    
    -- return our table of tile positions
    return ret
end

local function getCircle(radius, center, tile)
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

local function on_tick()
    for name, origin in pairs(global.origins) do
        if game.players[name] then
            if #global.origins[name].paths > 0 then
                for i, path in pairs(global.origins[name].paths) do
                    PathBuilder.update(path, name)
                end
            end
        end
    end
end

PathBuilder.events =
{
    [defines.events.on_tick] = on_tick
}

PathBuilder.on_init = function()
    -- reset the log file
    game.write_file('path_tiles.lua', '')
end

-- commands.add_command('createpath', 'hover your cursor on an entity and run this command', function(command)
--     local player = game.players[command.player_index]
--     if player.selected then
--         if config.logging then
--             game.print({'', 'Creating Path to ', player.selected.localised_name})
--         end
--         PathBuilder.new_path(player.name, player.selected)
--     else
--         game.print("Error: hover over entity that is the attack point for biters")
--     end
-- end)

-- commands.add_command('setorigin', 'put down ghost - hover your cursor over ghost, run command to set this origin from where you want biter to spawn', function(command)
--     local player = game.players[command.player_index]
--     if player.selected then
--         if config.logging then
--             game.print({'', 'Creating origin to ', player.selected.localised_name})
--         end
--         config.origin=player.selected.position
--     else
--         game.print("Error: put down ghost - hover your cursor over ghost, run command to set this origin from where you want biter to spawn")
--     end
-- end)


return PathBuilder