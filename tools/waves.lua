-- local config = require ('config')
local wave_config = require ('wave_config')

local WaveControl = {}

function WaveControl.init_wave(definition)
    local obj = {}
    obj.actions = {}
    obj.index = 1
    obj.last_tick = definition.tick
    if config.logging then
        game.print('Wave initialized')
    end
    return obj
end

function WaveControl.queue(wave, data)
    wave.actions[#wave.actions + 1] = data
end

-- to be used as the handler for on_tick event
function WaveControl.update(wave_index, player_name)
    local wave = global.origins[player_name].waves[wave_index]
    local action = wave.actions[wave.index]
    
    -- is it time to run this instruction yet?
    if game.tick < action.tick + wave.last_tick then return end
    
    wave.index = wave.index + 1
    
    local surface = game.surfaces[config.surface]
    
    if not wave.group then
        local group = surface.create_unit_group{position=global.origins[player_name].position, force=game.forces[config.enemy_force]}
        table.insert(global.origins[player_name].groups, group)
        wave.group = group
    end
    
    if wave.group then
        if wave.group.valid == false then
            local group = surface.create_unit_group{position=global.origins[player_name].position, force=game.forces[config.enemy_force]}
            table.insert(global.origins[player_name].groups, group)
            wave.group = group
        end
        local bug = surface.create_entity{name = action.name, position = _C.safe_position(action.name, global.origins[player_name].position), force = game.forces[config.enemy_force]}
        if bug and bug.valid then
            bug.ai_settings.allow_destroy_when_commands_fail = false
            bug.ai_settings.allow_try_return_to_spawner = false
            wave.group.add_member(bug)
        end
        local creeps = surface.find_entities_filtered{position=global.origins[player_name].position, radius=10, type='unit', force=game.forces[config.enemy_force]}
        if creeps then
            for _, creep in pairs(creeps) do
                if creep.command == nil then
                    wave.group.add_member(creep)
                end
            end
        end
        if #wave.group.members == wave.minimum_gathered then
            if not wave.command then wave.command = {WaveControl.attack_area(global.origins[player_name].target_position)} end
            if wave.command and (wave.group.command == nil) then
                wave.group.set_command
                {
                    type = defines.command.compound,
                    structure_type = defines.compound_command.return_last,
                    commands = wave.command
                }
            end
        end
    end
    --update our timer
    wave.last_tick = wave.last_tick + action.tick
    if wave.index > #wave.actions then
        -- if no more enemies spawning this wave, clear it from global table
        table.remove(global.origins[player_name].waves, wave_index)
        if config.logging then
            -- game.print('Wave complete. '..#global.waves..' left.')
        end
    end
end

function WaveControl.init_player_timer(definition)
    local obj = {}
    obj.actions = {}
    obj.index = 1
    obj.last_tick = definition.tick
    obj.player_name = definition.player_name
    obj.wave = definition.wave or 1
    return obj
end

function WaveControl.queue_player_timer(timer, data)
    timer.actions[#timer.actions + 1] = data
end

function WaveControl.update_player_timers(tick)
    local timers = global.player_timers
    for player_name, timer in pairs(timers) do
        -- get our current instruction
        local action = timer.actions[timer.index]
        
        -- is it time to run this instruction yet?
        if tick < action.tick + timer.last_tick then
            return
        end
        
        timer.index = timer.index + 1
        
        local origin = global.origins[player_name]
        local wave = WaveControl.create_wave(player_name, action.wave, 1)
        if origin.target_position then
            wave.command = {WaveControl.attack_area(origin.target_position)}
        end
        
        timer.last_tick = timer.last_tick + action.tick
        
        if timer.index > #timer.actions then
            local controller = global.origin_controller[player_name].controller
            local control_table = controller['origin_control_table']
            local k = player_name .. '_wave_speed'
            local new_tick = control_table[k].slider_value*60
            k = player_name .. '_wave_difficulty'
            local wave_difficulty = control_table[k].slider_value
            WaveControl.queue_player_timer(timers[player_name], {tick=new_tick, wave=wave_difficulty})
        end
    end
end

function WaveControl.create_wave(player_name, wave_index, multiplier, ticks)
    -- refer to wave_config for pre-made enemy waves that use a numeric index (wave number)
    -- you may also use a bug's name as the index to create a wave of just that bug type
    -- use multiplier to multiply the amounts defined in wave_config for pre-made,
    -- or use it to state how many of the single type enemy if supplying an enemy name
    
    if not global.origins[player_name] then
        game.print('No origin for player '..player_name)
        return
    end
    local surface = game.surfaces[config.surface]
    
    -- here we plug in our enemy table
    local enemies = wave_config[wave_index or 1]
    
    -- create new 'wave' object to keep track of in on_tick
    local wave = WaveControl.init_wave{tick=game.tick} -- trying something new
    table.insert(global.origins[player_name].waves, wave)
    -- if config.logging then
    --     game.print('Wave added to global table')
    --     if wave.group.valid then
    --         game.print('Group still valid inside wave')
    --     else
    --         game.print('Group now invalid inside wave')
    --     end
    -- end
    
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
    wave.minimum_gathered = math.floor(enemy_count*config.percent_bugs_created_before_departing)
    return wave
end

--------------------
-- Group Commands --
--------------------

function WaveControl.attack(target, distraction)
    -- assert(target)
    return {
        type=defines.command.attack,
        target=target,
        distraction=distraction or defines.distraction.none
    }
end

function WaveControl.attack_area(destination, radius, distraction)
    return {
        type=defines.command.attack_area,
        destination=destination,
        radius=radius or 32,
        distraction=distraction or defines.distraction.none
    }
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

--------------------
-- Event handlers --
--------------------

WaveControl.on_init = function()
    global.player_timers = {}
    local enemy_force = game.create_force(config.enemy_force)
    enemy_force.ai_controllable = false
    
    game.write_file('waves.lua', '')
end

local function on_tick()
    for name, origin in pairs(global.origins) do
        if game.players[name] then
            if #global.origins[name].waves > 0 then
                for i, wave in pairs(global.origins[name].waves) do
                    WaveControl.update(i, name)
                end
            end
            if #global.origins[name].groups > 0 then
                for i, group in pairs(global.origins[name].groups) do
                    if (group.valid == false) then
                        table.remove(global.origins[name].groups, i)
                        return
                    end
                end
            end
        end
    end
    if _C.table_length(global.player_timers) > 0 then
        WaveControl.update_player_timers(game.tick)
    end
end

local function on_entity_damaged(event)
    local entity = event.entity
    local cause = event.cause
    local damage = math.floor(event.original_damage_amount)
    local health = math.floor(entity.health)
    local health_percentage = entity.get_health_ratio()
    local text_color = {r = 1 - health_percentage, g = health_percentage, b = 0}
    
    -- Gets the location of the text
    local size = entity.get_radius()
    if size < 1 then size = 1 end
    local r = (math.random() - 0.5) * size * 0.75
    local p = entity.position
    local position = {x = p.x + r, y = p.y - size}
    local cause_types = {'character', 'gun-turret', 'laser-turret', 'flamethrower-turret'}
    local message
    if entity.name == 'character' then
        message = {'damage-popup.player-health', health}
    elseif entity.name ~= 'character' and cause and cause_types[cause.name] then
        message = {'damage-popup.player-damage', damage}
    end
    
    -- Outputs the message as floating text
    if message then
        _C.floating_text(entity.surface, position, message, text_color)
    end

    -- gonna leave this here for a possible feature..turret's damage increases every time it does damage. Only gun-turret is here
    -- possible use: a tech to unlock this for all turrets, a skill with a timer and a cooldown that performs this, then returns to standard damage

    -- if cause and cause.name == "gun-turret" and cause.last_user and has_this_tech_active(cause.last_user.name) then
    --     local player = cause.last_user
    --     player.force.set_ammo_damage_modifier("bullet", player.force.get_ammo_damage_modifier("bullet") + damage * 0.0000001)
    -- end
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
    [defines.events.on_entity_damaged] = on_entity_damaged,
    --testing/logging
    [defines.events.on_unit_group_created] = on_unit_group_created,
    [defines.events.on_unit_added_to_group] = on_unit_added_to_group,
}

-- commands.add_command("creategroup", "/creategroup wave_index multiplier\nTarget is the entity you are hovering\nRefer to wave_config.lua\nRunning with no arguments creates Wave 1\n/creategroup 3 2 would create Wave 3 with double the enemies\n/creategroup medium-biter 5 would create 5 medium biters", function(command)
--     local player = game.players[command.player_index]
--     if not player.admin then
--         player.print('You are not admin')
--         return
--     end
--     if not player.selected then
--         player.print("Error: hover over position to attack")
--         return
--     end

--     local wave_index = 1
--     local multiplier = 1
--     local ticks = 0
--     if command.parameter then
--         local params = command.parameter
--         local args = {}
--         for arg in params:gmatch("%S+") do table.insert(args, arg) end
--         if wave_config[args[1]] then
--             wave_index = args[1]
--         else
--             local try_wave_index = tonumber(args[1])
--             if (type(try_wave_index) == 'number') and (wave_config[try_wave_index]) then
--                 wave_index = try_wave_index
--             end
--         end
--         if args[2] then
--             local try_multiplier = tonumber(args[2])
--             if type(try_multiplier) == 'number' then
--                 multiplier = try_multiplier
--             end
--         end
--         if args[3] then
--             local try_ticks = tonumber(args[3])
--             if type(try_ticks) == 'number' then
--                 ticks = try_ticks
--             end
--         end
--     end
--     local group, wave = WaveControl.create_wave(player.name, wave_index, multiplier, ticks)
--     if group and group.valid then
--         local group_index
--         if player.selected then
--             table.insert(global.td_groups, group)
--             group_index = #global.td_groups
--             wave.command = WaveControl.move_and_attack({player.selected.position}, player.selected)
--             player.print('Group can be accessed via global.td_groups['..group_index..']')
--         else
--             player.print("Error: hover over position to attack")
--         end
--     else
--         player.print('Something happened, no group or group is invalid. Groups are in global.td_groups')
--     end
-- end)

return WaveControl