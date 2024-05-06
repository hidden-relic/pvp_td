local button_list = require ('buttons')
local drop_down_list = require ('drop_downs')
local progress_bar_list = require ('progress_bars')
local frame_list = require ('frames')

local cheat_gui = {}

local cheat_gui_enabled = false

function cheat_gui.create_main(player)
    local center = player.gui.center
    local main = center.add
    {
        type = 'frame',
        name = 'cheat_main'
    }
    local main_flow = main.add
    {
        type = 'flow',
        direction = 'vertical',
        name = 'cheat_flow'
    }
    local frames_flow = main_flow.add
    {
        type = 'flow',
        direction = 'horizontal',
        name = 'cheat_frames_flow'
    }
    frames_flow.add
    {
        type = 'drop-down',
        name = 'cheat_frame_dd',
        items = frame_list
    }
    local button_flow = main_flow.add
    {
        type = 'flow',
        direction = 'horizontal',
        name = 'cheat_buttons_flow'
    }
    button_flow.add
    {
        type = 'button',
        name = 'cheat_button',
    }
    button_flow.add
    {
        type = 'drop-down',
        name = 'cheat_button_dd',
        items = button_list
    }
    local progress_bar_flow = main_flow.add
    {
        type = 'flow',
        direction = 'horizontal',
        name = 'cheat_progress_bars_flow'
    }
    progress_bar_flow.add
    {
        type = 'progressbar',
        name = 'cheat_progress_bar',
        value = 0.5
    }
    progress_bar_flow.add
    {
        type = 'drop-down',
        name = 'cheat_progress_bar_dd',
        items = progress_bar_list
    }
    local drop_down_flow = main_flow.add
    {
        type = 'flow',
        direction = 'horizontal',
        name = 'cheat_drop_downs_flow'
    }
    drop_down_flow.add
    {
        type = 'drop-down',
        name = 'cheat_drop_down_dd',
        items = drop_down_list
    }
    return main_flow
end

local function handle_frames(event)
    local player = game.players[event.player_index]
    local main = global.cheat_gui[player.name].cheat_frames_flow
    if event.element == main.cheat_frame_dd then
        local choice = main.cheat_frame_dd.get_item(main.cheat_frame_dd.selected_index)
        if pcall(function()
            main.parent.parent.style = choice
        end) then
            return
        else
            return
        end
    end
end

local function handle_buttons(event)
    local player = game.players[event.player_index]
    local main = global.cheat_gui[player.name].cheat_buttons_flow
    if event.element == main.cheat_button_dd then
        local choice = main.cheat_button_dd.get_item(main.cheat_button_dd.selected_index)
        if pcall(function()
            main.cheat_button.style = choice
        end) then
            main.cheat_button.style.width = 256
            main.cheat_button.style.height = 32
            main.cheat_button.caption = choice
        else
            return
        end
    end
end

local function handle_drop_downs(event)
    local player = game.players[event.player_index]
    local main = global.cheat_gui[player.name].cheat_drop_downs_flow
    if event.element == main.cheat_drop_down_dd then
        local choice = main.cheat_drop_down_dd.get_item(main.cheat_drop_down_dd.selected_index)
        if pcall(function()
            main.cheat_drop_down_dd.style = choice
        end) then
            return
        else
            return
        end
    end
end

local function handle_progress_bars(event)
    local player = game.players[event.player_index]
    local main = global.cheat_gui[player.name].cheat_progress_bars_flow
    if event.element == main.cheat_progress_bar_dd then
        local choice = main.cheat_progress_bar_dd.get_item(main.cheat_progress_bar_dd.selected_index)
        if pcall(function()
            main.cheat_progress_bar.style = choice
        end) then
            return
        else
            return
        end
    end
end

function cheat_gui.on_init()
    global.cheat_gui = {}
end

local function on_player_created(event)
    local player = game.players[event.player_index]
    if cheat_gui_enabled then
    global.cheat_gui[player.name] = cheat_gui.create_main(player)
    end
end

local function on_gui_selection_state_changed(event)
    handle_frames(event)
    handle_buttons(event)
    handle_drop_downs(event)
    handle_progress_bars(event)
end


cheat_gui.events =
{
    [defines.events.on_player_created] = on_player_created,
    [defines.events.on_gui_selection_state_changed] = on_gui_selection_state_changed,
}

return cheat_gui