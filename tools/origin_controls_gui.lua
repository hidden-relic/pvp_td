local mod_gui = require ('mod-gui')

-------------------------------------------
-- THIS FILE IS INCOMPLETE, DO NOT USE!! --
-------------------------------------------

local function init_warning_button(player)
    local button_flow = mod_gui.get_button_flow(player)
    local warning_button = button_flow.add
    {
        name = 'warning_control_button',
        type = 'sprite-button',
        sprite = 'entity/medium-biter',
        -- number = market.balance,
        -- tooltip = '[item=coin] ' .. tools.add_commas(market.balance)
    }
end

local function init_origin_control_button(player)
    local button_flow = mod_gui.get_button_flow(player)
    local origin_control_button = button_flow.add
    {
        name = 'origin_control_button',
        type = 'sprite-button',
        sprite = 'entity/biter-spawner',
        -- number = market.balance,
        -- tooltip = '[item=coin] ' .. tools.add_commas(market.balance)
    }
end

local function init_origin_control_gui(player)
    local center = 
end

function init_origin_controls(player)
    if global.player_origins[player.name] then
        init_warning_button(player)
        init_gui(player)
    end
    if player.admin then
        init_origin_control_button(player)
    end
end

return init_origin_controls