local config = require ('config')
local wave_config = require ('wave_config')

local WaveControl = {}

-- functions:
-- WaveControl.init_wave(definition)
---- create and return the table to hold the data of the wave, such as what is spawned and when
------ 'definition' is a table containing the current tick and the group that enemies will be added to
-- usage:
---- WaveControl.init_wave{tick=game.tick, group=LuaGroup}

-- WaveControl.queue(wave, data)
---- add an enemy creation instruction to our wave table
------ 'wave' is the wave table returned by init_wave()
------ 'data' is a table containing creation info, including the enemy name and how many ticks until creation
-- usage:
---- WaveControl.queue(wave, {tick=60, name='small-biter'})

-- WaveControl.create_wave(wave_index, multiplier, ticks)
---- combines the 2 previous functions, so that you can supply an index for a wave composition,
---- the optional multiplier to increase the amount of enemies, and the ticks between spawns
------ 'wave_index' (optional) is the key (or index) to use from the table that wave_config.lua returns
------ default: '1' (wave 1 or entry [1] in the wave_config table)
------ 'multiplier' (optional) is what the enemy counts will be multiplied by
------ default: '1' (1*count)
------ 'ticks' (optional) is the number of ticks to wait between spawning enemies.
------ this value is ignored if the enemy already has a tick value that isn't 0 in wave_config
------ this means if your pre-gen wave already has ticks assigned (not 0), they will still be used
------ default: '0' (instant)
-- usage:
---- if a pre-gen wave is desired:
---- WaveControl.create_wave(3, 2)
------ this would create Wave 3 (entry [3] in wave_config table) with 2x enemies
------ [3] = {{name='medium-biter', count = 10, tick = 60}, {name='big-biter', count = 5, tick = 120}}
------ Wave 3 with 'multiplier' 2 is 20 medium biters, spawned 60 ticks (1s) apart,
------ then 10 big biters, spawned 120 ticks (2s) apart
---- if a single enemy type is desired:
---- WaveControl.create_wave('big-biter', 20)
------ this would create 20 big biters

-- WaveControl.move_and_attack(group, positions, target)
---- issue a move and/or move+attack command
------ 'group' is the LuaGroup to issue the commands to
------ 'positions' is a table of positions. to use a single position, supply a table with a single entry
------ 'target' (optional) is a LuaEntity that the group will attack after moving to all positions
-- usage:
---- single move:
------ WaveControl.move_and_attack(LuaGroup, {{x=100, y=200}})
---- waypoint move:
------ WaveControl.move_and_attack(LuaGroup, {{x=100, y=200}, {x=150, y=250}})
---- single move and attack:
------ WaveControl.move_and_attack(LuaGroup, {{x=100, y=200}}, LuaEntity)
---- waypoint move and attack:
------ WaveControl.move_and_attack(LuaGroup, {{x=100, y=200}, {x=150, y=250}}, LuaEntity)


function WaveControl.init_wave(definition)
    local obj = {}
    obj.actions = {}
    obj.index = 1
    obj.last_tick = definition.tick
    obj.group = definition.group
    obj.player_name = definition.player_name
    if config.logging then
        game.print('Wave initialized')
    end
    return obj
end

function WaveControl.queue(wave, data)
    wave.actions[#wave.actions + 1] = data
end

-- to be used as the handler for on_tick event
function WaveControl.update(tick)
    local waves = global.waves
    for i, wave in pairs(waves) do
        -- get our current instruction
        local action = wave.actions[wave.index]
        
        -- is it time to run this instruction yet?
        if tick < action.tick + wave.last_tick then return end
        
        wave.index = wave.index + 1
        
        local surface = game.surfaces[config.surface]
        
        if wave.group then
            if wave.group.valid == false then
                local surface = game.surfaces[config.surface]
                wave.group = surface.create_unit_group{position=global.player_origins[wave.player_name].position, force=game.forces[config.enemy_force]}
                if wave.command and (wave.group.command == nil) then
                    wave.group.set_command
                    {
                        type = defines.command.compound,
                        structure_type = defines.compound_command.return_last,
                        commands = wave.command
                    }
                end
            end
            if wave.group.valid then
                local bug = surface.create_entity{name = action.name, position = global.player_origins[wave.player_name].position, force = game.forces[config.enemy_force]}
                if bug and bug.valid then
                    _C.safe_teleport(bug, global.player_origins[wave.player_name].position)
                    bug.ai_settings.allow_destroy_when_commands_fail = false
                    bug.ai_settings.allow_try_return_to_spawner = false
                    wave.group.add_member(bug)
                end
                if #wave.group.members == wave.minimum_gathered then
                    wave.group.set_command
                    {
                        type = defines.command.compound,
                        structure_type = defines.compound_command.return_last,
                        commands = wave.command
                    }
                end
            else
                game.print("Wave's group is nil or invalid at wave.index "..wave.index..". (reference to the wave: global.waves["..i.."])")
            end
        end
        
        --update our timer
        wave.last_tick = wave.last_tick + action.tick
        if wave.index > #wave.actions then
            -- if no more enemies spawning this wave, clear it from global table
            table.remove(global.waves, i)
            if config.logging then
                game.print('Wave complete. '..#global.waves..' left.')
            end
        end
    end
end

function WaveControl.create_wave(player_name, wave_index, multiplier, ticks)
    -- refer to wave_config for pre-made enemy waves that use a numeric index (wave number)
    -- you may also use a bug's name as the index to create a wave of just that bug type
    -- use multiplier to multiply the amounts defined in wave_config for pre-made,
    -- or use it to state how many of the single type enemy if supplying an enemy name
    
    if not global.player_origins[player_name] then
        game.print('No origin for player '..player_name)
        return
    end
    local surface = game.surfaces[config.surface]
    local group = surface.create_unit_group{position=global.player_origins[player_name].position, force=game.forces[config.enemy_force]}
    if config.logging then
        game.print('Group created')
    end
    -- here we plug in our enemy table
    local enemies = wave_config[wave_index or 1]
    
    -- create new 'wave' object to keep track of in on_tick
    local wave = WaveControl.init_wave{tick=game.tick, group=group, player_name=player_name} -- trying something new
    table.insert(global.waves, wave)
    if config.logging then
        game.print('Wave added to global table')
        if wave.group.valid then
            game.print('Group still valid inside wave')
        else
            game.print('Group now invalid inside wave')
        end
    end
    
    local enemy_count = 0
    for index, enemy in pairs(enemies) do
        for i = 1, enemies[index].count do
            for m = 1, (multiplier or 1) do
                WaveControl.queue(wave, {tick=((enemies[index].tick == 0) and ticks or enemies[index].tick), name=enemies[index].name})
                -- 'tick' above is a ternary condition
                -- it says if enemies[i].tick == 0 then use 'ticks' value set above,
                -- otherwise use what is set in enemies[i].tick
                enemy_count = enemy_count + 1
            end
        end
    end
    wave.minimum_gathered = math.floor(enemy_count*config.percent_bugs_created_before_command)
    return group, wave
end

function WaveControl.move_and_attack(positions, target)
    -- positions: a table. accepts waypoints, so positions should be a table
    -- if just a single move command just supply a table with the single position
    -- target (optional): LuaEntity. must be an entity, not a position
    -- creates and returns a compound command table for a group
    -- will move to all the positions in order
    -- if a target is supplied, an attack command is added to the end
    
    local waypoint_commands = {}
    for i = 1, #positions do
        table.insert(waypoint_commands,
        {
            type=defines.command.go_to_location,
            destination=positions[i],
            distraction=defines.distraction.none
        })
    end
    if target then
        table.insert(waypoint_commands,
        {
            type=defines.command.attack,
            target=target,
            distraction=defines.distraction.none
        })
    end
    -- usage:
    -- group.set_command
    -- {
    --     type = defines.command.compound,
    --     structure_type = defines.compound_command.return_last,
    --     commands = WaveControl.move_and_attack(positions, target)
    -- }
    return waypoint_commands
end

WaveControl.on_init = function()
    global.td_groups = {}
    global.waves = {}
    local enemy_force = game.create_force(config.enemy_force)
    enemy_force.ai_controllable = false
    
    game.write_file('waves.lua', '')
end

local function on_tick()
    if #global.waves > 0 then
        WaveControl.update(game.tick)
    end
    if #global.td_groups > 0 then
        for i, group in pairs(global.td_groups) do
            if (group.valid == false) then
                table.remove(global.td_groups, i)
                return
            end
            -- if (group.command == nil) then
            --     for _, bug in pairs(group.members) do
            --         bug.destroy()
            --     end
            --     group.destroy()
            --     table.remove(global.td_groups, i)
            -- end
        end
    end
end

-- testing/logging
local function format_info(title, value)
    local s = '[color=blue]'..title..':[/color] [color=green]'..value..'[/color]'
    return s
end
local function get_group_info(group)
    if group and group.valid then
        game.print('[color=orange]Info for Group [/color][color=blue]'..group.group_number..'[/color]:')
        game.print(format_info('Position', serpent.line(group.position)))
        game.print(format_info('Members', #group.members))
        game.print(format_info('State', group.state))
        game.print(format_info('Command', serpent.line(group.command)))
    end
end
local function on_unit_group_created(event)
    if config.logging then
        game.print('[color=orange]Event Trigger:[/color] [color=blue][on_unit_group_created][/color]')
    end
end
local function on_unit_added_to_group(event)
    if config.logging then
        game.print('[color=orange]Event Trigger:[/color] [color=blue][on_unit_added_to_group][/color]')
        local unit = event.unit
        local group = event.group
        game.print({'', '[color=blue]Unit: [/color][color=green]', unit.localised_name, '[/color] [color=blue]Group: [/color][color=green]', group.group_number, '[/color]'})
        get_group_info(group)
    end
end
-- end testing/logging

WaveControl.events =
{
    [defines.events.on_tick] = on_tick,
    --testing/logging
    [defines.events.on_unit_group_created] = on_unit_group_created,
    [defines.events.on_unit_added_to_group] = on_unit_added_to_group,
}

commands.add_command("creategroup", "/creategroup wave_index multiplier\nTarget is the entity you are hovering\nRefer to wave_config.lua\nRunning with no arguments creates Wave 1\n/creategroup 3 2 would create Wave 3 with double the enemies\n/creategroup medium-biter 5 would create 5 medium biters", function(command)
    local player = game.players[command.player_index]
    if not player.admin then
        player.print('You are not admin')
        return
    end
    if not player.selected then
        player.print("Error: hover over position to attack")
        return
    end
    
    local wave_index = 1
    local multiplier = 1
    local ticks = 0
    if command.parameter then
        local params = command.parameter
        local args = {}
        for arg in params:gmatch("%S+") do table.insert(args, arg) end
        if wave_config[args[1]] then
            wave_index = args[1]
        else
            local try_wave_index = tonumber(args[1])
            if (type(try_wave_index) == 'number') and (wave_config[try_wave_index]) then
                wave_index = try_wave_index
            end
        end
        if args[2] then
            local try_multiplier = tonumber(args[2])
            if type(try_multiplier) == 'number' then
                multiplier = try_multiplier
            end
        end
        if args[3] then
            local try_ticks = tonumber(args[3])
            if type(try_ticks) == 'number' then
                ticks = try_ticks
            end
        end
    end
    local group, wave = WaveControl.create_wave(player.name, wave_index, multiplier, ticks)
    if group and group.valid then
        local group_index
        if player.selected then
            table.insert(global.td_groups, group)
            group_index = #global.td_groups
            wave.command = WaveControl.move_and_attack({player.selected.position}, player.selected)
            player.print('Group can be accessed via global.td_groups['..group_index..']')
        else
            player.print("Error: hover over position to attack")
        end
    else
        player.print('Something happened, no group or group is invalid. Groups are in global.td_groups')
    end
end)

return WaveControl