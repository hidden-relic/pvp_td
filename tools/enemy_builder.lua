-- local td_gui = require('tools.td_gui')

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
    ticks_between_waves = 60*2,
    origin = {x=0, y=0},
    enemies_in_wave = 5,
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
    obj.player = definition.player
    obj.target = {}
    obj.waypoints = {}
    obj.wave = 1
    obj.next_wave_time = 0
    obj.enemies =
    {
        {
            'small-biter',
        },
        {
            'small-biter',
            'small-biter'
        },
        {
            'small-biter',
            'small-biter',
            'small-biter'
        },
        {
            'small-biter',
            'small-biter',
            'small-biter',
            'small-biter'
        },
        {
            'small-biter',
            'small-biter',
            'small-biter',
            'small-biter',
            'medium-biter'
        },
        {
            'small-biter',
            'small-biter',
            'small-biter',
            'small-biter',
            'medium-biter',
            'medium-biter'
        },
        {
            'small-biter',
            'small-biter',
            'small-biter',
            'small-biter',
            'medium-biter',
            'medium-biter',
            'medium-biter'
        },
        {
            'small-biter',
            'small-biter',
            'small-biter',
            'small-biter',
            'medium-biter',
            'medium-biter',
            'medium-biter',
            'medium-biter'
        },
        {
            'small-biter',
            'small-biter',
            'medium-biter',
            'medium-biter',
            'medium-biter',
            'medium-biter',
            'big-biter',
            'big-biter'
        },
        {
            'small-biter',
            'small-biter',
            'medium-biter',
            'medium-biter',
            'big-biter',
            'big-biter',
            'big-biter',
            'big-biter'
        },
        {
            'small-biter',
            'small-biter',
            'medium-biter',
            'medium-biter',
            'big-biter',
            'big-biter',
            'behemoth-biter',
            'behemoth-biter'
        },
        {
            'small-biter',
            'small-biter',
            'small-biter',
            'small-biter',
            'medium-biter',
            'medium-biter',
            'medium-biter',
            'medium-biter',
            'big-biter',
            'big-biter',
            'big-biter',
            'big-biter',
            'behemoth-biter',
            'behemoth-biter',
            'behemoth-biter',
            'behemoth-biter'
        }
    }
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
    local waypoint_commands = {}
    for i = 1, #action.waypoints, 10 do
        local command =
        {
            type=defines.command.go_to_location,
            destination=action.waypoints[i],
            distraction=defines.distraction.none
        }
        table.insert(waypoint_commands, command)
    end
    table.insert(waypoint_commands,
    {
        type=defines.command.attack,
        target=action.target,
        distraction=defines.distraction.none
    })
    bug.set_command
    {
        type = defines.command.compound,
        structure_type = defines.compound_command.return_last, 
        commands = waypoint_commands
    }
    bug.force = game.forces['enemy']
    self.last_tick = self.last_tick + action.tick
end

function EnemyBuilder:set_enemies(enemies)
    self.enemies = enemies
end

function EnemyBuilder:get_enemies()
    return self.enemies
end

function EnemyBuilder:set_wave(wave)
    self.wave = wave
end

function EnemyBuilder:get_wave()
    return self.wave
end

function EnemyBuilder:set_tick(tick)
    self.last_tick = tick
end

function EnemyBuilder:get_tick()
    return self.last_tick
end

function EnemyBuilder:set_next_wave_time(tick)
    self.next_wave_time = tick
end

function EnemyBuilder:get_next_wave_time()
    return self.next_wave_time
end

function EnemyBuilder:set_target(target)
    self.target = target
end

function EnemyBuilder:get_target()
    return self.target
end

function EnemyBuilder:set_waypoints(waypoints)
    self.waypoints = waypoints
end

function EnemyBuilder:get_waypoints()
    return self.waypoints
end

function EnemyBuilder:set_player(player)
    self.player = player
end

function EnemyBuilder:get_player()
    return self.player
end

function EnemyBuilder:create_wave(target, waypoints, player, wave)
    local origin = config.origin
    local wave = wave or EnemyBuilder:new({position = origin, tick = game.tick, player = player})
    wave:set_target(target)
    wave:set_waypoints(waypoints)
    local enemies = wave:get_enemies()
    local wave_ticks = 0
    -- wave:set_tick(game.tick+wave_ticks)
    -- create an EnemyBuilder instance
    table.insert(EnemyBuilder.waves, wave)
    -- keep track of instance for on_tick handler
    
    if config.logging then
        game.write_file('waves.lua', 'Wave '..wave:get_wave()..'\n', true)
    end

    -- game.print('Wave [color=red]'..wave:get_wave()..'[/color] @'..game.tick)
    
    for i = 1, config.enemies_in_wave do
        for _, enemy in pairs(enemies[wave:get_wave()]) do
            if wave:get_target() and wave:get_target().valid then
                if config.logging then
                    game.write_file('waves.lua', enemy..' @'..game.tick..'\n', true)
                end
                wave:add({name = enemy, tick = config.ticks_between_enemies, target = wave:get_target(), waypoints = wave:get_waypoints(), player = wave:get_player()})
                wave_ticks = wave_ticks + config.ticks_between_enemies
            else return end
        end
    end
    wave:set_wave(wave:get_wave()+1)
    if #wave:get_enemies() >= wave:get_wave() then
        wave:set_next_wave_time(game.tick+wave_ticks+config.ticks_between_waves)
        if config.logging then
            game.write_file('waves.lua', 'Next wave time: '..wave:get_next_wave_time()..'\n', true)
        end
    end
end

local function on_tick()
    if #EnemyBuilder.waves > 0 then
        for _, wave in pairs(EnemyBuilder.waves) do
            wave:update(game.tick)
            if (wave:get_next_wave_time() > 0) and (game.tick >= wave:get_next_wave_time()) then
                wave:set_next_wave_time(0)
                EnemyBuilder:create_wave(wave:get_target(), wave:get_waypoints(), wave:get_player(), wave)
            end
        end
    end
end

EnemyBuilder.events =
{
    [defines.events.on_tick] = on_tick
}

return EnemyBuilder