-- local config = require ('config')

local Origins = {}

function Origins.init_origin(definition)
    local surface = game.surfaces[config.surface]
    local tile_positions = _C.getCircle(6, definition.position, config.origin_tile)
    surface.set_tiles(tile_positions)
    local spawner = surface.create_entity{name='biter-spawner', force=game.forces[config.enemy_force], position=definition.position}
    _C.protect_entity(spawner)
    spawner.active = false
    local obj = {}
    obj.actions = {}
    obj.index = 1
    obj.position = definition.position
    obj.last_tick = definition.tick
    if config.logging then
        game.print('Origin initialized')
    end
    return obj
end

Origins.on_init = function()
    global.player_origins = {}
end

commands.add_command('createorigin', '', function(command)
    local player = game.players[command.player_index]
    if not player.admin then
        player.print('You are not admin')
        return
    end
    local definition = {}
    definition.position = player.selected.position
    definition.tick = game.tick
    local origin = Origins.init_origin(definition)
    global.player_origins[player.name] = origin
    player.print('You can access this origin through global.player_origins['..player.name..']')
end)

return Origins