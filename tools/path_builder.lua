local config = require ('config')
local bresenham = require('tools.bresenham')
-- local EnemyBuilder = require('tools.enemy_builder')

local PathBuilder = {origin_generated = false}

-- create a path builder instance:
-- -- local path = PathBuilder:new({position = origin, tick = game.tick})
-- get a list of the tile positions in a line:
-- -- local tiles = path:get_path(destination)
-- queue a tile in the builder
-- -- path:add{tick=config.ticks_between_tiles, position={x=tile.x, y=tile.y}}


-- returns distance in tiles between 2 positions, will be used to get progress of the paths
local function getDistance(posA, posB)
    -- Get the length for each of the components x and y
    local xDist = posB.x - posA.x
    local yDist = posB.y - posA.y
    
    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) )
end

-- create a new path object
function PathBuilder.create_path_obj(definition)
    local obj = {}
    obj.actions = {}
    obj.index = 1
    obj.position = definition.position
    obj.last_tick = definition.tick
    obj.target = definition.target
    obj.wave_enabled = false
    obj.wave = 0
    obj.waypoints = {}
    return obj
end

function PathBuilder.get_nth_positions(path, n)
    local n = n or 1
    local positions = {}
    for i = 1, #path do
        if ((i % n) == 0) then
            table.insert(positions, {x=path.x, y=path.y})
        end
    end
    return positions
end

-- add an instruction to the path object's tasks
function PathBuilder.queue(path, data)
    path.actions[#path.actions + 1] = data
end

-- to be used as the handler for on_tick event
function PathBuilder.update(tick)
    local paths = global.paths
    for i, path in pairs(paths) do
        if path.index > #path.actions then
            if path.wave_enabled == false then
                if config.logging then
                    game.print('Path '..i..' is complete')
                end
                path.wave_enabled = true
                -- local wave = EnemyBuilder:create_wave(path.target, path.waypoints, path.player)
            end
            return
        end
        -- are we out of instructions?
        local action = path.actions[path.index]
        -- get our current instruction
        if tick < action.tick + path.last_tick then return end
        -- is it time to run this instruction yet?
        
        -- perform action
        path.index = path.index + 1
        path.position = action.position
        -- update our position
        local surface = game.surfaces[config.surface]
        surface.set_tiles{
            tiles = {name = config.path_tile, position = path.position}
        }
        -- set our tile to finish our instruction
        path.last_tick = path.last_tick + action.tick
        --update our timer
    end
end

function PathBuilder.new_path(target)
    local origin = config.origin
    
    local ret = {}
    -- collect tile positions in a table
    
    if config.logging then
        game.write_file('path_tiles.lua', 'Path from '..serpent.line(origin)..' to '..serpent.line(target.position)..'\n', true)
    end
    
    local path = PathBuilder.create_path_obj({position = origin, tick = game.tick, target = target})
    table.insert(global.paths, path)
    -- create a PathBuilder instance
    
    -- keep track of instance for on_tick handler
    
    -- bresenham.line usage: success, counter = bresenham.line(ox, oy, ex, ey, callback)
    -- the callback function is passed each tile's position and the current count.
    -- the callback must return true to continue the path,
    -- this is how you can say that you've hit something and need to stop the path.
    -- returns 2 values, a boolean success, and the total tile count number
    -- if no callback is provided, just returns the total tile count number
    
    local success, counter = bresenham.line(origin.x, origin.y, target.position.x, target.position.y, function( x, y, counter )
        -- checking that the line has not grown past our destination
        if ((target.position.x >= origin.x) and (x >= target.position.x)) then
            if ((target.position.y >= origin.y) and (y >= target.position.y))
            or ((target.position.y <= origin.y) and (y <= target.position.y))
            then
                -- returning false stops the path
                return false
            end
        end
        if ((target.position.x <= origin.x) and (x <= target.position.x)) then
            if ((target.position.y >= origin.y) and (y >= target.position.y))
            or ((target.position.y <= origin.y) and (y <= target.position.y))
            then
                -- returning false stops the path
                return false
            end
        end
        
        -- adding our build to the queue
        PathBuilder.queue(path, {tick=config.ticks_between_tiles, position={x=x, y=y}})
        table.insert(ret, {x=x, y=y})
        if math.abs(target.position.x-origin.x) >= math.abs(target.position.y-origin.y) then
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
    local radius = radius
    local center = center
    local results = {}
    local area = {top_left={x=center.x-radius, y=center.y-radius}, bottom_right={x=center.x+radius, y=center.y+radius}}
    
    for i = area.top_left.x, area.bottom_right.x, 1 do
        for j = area.top_left.y, area.bottom_right.y, 1 do
            local distance = getDistance(center, {x=i, y=j})
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
    if #global.paths > 0 then
        PathBuilder.update(game.tick)
    end
end



local function on_player_created(event)
    -- teleport player to surface at 0, 0
    local player = game.players[event.player_index]
    local posx = math.random(-10*32, 10*32)
    local posy = math.random(-10*32, 10*32)
    while getDistance({x=posx, y=posy}, {x=0, y=0}) <= 11*32 do
        posx = math.random(-10*32, 10*32)
        posy = math.random(-10*32, 10*32)
    end
    if getDistance({x=posx, y=posy}, {x=0, y=0}) > 11*32 then
        player.teleport({x=posx, y=posy}, game.surfaces[config.surface])
    end
end

local on_nth_tick = function()
    if PathBuilder.origin_generated then return end
    local s = game.surfaces[config.surface]
    if s.is_chunk_generated({2, 2}) then
        local void_tiles = getCircle(10*32, config.origin, 'out-of-map')
        local center_tiles = getCircle(2*32, config.origin, 'tutorial-grid')
        
        s.set_tiles(void_tiles)
        s.set_tiles(center_tiles)
        PathBuilder.origin_generated = true
    end
end

PathBuilder.events =
{
    [defines.events.on_tick] = on_tick,
    [defines.events.on_player_created] = on_player_created
}

PathBuilder.on_nth_tick =
{
    [30] = on_nth_tick
}


PathBuilder.on_init = function()
    global.paths = {}
    -- setup the surface and tile grid
    local s = game.surfaces[config.surface] or game.create_surface(config.surface)  -- if running with oarc, use that surface, otherwise create
    -- s.generate_with_lab_tiles = true
    game.write_file('path_tiles.lua', '')
    -- reset the log file
    s.always_day = true
    s.request_to_generate_chunks(config.origin, 12)
    s.force_generate_chunk_requests()
    -- local mgs = s.map_gen_settings
    s.map_gen_settings.width = 1000
    s.map_gen_settings.height = 1000
end

commands.add_command('createpath', 'hover your cursor on an entity and run this command', function(command)
    local player = game.players[command.player_index]
    if player.selected then
        if config.logging then
        game.print({'', 'Creating Path to ', player.selected.localised_name})
        end
        PathBuilder.new_path(player.selected)
    end
end)

return PathBuilder