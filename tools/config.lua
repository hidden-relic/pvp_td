local config =
{
    surface = 'oarc',
    ticks_between_enemies = 20,
    ticks_between_waves = 60*2,
    origin = {x=0, y=0},
    enemies_in_wave = 5,
    path_tile = 'landfill',
    ticks_between_tiles = 1,
    logging = false         -- will log "origin xy to destination xy" and all the tile positions between for each new line
}

return config