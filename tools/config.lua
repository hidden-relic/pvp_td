local sec = 60
local min = sec*60
local hour = min*60
local day = hour*24

local config =
{
    surface = 'nauvis',
    enemy_force = 'creeps',
    origin_position_radius = 32*10,
    origin_position_grain = 6,
    distance_between_origins = 32*3,
    percent_bugs_created_before_departing = 0.5,
    ticks_between_waves = 60*2, -- not in use currently
    origin = {x=0, y=0}, -- this may change depending on gametype
    path_tile = 'landfill',
    origin_tile = 'tutorial-grid',
    ticks_between_tiles = 1, -- this should be determined elsewhere, but for now, testing
    logging = false, -- not in use currently
    pollution_tracker = {
        enabled = true,
        logging = false,
        search_radius = 2,          -- 
        time_between_scans = 1*sec, -- keep in mind each scan searches a square radius, so give time for chunks to be generated.
                                    -- ((radius*2)+1)^2 gets the square area
        time_until_refresh = 10*min
    }
}

return config