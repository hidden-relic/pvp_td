local config =
{
    surface = 'oarc',
    enemy_force = 'creeps',
    percent_bugs_created_before_command = 0.5,
    ticks_between_waves = 60*2, -- not in use currently
    origin = {x=0, y=0}, -- this may change depending on gametype
    path_tile = 'landfill',
    ticks_between_tiles = 1, -- this should be determined elsewhere, but for now, testing
    logging = true -- not in use currently
}

return config