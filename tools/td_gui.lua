local mod_gui = require('mod-gui')
local td_gui = {}

function td_gui.create_wave_gui(player)
    local left_side = mod_gui.get_frame_flow(player)

    local left_frame = left_side.add{
        name = 'left_frame',
        type = 'table',
        column_count = 2
    }
    left_frame.add{
        
    }
end

function td_gui.get_label(player)
    local td_gui_flow = mod_gui.get_frame_flow(player)
    local left_frame = td_gui_flow.left_frame
    return left_frame.wave_label
end

local function on_player_created(event)
    -- teleport player to surface at 0, 0
    local player = game.players[event.player_index]
    td_gui.new(player)
end

td_gui.events =
{
    [defines.events.on_player_created] = on_player_created
}

return td_gui