local EnemyBuilder =
{
    waves = {}
}

-- usage:
-- local EnemyBuilder = require('tools.enemy_builder')
-- -- require the file to get the builder methods under the name EnemyBuilder

-- local spawner = EnemyBuilder:new({position={x=0, y=0}, tick=game.tick})
-- -- create an instance, supplying the spawn position and the tick to start counting from.

-- -- if you don't plan on immediately using the instance's addbuild method,
-- -- reset the tick before you do use it so it knows where to begin counting from:
-- spawner.last_tick = game.tick
-- -- resetting the counter

-- spawner:addbuild{tick=60, name="small-biter"}
-- -- will spawn a small biter 60 ticks from spawner.last_tick

-- -- chain together a wave:
-- for i = 1, 10 do
--     spawner:addbuild{tick=60, name="small-biter"}
-- end
-- -- this will spawn 10 small biters in a row, 60 ticks apart

local config =
{
    surface = 'oarc',
    ticks_between_enemies = 20,
    origin = {x=0, y=0},
    logging = false
}

-- Initialize 
function EnemyBuilder:new(definition)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.actions = {}
    obj.index = 1
    obj.position = definition.position
    obj.last_tick = definition.tick
    return obj
end

function EnemyBuilder:add(builddata)
    self.actions[#self.actions + 1] = builddata
end

-- In:     Tick - tick to up on
-- Result: Draw a path setup in self
function EnemyBuilder:update(tick)
    if self.index > #self.actions then return end
    local action = self.actions[self.index]
    if tick < action.tick + self.last_tick then return end
    
    -- perform action
    self.position = self.position
    self.index = self.index + 1
    local surface = game.surfaces[config.surface]
    local bug = surface.create_entity{name=action.name, position=self.position, direction=action.direction, force='neutral'}
    bug.set_command
    {
        type = defines.command.compound,
        structure_type = defines.compound_command.return_last, 
        commands = 
        {
            {type=defines.command.go_to_location, destination=action.target.position, distraction=defines.distraction.none},
            {type=defines.command.attack, target=action.target}
        }
    }
    bug.force = game.forces['enemy']
    self.last_tick = self.last_tick + action.tick
end

function EnemyBuilder:create_wave(target)
    local origin = config.origin
    local wave = EnemyBuilder:new({position = origin, tick = game.tick})
    -- create an EnemyBuilder instance
    table.insert(EnemyBuilder.waves, wave)
    -- keep track of instance for on_tick handler
    for i = 1, 25 do
        if target and target.valid then
            wave:add({name = 'small-biter', tick = config.ticks_between_enemies, target = target})
        else return end
    end
end

commands.add_command('createwave', '', function(command)
    local player = game.players[command.player_index]
    if player.selected then
        EnemyBuilder:create_wave(player.selected)
    end
end)

local function on_tick()
    if #EnemyBuilder.waves > 0 then
        for _, wave in pairs(EnemyBuilder.waves) do
            wave:update(game.tick)
        end
    end
end

EnemyBuilder.events =
{
    [defines.events.on_tick] = on_tick
}

return EnemyBuilder