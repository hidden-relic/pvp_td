-- local td_gui = require('tools.td_gui')
local config = require ('config')
local wave_config = require ('wave_config')

local EnemyBuilder = {}

-- New Enemy Builder obj
function EnemyBuilder.create_obj(definition)
    local obj = {}
    obj.actions = {}
    obj.index = 1
    obj.position = definition.position
    obj.last_tick = definition.tick
    obj.target = {}
    obj.waypoints = {}
    obj.wave = 1
    obj.next_wave_time = 0
    return obj
end

function EnemyBuilder.queue(group, builddata)
    group.actions[#group.actions + 1] = builddata
end

-- In:     Tick - tick to up on
-- Result: Draw a path setup in group
function EnemyBuilder.update(tick)
    if global.td_waves then
        local waves = global.td_waves
        for wave_index, wave in pairs(waves) do
            if wave.index > #wave.actions then return end
            local action = wave.actions[wave.index]
            if tick < action.tick + wave.last_tick then return end
            
            -- perform action
            wave.position = wave.position
            wave.index = wave.index + 1
            local surface = game.surfaces[config.surface]
            local bug = surface.create_entity{name=action.name, position=wave.position, force='neutral'}
            --     local waypoint_commands = {}
            --     for i = 1, #action.waypoints, 10 do
            --         local command =
            --         {
            --             type=defines.command.go_to_location,
            --             destination=action.waypoints[i],
            --             distraction=defines.distraction.none
            --         }
            --         table.insert(waypoint_commands, command)
            --     end
            --     table.insert(waypoint_commands,
            --     {
            --         type=defines.command.attack,
            --         target=action.target,
            --         distraction=defines.distraction.none
            --     })
            --     bug.set_command
            --     {
            --         type = defines.command.compound,
            --         structure_type = defines.compound_command.return_last, 
            --         commands = waypoint_commands
            --     }
            --     bug.force = game.forces['enemy']
            --     group.last_tick = group.last_tick + action.tick
        end
    end
end



function EnemyBuilder.create_wave(target_position, wave_data)
    -- target_position should be a position, so bugs aren't potentially chasing a character around,
    -- and won't have any issues with not having a target after destroying an entity target
    -- ... for now.
    
    -- wave data should be a table, like this:
    -- wave_data =
    -- {
    --     index = 2,                   -- the index from the table in wave_config
    --     multiplier = 1,              -- multiplier to use on the enemy counts in wave_config
    --     ticks_between_spawns = 30    -- ticks between each enemy spawn (negating possible lag spike)
    -- }
    
    local origin = config.origin
    local wave = EnemyBuilder.create_obj({position = origin, tick = game.tick, target = target_position})
    table.insert(global.enemy_groups, wave)
    -- create an EnemyBuilder instance
    -- keep track of instance for on_tick handler
    
    local data =
    {
        index = wave_data.index or 1,
        multiplier = wave_data.multiplier or 1,
        ticks_between_spawns = wave_data.ticks_between_spawns or 15
    }

    local group = game.surfaces[config.surface].create_unit_group(origin)
    
    local enemies = wave_config[data.index]
    local total_count = 0
    for enemy_name, count in pairs(enemies) do
        for i = 1, count do
            EnemyBuilder.queue(wave, {name = enemy_name, tick = data.ticks_between_spawns, target = target_position})
            total_count = total_count + 1
        end
    end
    
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