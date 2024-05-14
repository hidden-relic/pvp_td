local config =
{
    surface = 'nauvis',
    enemy_force = 'creeps',
    origin_position_radius = 32*10,
    origin_position_grain = 6,
    distance_between_origins = 32*3,
    percent_bugs_created_before_command = 0.5,
    ticks_between_waves = 60*2, -- not in use currently
    origin = {x=0, y=0}, -- this may change depending on gametype
    path_tile = 'landfill',
    origin_tile = 'tutorial-grid',
    ticks_between_tiles = 1, -- this should be determined elsewhere, but for now, testing
    logging = false -- not in use currently
}

return config