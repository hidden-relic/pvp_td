local PathBuilder =
{
    paths = {}
}

local config =
{
    surface = 'oarc',
    path_tile = 'landfill',
    ticks_between_tiles = 1
}

-- position functions to return a position relative to a position
local function down(position) return {x=position.x, y=position.y + 1} end
local function right(position) return {x=position.x + 1, y=position.y} end
local function up(position) return {x=position.x, y=position.y - 1} end
local function left(position) return {x=position.x - 1, y=position.y} end

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
    self.position = action.positionfunction(self.position)
    -- update our position using the given position function in this instruction
    local surface = game.surfaces[config.surface]
--    surface.set_tiles{
--        tiles = {name = config.path_tile, position = self.position}
--    }
    -- set our tile to finish our instruction
    self.last_tick = self.last_tick + action.tick
    --update our timer
end

function PathBuilder:queue_path(position)
    local x_tiles = math.abs(position.x)
    local y_tiles = math.abs(position.y)
    -- getting our number of steps on each axis. because our origin is 0, 0 we don't have to math
    local x_direction = position.x > 0 and right or left
    local y_direction = position.y > 0 and down or up
    -- get our position functions setup. if a positive x or y, we're heading right or down, respectfully
    local intervals = x_tiles > y_tiles and (x_tiles/y_tiles) or (y_tiles/x_tiles)
    -- determine on which axis the length is largest
    -- and divide the larger axis by the smaller to get our ratio
    local remainder = 0
    
    local path = PathBuilder:new({position = {x = 0, y = 0}, tick = game.tick})
    -- create a new path origin
    if x_tiles > y_tiles then
        -- if we need more x than y (larger x than y length)
        for n = 1, x_tiles/intervals do
            -- divide our long side by our ratio to get iteration count
            for i = 1, intervals do
                path:add{tick=config.ticks_between_tiles, positionfunction=x_direction}
                -- queue our burst of x axis tiles
                remainder = remainder + (intervals % 1)
                -- add our remainder
                if remainder >= 1 then
                    path:add{tick=config.ticks_between_tiles, positionfunction=x_direction}
                    -- if remainder is over 1, do another tile in the burst
                    remainder = remainder - 1
                    -- remove the 1 from our remainder
                end
            end
            path:add{tick=config.ticks_between_tiles, positionfunction=y_direction}
            -- queue our other axis
        end
    else
        -- if we need more y than x (larger y than x length)
        for n = 1, y_tiles/intervals do
            -- divide our long side by our ratio to get iteration count
            for i = 1, intervals do
                path:add{tick=config.ticks_between_tiles, positionfunction=y_direction}
                -- queue our burst of y axis tiles
                remainder = remainder + (intervals % 1)
                -- add our remainder
                if remainder >= 1 then
                    path:add{tick=config.ticks_between_tiles, positionfunction=y_direction}
                    -- if remainder is over 1, do another tile in the burst
                    remainder = remainder - 1
                    -- remove the 1 from our remainder
                end
            end
            path:add{tick=config.ticks_between_tiles, positionfunction=x_direction}
            -- queue our other axis
        end
    end
    table.insert(PathBuilder.paths, path)
    -- add our path origin to the global table to be accessed later
    return path
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