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
local function get_distance(pos1, pos2)
    local pos1 = {x = pos1.x or pos1[1], y = pos1.y or pos1[2]}
    local pos2 = {x = pos2.x or pos2[1], y = pos2.y or pos2[2]}
    local a = math.abs(pos1.x - pos2.x)
    local b = math.abs(pos1.y - pos2.y)
    local c = math.sqrt(a ^ 2 + b ^ 2)
    return c
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
    surface.set_tiles{
        tiles = {name = config.path_tile, position = self.position}
    }
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
    local multiplier = 1
    -- local remainder_amount = x_tiles > y_tiles and (x_tiles%y_tiles) or (y_tiles%x_tiles)
    local intervals = x_tiles > y_tiles and (x_tiles/y_tiles) or (y_tiles/x_tiles)
    local remainder = 0
    -- local remainder_amount = x_tiles > y_tiles and (x_tiles/y_tiles)-math.floor((x_tiles/y_tiles)) or (y_tiles/x_tiles)-math.floor((y_tiles/x_tiles))
    local path = PathBuilder:new({position = {x = 0, y = 0}, tick = game.tick})
    if x_tiles > y_tiles then
        for n = 1, x_tiles/intervals do
            for i = 1, intervals do
                path:add{tick=config.ticks_between_tiles, positionfunction=x_direction}
                remainder = remainder + (intervals % 1)
                if remainder >= 1 then
                    path:add{tick=config.ticks_between_tiles, positionfunction=x_direction}
                    remainder = remainder - 1
                end
            end
            path:add{tick=config.ticks_between_tiles, positionfunction=y_direction}
        end
    else
        for n = 1, y_tiles/intervals do
            for i = 1, intervals do
                path:add{tick=config.ticks_between_tiles, positionfunction=y_direction}
                remainder = remainder + (intervals % 1)
                if remainder >= 1 then
                    path:add{tick=config.ticks_between_tiles, positionfunction=y_direction}
                    remainder = remainder - 1
                end
            end
            path:add{tick=config.ticks_between_tiles, positionfunction=x_direction}
        end
    end
    table.insert(PathBuilder.paths, path)
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
    local player = game.players[event.player_index]
    player.teleport({0, 0}, game.surfaces['oarc'])
end

PathBuilder.events =
{
    [defines.events.on_tick] = on_tick,
    [defines.events.on_player_created] = on_player_created
}

PathBuilder.on_init = function()
    local s = game.create_surface('oarc')
    s.generate_with_lab_tiles = true
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