local config = require ('config')
local wave_config = require ('wave_config')

local WaveControl = {}

-- functions:
-- WaveControl.create_wave(wave_index, multiplier)
-- WaveControl.move(group, positions)
-- WaveControl.move_and_attack(group, positions)

function WaveControl.create_wave(wave_index, multiplier)
    -- refer to wave_config for pre-made enemy waves that use a numeric index (wave number)
    -- you may also use a bug's name as the index to create a wave of just that bug type
    -- use multiplier to multiply the amounts defined in wave_config for pre-made,
    -- or use it to state how many of the single type enemy if supplying an enemy name
    
    local surface = game.surfaces[config.surface]
    local group = surface.create_unit_group{position=config.origin}
    local enemies = wave_config[wave_index or 1]
    
    for enemy_name, count in pairs(enemies) do
        for i = 1, count do
            for m = 1, (multiplier or 1) do
                local bug = surface.create_entity{name = enemy_name, position = config.origin}
                if bug and bug.valid then
                    bug.ai_settings.allow_destroy_when_commands_fail = false
                    bug.ai_settings.allow_try_return_to_spawner = false
                    if group and group.valid then
                        group.add_member(bug)
                    end
                end
            end
        end
    end
    return group
end

-- function WaveControl.move(group, positions)
--     -- accepts waypoints, so positions should be a table
--     -- if just a single move command just supply a table with the single position
--     -- positions = {{x=100, y=200}}
--     -- issues the compound command, then returns the compound command table

--     local waypoint_commands = {}
--     for i = 1, #positions do
--         table.insert(waypoint_commands,
--         {
--             type=defines.command.go_to_location,
--             destination=positions[i],
--             distraction=defines.distraction.none
--         })
--     end
--     group.set_command
--     {
--         type = defines.command.compound,
--         structure_type = defines.compound_command.return_last,
--         commands = waypoint_commands
--     }
--     group.force = game.forces['enemy']
--     return waypoint_commands
-- end

function WaveControl.move_and_attack(group, positions, target)
    -- group: LuaUnitGroup
    -- positions: a table. accepts waypoints, so positions should be a table
    -- if just a single move command just supply a table with the single position
    -- target: LuaEntity. must be an entity, not a position
    -- creates and issues a compound command to the group
    -- will move to all the positions in order
    -- if a target is supplied, an attack command is added to the end
    -- returns the compound command table
    
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
    group.set_command
    {
        type = defines.command.compound,
        structure_type = defines.compound_command.return_last,
        commands = waypoint_commands
    }

    return waypoint_commands
end

function WaveControl.get_position(group)
    return group.position
end

WaveControl.on_init = function()
    global.td_groups = {}
end

commands.add_command("creategroup", "/creategroup wave_index multiplier\nRefer to wave_config.lua\nRunning with no arguments creates Wave 1\n/creategroup 3 2 would create Wave 3 with double the enemies\n/creategroup medium-biter 5 would create 5 medium biters", function(command)
    local player = game.players[command.player_index]
    if not player.admin then
        player.print('You are not admin')
        return
    end
    local wave_index = 1
    local multiplier = 1
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
    end
    local group = WaveControl.create_wave(wave_index, multiplier)
    if group and group.valid then
        table.insert(global.td_groups, group)
        local group_index = #global.td_groups
        if player.selected then
            WaveControl.move_and_attack(group, {player.selected.position}, player.selected)
        end
        player.print('Group can be accessed via global.td_groups['..group_index..']')
    else
        player.print('Something happened, no group or group is invalid. Groups are in global.td_groups')
    end
end)


return WaveControl