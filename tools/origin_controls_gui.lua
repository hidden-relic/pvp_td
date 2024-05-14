local mod_gui = require ('mod-gui')
local guilib = require ('guilib')

local origin_controls = {}

----------------------------------
-- initializing the top buttons --
----------------------------------

local function init_warning_button(player)
    -- the warning button for all players
    local button_flow = mod_gui.get_button_flow(player)
    local warning_button = button_flow.add
    {
        name = 'warning_control_button',
        type = 'sprite-button',
        sprite = 'entity/medium-biter',
        -- number = market.balance,
        -- tooltip = '[item=coin] ' .. tools.add_commas(market.balance)
    }
    return warning_button
end

local function init_origin_control_button(player)
    -- the origin controller button for admin
    local button_flow = mod_gui.get_button_flow(player)
    local origin_control_button = button_flow.add
    {
        name = 'origin_control_button',
        type = 'sprite-button',
        sprite = 'entity/biter-spawner',
        -- number = market.balance,
        -- tooltip = '[item=coin] ' .. tools.add_commas(market.balance)
    }
    return origin_control_button
end

---------------------------------
-- initializing controller gui --
---------------------------------

local function create_headers(controls_table)
    local headers =
    {
        'Player Name',
        'Origin Health',
        'Origin Position',
        'Path Toggle',
        'Path Speed (ticks)',
        'Path Progress',
        'Origin Difficulty',
        'Origin Speed (secs)'
    }
    for _, header in pairs(headers) do
        local head = controls_table.add
        {
            type = 'label',
            caption = header,
        }
        head.style.horizontal_align = 'center'
        head.style.single_line = false
    end
end

local function populate_controller_table(controls_table)
    
    controls_table.clear()
    create_headers(controls_table)
    for player_name, origin in pairs(global.origins) do
        if game.players[player_name] then
            controls_table.add
            {
                type = 'label',
                caption = player_name
            }
            controls_table.add
            {
                name = player_name .. '_spawner_health',
                type = 'progressbar',
                style = 'health_progressbar',
                value = global.origins[player_name].spawner.get_health_ratio()
            }
            controls_table.add
            {
                type = 'label',
                caption = serpent.line(global.origins[player_name].spawner.position)
            }
            controls_table.add
            {
                name = player_name .. '_path_switch',
                type = 'switch'
            }
            controls_table.add
            {
                name = player_name .. '_path_speed',
                type = 'slider',
                minimum_value = 1,
                maximum_value = 600,
                value = 60
            }
            controls_table.add
            {
                name = player_name .. '_path_progress',
                type = 'progressbar',
                value = 0
            }
            controls_table.add
            {
                name = player_name .. '_wave_difficulty',
                type = 'slider',
                minimum_value = 1,
                maximum_value = 5,
                value = 1
            }
            controls_table.add
            {
                name = player_name .. '_wave_speed',
                type = 'slider',
                minimum_value = 1,
                maximum_value = 600,
                value = 300
            }
        end
    end
end

local function init_origin_control_gui(player)
    global.origin_controller[player.name] = {}
    local frame, container = guilib.create_window(player.gui.screen, 'vertical', 'Origin Controller')
    global.origin_controller[player.name].frame = frame
    global.origin_controller[player.name].controller = container
    local controls_table = container.add
    {
        type = 'table',
        name = 'origin_control_table',
        column_count = 8,
        draw_horizontal_line_after_headers = true,
        style = 'technology_slot_table'
    }
    create_headers(controls_table)
    populate_controller_table(controls_table)
    return container
end


----------------------
-- updating the gui --
----------------------

local function origin_controller_update(player)
    local controller = global.origin_controller[player.name].controller
    local control_table = controller['origin_control_table']
    for player_name, origin in pairs(global.origins) do
        local k = player_name..'_spawner_health'
        if control_table[k] then
            if global.origins[player_name].spawner and global.origins[player_name].spawner.valid then
                control_table[k].value = global.origins[player_name].spawner.get_health_ratio()
            end
        end
        k = player_name..'_path_progress'
        if control_table[k] then
            for i, path in pairs(global.origins[player.name].paths) do
                control_table[k].value = _C.round((global.origins[player.name].paths[i].index/#global.origins[player.name].paths[i].actions), 2) or 0
            end
        end
    end
end

-----------------
-- wrap it up! --
-----------------

function origin_controls.create_origin_controls(player)
    if global.origins[player.name] then
        init_warning_button(player)
        if player.admin then
            init_origin_control_button(player)
            init_origin_control_gui(player)
        end
        origin_controller_update(player)
    end
end

-------------------------------------------
-- handling the toggle of the top button --
-------------------------------------------

local function close_origin_controls_gui(player)
    local controller_frame = global.origin_controller[player.name].frame
    if (controller_frame == nil) then return end
    controller_frame.visible = false
    player.opened = nil
end

local function open_origin_controls_gui(player)
    local controller_frame = global.origin_controller[player.name].frame
    controller_frame.visible = true
    player.opened = controller_frame
end

local function toggle_origin_controls_gui(player)
    local controller_frame = global.origin_controller[player.name].frame
    origin_controller_update(player)
    if controller_frame.visible then
        close_origin_controls_gui(player)
    else
        open_origin_controls_gui(player)
    end
end

--------------------
-- event handlers --
--------------------

function origin_controls.on_init()
    global.origin_controller = {}
end

local function on_gui_selection_state_changed(event)
    local player = game.players[event.player_index]
    local element = event.element
    local controller = global.origin_controller[player.name].controller
    control_table = controller['origin_control_table']
    if element == control_table['table_dd'] then
        control_table.style = element.get_item(element.selected_index)
    end
end

local function on_gui_value_changed(event)
    local player = game.players[event.player_index]
    local controller = global.origin_controller[player.name].controller
    control_table = controller['origin_control_table']
    local element = event.element
    local k = player.name .. '_path_speed'
    if element == control_table[k] then
        for i, path in pairs(global.paths) do
            if path.player_name == player.name then
                local path = global.paths[i]
                for j, action in pairs(path.actions) do
                    path.actions[j].tick = control_table[k].slider_value
                end
            end
        end
    end
    local k = player.name .. '_wave_difficulty'
    if element == control_table[k] then
        for i, path in pairs(global.paths) do
            if path.player_name == player.name then
                local path = global.paths[i]
                for j, action in pairs(path.actions) do
                    path.actions[j].tick = control_table[k].slider_value
                end
            end
        end
    end
    local k = player.name .. '_wave_speed'
    if element == control_table[k] then
        for i, path in pairs(global.paths) do
            if path.player_name == player.name then
                local path = global.paths[i]
                for j, action in pairs(path.actions) do
                    path.actions[j].tick = control_table[k].slider_value
                end
            end
        end
    end
end


local function on_gui_click(event)
    local player = game.players[event.player_index]
    local button_flow = mod_gui.get_button_flow(player)
    local element = event.element
    if element == button_flow['origin_control_button'] then
        toggle_origin_controls_gui(player)
    end
end

local function on_tick()
    for player_name, controller in pairs(global.origin_controller) do
        origin_controller_update(game.players[player_name])
    end
end

-- local function on_nth_tick()
--     for player_name, controller in pairs(global.origin_controller) do
--         origin_controller_update(game.players[player_name])
--     end
-- end

origin_controls.events =
{
    [defines.events.on_gui_click] = on_gui_click,
    [defines.events.on_gui_value_changed] = on_gui_value_changed,
    [defines.events.on_tick] = on_tick,
    [defines.events.on_gui_selection_state_changed] = on_gui_selection_state_changed,
    -- [defines.events.on_player_created] = on_player_created
}

return origin_controls