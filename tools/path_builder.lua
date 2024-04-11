local bresenham = require('tools.bresenham')

local PathBuilder =
{
    paths = {}
}

local config =
{
    surface = 'oarc',
    path_tile = 'landfill',
    ticks_between_tiles = 1,
    origin = {x=0, y=0}
}

-- -- position functions to return a position relative to a position
-- local function down(position) return {x=position.x, y=position.y + 1} end
-- local function right(position) return {x=position.x + 1, y=position.y} end
-- local function up(position) return {x=position.x, y=position.y - 1} end
-- local function left(position) return {x=position.x - 1, y=position.y} end

-- returns distance in tiles between 2 positions, will be used to get progress of the paths
function getDistance(posA, posB)
    -- Get the length for each of the components x and y
    local xDist = posB.x - posA.x
    local yDist = posB.y - posA.y

    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) )
end

-- round a number 'num' to 'dp' decimal places. default is 0 (whole number)
local function round(num, dp)
    local mult = 10 ^ (dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

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
--    surface.set_tiles{
--        tiles = {name = config.path_tile, position = self.position}
--    }
    -- set our tile to finish our instruction
    self.last_tick = self.last_tick + action.tick
    --update our timer
end

function PathBuilder:queue_path(position)
    local origin = config.origin
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
        path:add{tick=config.ticks_between_tiles, position={x=x, y=y}}
        return true
    end) 
    -- counter can be used within the callback above as well to get the count as you go
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
    s.always_day = true
end

commands.add_command('createpath', 'test path creation', function(command)
    local player = game.players[command.player_index]
    player.surface.set_tiles{
        tiles = {name = 'concrete', position = player.position}
    }
    PathBuilder:queue_path(player.position)
end)

return PathBuilder