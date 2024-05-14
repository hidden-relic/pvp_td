local Paths = require ('paths')
local origin_controls = require ('origin_controls_gui')

local Origins = {}

function Origins.create_origin(definition)
    local surface = game.surfaces[config.surface]
    local tile_positions = _C.get_circle(6, definition.position, config.origin_tile)
    surface.set_tiles(tile_positions)
    local spawner = surface.create_entity{name='biter-spawner', force=game.forces[config.enemy_force], position=definition.position}
    _C.protect_entity(spawner)
    local entities = surface.find_entities_filtered{position=definition.position, radius=6, force=game.forces[config.enemy_force], invert = true}
    if entities then
        for _, entity in pairs(entities) do entity.destroy() end
    end
    spawner.active = false
    local obj = {}
    obj.actions = {}
    obj.index = 1
    obj.position = definition.position
    obj.last_tick = definition.tick
    obj.spawner = spawner
    obj.target_position = definition.target_position
    obj.paths = {}
    obj.waves = {}
    obj.groups = {}
    if config.logging then
        game.print('Origin initialized')
    end
    return obj
end

local function get_potential_positions(r, n)
    local random_angle_offset = math.random(0, math.pi * 2)
    local num_positions_for_circle = math.ceil((r / (n or 8)))
    local positions = {}
    
    for i = 1, num_positions_for_circle do
        local theta = ((math.pi * 2) / num_positions_for_circle);
        local angle = (theta * i) + random_angle_offset;
        
        local chunk_x = _C.round((r * math.cos(angle)) +
        math.random(-2, 2))
        local chunk_y = _C.round((r * math.sin(angle)) +
        math.random(-2, 2))
        local position = {x=chunk_x, y=chunk_y}
        table.insert(positions, position)
    end
    return positions
end

local function get_closest_potential_position(position)
    local origin_position, index = _C.get_closest_position(position, global.origins.potential_positions)
    for _, origin in pairs(global.origins) do
        if origin.position then
            if _C.get_distance(origin_position, origin.position) < config.distance_between_origins then
                return get_closest_potential_position(position)
            end
        end
    end
    table.remove(global.origins.potential_positions, index)
    return origin_position
end

-----------------------------------------------
-- the function to run after spawning player --
-----------------------------------------------

function Origins.player_created(player)
    local origin_position = get_closest_potential_position(player.position)
    game.print(serpent.line(origin_position))
    local origin = Origins.create_origin{tick=game.tick, position=origin_position, target_position=player.position}
    global.origins[player.name] = origin
    origin_controls.create_origin_controls(player)
    Paths.new_path(origin)
    return origin
end

-----------------------------------------------

Origins.on_init = function()
    global.origins = {}
    global.origins.potential_positions = get_potential_positions(config.origin_position_radius, config.origin_position_grain)
end

-- if (not game.surfaces[GAME_SURFACE_NAME].is_chunk_generated({
--     chunk_x, chunk_y
-- })) then
-- end

commands.add_command('createorigin', '', function(command)
    local player = game.players[command.player_index]
    if not player.admin then
        player.print('You are not admin')
        return
    end
    local definition = {}
    definition.tick = game.tick
    definition.target_position = player.position
    Origins.player_created(player)
end)

return Origins