local mod_gui = require('mod-gui')
local td_gui = {}

function td_gui.new(player)
    local left_side = mod_gui.get_frame_flow(player)
    -- local frame_table = left_side.add{
    --     type = 'table',
    --     column_count = 100
    -- }
    local left_frame = left_side.add{
        name = 'left_frame',
        type = 'table',
        column_count = 6
    }
    left_frame.add{
        type = 'label',
        caption = 'achievement_title_label',
        style = 'achievement_title_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'yellow_label',
        style = 'yellow_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'tooltip_item_label',
        style = 'tooltip_item_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_locked_title_label',
        style = 'achievement_locked_title_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'mod_manager_label',
        style = 'mod_manager_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'invalid_selected_mod_label',
        style = 'invalid_selected_mod_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'label_dividing_inside_frames',
        style = 'label_dividing_inside_frames'
        }
        left_frame.add{
        type = 'label',
        caption = 'valid_mod_label',
        style = 'valid_mod_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'electric_usage_label',
        style = 'electric_usage_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_locked_progress_label',
        style = 'achievement_locked_progress_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'valid_selected_mod_label',
        style = 'valid_selected_mod_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'bold_green_label',
        style = 'bold_green_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'saved_research_label',
        style = 'saved_research_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'main_menu_login_notice_label',
        style = 'main_menu_login_notice_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'subheader_caption_label',
        style = 'subheader_caption_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'menu_message',
        style = 'menu_message'
        }
        left_frame.add{
        type = 'label',
        caption = 'train_schedule_unavailable_stop_label',
        style = 'train_schedule_unavailable_stop_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_locked_description_label',
        style = 'achievement_locked_description_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'mod_dependency_invalid_label',
        style = 'mod_dependency_invalid_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'bold_red_label',
        style = 'bold_red_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'map_gen_row_label',
        style = 'map_gen_row_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'description_value_label',
        style = 'description_value_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'black_label',
        style = 'black_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'subheader_label',
        style = 'subheader_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'train_schedule_non_existent_stop_label',
        style = 'train_schedule_non_existent_stop_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'bold_black_label',
        style = 'bold_black_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'count_label',
        style = 'count_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'black_clickable_label',
        style = 'black_clickable_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'frame_subheading_label',
        style = 'frame_subheading_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'clickable_squashable_label',
        style = 'clickable_squashable_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'recipe_tooltip_transitive_craft_label',
        style = 'recipe_tooltip_transitive_craft_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_failed_reason_label',
        style = 'achievement_failed_reason_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_failed_description_label',
        style = 'achievement_failed_description_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'color_picker_label',
        style = 'color_picker_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'current_research_info_percent_label_white',
        style = 'current_research_info_percent_label_white'
        }
        left_frame.add{
        type = 'label',
        caption = 'black_clickable_squashable_label',
        style = 'black_clickable_squashable_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'tooltip_heading_label',
        style = 'tooltip_heading_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'tooltip_label',
        style = 'tooltip_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'special_label_under_widget',
        style = 'special_label_under_widget'
        }
        left_frame.add{
        type = 'label',
        caption = 'recipe_tooltip_transitive_craft_count_label',
        style = 'recipe_tooltip_transitive_craft_count_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'description_title_indented_label',
        style = 'description_title_indented_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'heading_2_label',
        style = 'heading_2_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'invalid_hovered_mod_label',
        style = 'invalid_hovered_mod_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'hyperlink_label',
        style = 'hyperlink_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'valid_hovered_mod_label',
        style = 'valid_hovered_mod_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_failed_title_label',
        style = 'achievement_failed_title_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'invalid_label',
        style = 'invalid_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'bold_label',
        style = 'bold_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'recipe_tooltip_cannot_craft_count_label',
        style = 'recipe_tooltip_cannot_craft_count_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'player_not_in_game_state_label',
        style = 'player_not_in_game_state_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'heading_3_label_yellow',
        style = 'heading_3_label_yellow'
        }
        left_frame.add{
        type = 'label',
        caption = 'heading_1_label',
        style = 'heading_1_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'caption_label',
        style = 'caption_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_description_label',
        style = 'achievement_description_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'label_under_widget',
        style = 'label_under_widget'
        }
        left_frame.add{
        type = 'label',
        caption = 'tooltip_title_label',
        style = 'tooltip_title_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'squashable_label_with_left_padding',
        style = 'squashable_label_with_left_padding'
        }
        left_frame.add{
        type = 'label',
        caption = 'label_with_left_padding',
        style = 'label_with_left_padding'
        }
        left_frame.add{
        type = 'label',
        caption = 'black_label_with_left_padding',
        style = 'black_label_with_left_padding'
        }
        left_frame.add{
        type = 'label',
        caption = 'black_squashable_label',
        style = 'black_squashable_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'player_offline_label',
        style = 'player_offline_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'featured_technology_description_label',
        style = 'featured_technology_description_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'clickable_label',
        style = 'clickable_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'label',
        style = 'label'
        }
        left_frame.add{
        type = 'label',
        caption = 'recipe_count_label',
        style = 'recipe_count_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'goal_label',
        style = 'goal_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'control_input_shortcut_label',
        style = 'control_input_shortcut_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'current_research_info_percent_label_black',
        style = 'current_research_info_percent_label_black'
        }
        left_frame.add{
        type = 'label',
        caption = 'heading_3_label',
        style = 'heading_3_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'orange_label',
        style = 'orange_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'squashable_label',
        style = 'squashable_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'black_squashable_label_with_left_padding',
        style = 'black_squashable_label_with_left_padding'
        }
        left_frame.add{
        type = 'label',
        caption = 'tooltip_heading_label_category',
        style = 'tooltip_heading_label_category'
        }
        left_frame.add{
        type = 'label',
        caption = 'steam_friend_label',
        style = 'steam_friend_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'frame_title',
        style = 'frame_title'
        }
        left_frame.add{
        type = 'label',
        caption = 'main_menu_version_label',
        style = 'main_menu_version_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'inventory_label',
        style = 'inventory_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'mod_optional_dependency_invalid_label',
        style = 'mod_optional_dependency_invalid_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_unlocked_description_label',
        style = 'achievement_unlocked_description_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'info_label',
        style = 'info_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'load_game_mod_invalid_label',
        style = 'load_game_mod_invalid_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'player_online_label',
        style = 'player_online_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'mod_disabled_label',
        style = 'mod_disabled_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'description_property_name_label',
        style = 'description_property_name_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'description_title_label',
        style = 'description_title_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'recipe_tooltip_cannot_craft_label',
        style = 'recipe_tooltip_cannot_craft_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'description_label',
        style = 'description_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'invalid_mod_label',
        style = 'invalid_mod_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_percent_label',
        style = 'achievement_percent_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'achievement_unlocked_title_label',
        style = 'achievement_unlocked_title_label'
        }
        left_frame.add{
        type = 'label',
        caption = 'subheader_right_aligned_label',
        style = 'subheader_right_aligned_label'
        }
    
    -- local wave_label = left_frame.add{
    --     name = 'wave_label',
    --     type = 'label',
    --     caption = '',
    --     style = 'count_label'
    -- }
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