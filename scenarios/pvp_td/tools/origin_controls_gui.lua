local mod_gui = require ('mod-gui')

local function init_button(player)

end

local function init_gui(player)

end

function init_origin_controls(player)
    if global.player_origins[player.name] then
        init_button(player)
        init_gui(player)
    end
end

return init_origin_controls