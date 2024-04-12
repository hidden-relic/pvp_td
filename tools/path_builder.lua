local bresenham = require('tools.bresenham')

local PathBuilder =
{
    paths = {}
}

-- create a path builder instance:
-- -- local path = PathBuilder:new({position = origin, tick = game.tick})
-- get a list of the tile positions in a line:
-- -- local tiles = path:get_path(destination)
-- queue a tile in the builder
-- -- path:add{tick=config.ticks_between_tiles, position={x=tile.x, y=tile.y}}

local config =
{
    surface = 'oarc',
    path_tile = 'landfill',
    ticks_between_tiles = 5,
    origin = {x=0, y=0},
    logging = false
    -- will log "origin xy to destination xy" and all the tile positions between for each new line
}

-- returns distance in tiles between 2 positions, will be used to get progress of the paths
-- function getDistance(posA, posB)
--     -- Get the length for each of the components x and y
--     local xDist = posB.x - posA.x
--     local yDist = posB.y - posA.y
    
--     return math.sqrt( (xDist ^ 2) + (yDist ^ 2) )
-- end

-- create a new path object
function PathBuilder:new(definition)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.actions = {}
    obj.index = 1
    obj.position = definition.position
    obj.last_tick = definition.tick
    return obj
end

-- add an instruction to the path object's tasks
function PathBuilder:add(data)
    self.actions[#self.actions + 1] = data
end

-- to be used as the handler for on_tick event
function PathBuilder:update(tick)
    if self.index > #self.actions then return end
    -- are we out of instructions?
    local action = self.actions[self.index]
    -- get our current instruction
    if tick < action.tick + self.last_tick then return end
    -- is it time to run this instruction yet?
    
    -- perform action
    self.index = self.index + 1
    self.position = action.position
    -- update our position
    local surface = game.surfaces[config.surface]
    surface.set_tiles{
        tiles = {name = config.path_tile, position = self.position}
    }
    -- set our tile to finish our instruction
    self.last_tick = self.last_tick + action.tick
    --update our timer
end

function PathBuilder:get_path(position)
    local origin = config.origin
    
    local ret = {}
    -- collect tile positions in a table
    
    if config.logging then
        game.write_file('path_tiles.lua', 'Path from '..serpent.line(origin)..' to '..serpent.line(position)..'\n', true)
    end
    
    local path = PathBuilder:new({position = origin, tick = game.tick})
    -- create a PathBuilder instance
    table.insert(PathBuilder.paths, path)
    -- keep track of instance for on_tick handler
    
    -- bresenham.line usage: success, counter = bresenham.line(ox, oy, ex, ey, callback)
    -- the callback function is passed each tile's position and the current count.
    -- the callback must return true to continue the path,
    -- this is how you can say that you've hit something and need to stop the path.
    -- returns 2 values, a boolean success, and the total tile count number
    -- if no callback is provided, just returns the total tile count number

    local success, counter = bresenham.line(origin.x, origin.y, position.x, position.y, function( x, y, counter )
        -- checking that the line has not grown past our destination
        if ((position.x >= origin.x) and (x >= position.x)) then
            if ((position.y >= origin.y) and (y >= position.y))
            or ((position.y <= origin.y) and (y <= position.y))
            then
                -- returning false stops the path
                return false
            end
        end
        if ((position.x <= origin.x) and (x <= position.x)) then
            if ((position.y >= origin.y) and (y >= position.y))
            or ((position.y <= origin.y) and (y <= position.y))
            then
                -- returning false stops the path
                return false
            end
        end
        
        -- uncomment if creating the path now, 1 tile at a time
        -- path:add{tick=config.ticks_between_tiles, position={x=round(x), y=round(y)}}
        
        table.insert(ret, {x=x, y=y})
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

local function on_tick()
    if #PathBuilder.paths > 0 then
        for _, path in pairs(PathBuilder.paths) do
            path:update(game.tick)
        end
    end
end

local function on_player_created(event)
    -- teleport player to surface at 0, 0
    local player = game.players[event.player_index]
    player.teleport({0, 0}, game.surfaces['oarc'])
end

PathBuilder.events =
{
    [defines.events.on_tick] = on_tick,
    [defines.events.on_player_created] = on_player_created
}

PathBuilder.on_init = function()
    -- setup the surface and tile grid
    local s = game.surfaces["oarc"] or game.create_surface('oarc')  -- if running with oarc, use that surface, otherwise create
    -- s.generate_with_lab_tiles = true
    game.write_file('path_tiles.lua', '')
    -- reset the log file
    s.always_day = true
end

return PathBuilder