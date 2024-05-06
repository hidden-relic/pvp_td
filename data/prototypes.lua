-- local td_prototypes = { -- just here so i can see our data easier
-- ["small-biter"] = {
--     ai_settings = {
--         allow_try_return_to_spawner = false,
--         destroy_when_commands_fail = false
--     },
--     attack_parameters = {
--         ammo_type = {
--             action = {
--                 action_delivery = {
--                     target_effects = {
--                         damage = {
--                             amount = 7,
--                             type = "physical"
--                         },
--                         type = "damage"
--                     },
--                     type = "instant"
--                 },
--                 type = "direct"
--             },
--             category = "melee",
--             target_type = "entity"
--         },
--         cooldown = 35,
--         cooldown_deviation = 0.15,
--         range = 0.5,
--         type = "projectile"
--     },
--     distance_per_frame = 0.125,
--     distraction_cooldown = 300,
--     healing_per_tick = 0.01,
--     icon = "__base__/graphics/icons/small-biter.png",
--     icon_mipmaps = 4,
--     icon_size = 64,
--     max_health = 15,
--     max_pursue_distance = 50,
--     min_pursue_time = 600,
--     movement_speed = 0.2,
--     name = "small-biter",
--     order = "b-a-a",
--     pollution_to_join_attack = 4,
--     resistances = {},
--     vision_distance = 30,
-- },

-- ["medium-biter"] = {
--     ai_settings = {
--         allow_try_return_to_spawner = false,
--         destroy_when_commands_fail = false
--     },
--     attack_parameters = {
--         ammo_type = {
--             action = {
--                 action_delivery = {
--                     target_effects = {
--                         damage = {
--                             amount = 15,
--                             type = "physical"
--                         },
--                         type = "damage"
--                     },
--                     type = "instant"
--                 },
--                 type = "direct"
--             },
--             category = "melee",
--             target_type = "entity"
--         },
--         cooldown = 35,
--         cooldown_deviation = 0.15,
--         range = 1,
--         range_mode = "bounding-box-to-bounding-box",
--         type = "projectile"
--     },
--     corpse = "medium-biter-corpse",
--     distance_per_frame = 0.18799999999999999,
--     distraction_cooldown = 300,
--     healing_per_tick = 0.01,
--     icon = "__base__/graphics/icons/medium-biter.png",
--     icon_mipmaps = 4,
--     icon_size = 64,
--     max_health = 75,
--     max_pursue_distance = 50,
--     min_pursue_time = 600,
--     movement_speed = 0.23999999999999999,
--     name = "medium-biter",
--     order = "b-a-b",
--     pollution_to_join_attack = 20,
--     resistances = {
--         {
--             decrease = 4,
--             percent = 10,
--             type = "physical"
--         },
--         {
--             percent = 10,
--             type = "explosion"
--         }
--     },
--     subgroup = "enemies",
--     type = "unit",
--     vision_distance = 30,
-- }
-- }

local round = function(num, dp)
    local mult = 10 ^ (dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- level up a single attribute
local lvl_item = function(v, m)
    -- value (v) has a percentage (m) of itself added to itself
    return v + round(v * (m or 0.1))
end

-- level up attributes dealing with attack, speed, the normal things you'd increase
-- resistances not included, yet
local lvl_up = function(pt)
    local new = pt
    
    -- damage amount for the prototype's damage type (float)
    new.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount =
    lvl_item(new.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount)

    -- number of ticks in which it will be possible to shoot again (float)
    new.attack_parameters.cooldown =
    round(lvl_item(new.attack_parameters.cooldown, -0.01))
    
    -- the amount of health automatically regenerated per tick (float)
    new.healing_per_tick =
    lvl_item(new.healing_per_tick)

    -- the unit health can never go over the maximum. 
    -- default health of units on creation is set to max
    -- must be greater than 0 (float)
    new.max_health =
    lvl_item(new.max_health)

    -- in tiles per tick (float)
    new.movement_speed =
    lvl_item(new.movement_speed)
    return new
end

local tint = function(pt, tint)
    pt.attack_parameters.animation.layers[2].hr_version.tint = tint
    for i, _ in pairs(pt.attack_parameters.animation.layers) do
        if pt.attack_parameters.animation.layers[i].tint then
            pt.attack_parameters.animation.layers[i].tint = tint
        end
        if pt.attack_parameters.animation.layers[i].hr_version and pt.attack_parameters.animation.layers[i].hr_version.tint then
            pt.attack_parameters.animation.layers[i].hr_version.tint = tint
        end
    end
    for i, _ in pairs(pt.run_animation.layers) do
        if pt.run_animation.layers[i].tint then
            pt.run_animation.layers[i].tint = tint
        end
        if pt.run_animation.layers[i].hr_version and pt.run_animation.layers[i].hr_version.tint then
            pt.run_animation.layers[i].hr_version.tint = tint
        end
    end
    return pt
end

-- push the new through?
local make_td_unit = function(unit)
    data:extend{unit}
    return table.deepcopy(data.raw["unit"][unit.name])
end

-- the function i want to call to test
local make_new_small_biters = function()
    local pt = table.deepcopy(data.raw["unit"]["small-biter"])
    for i = 2, 5 do
        pt.name = "small-biter-"..i
        pt.localised_name = {"", "Small Biter Lvl ", i}
        pt.type = 'unit'
        pt = tint(pt, {r=1, g=(1-(i*0.2)), b=(1-(i*0.2))})
        pt = lvl_up(pt)
        pt = make_td_unit(pt)
    end
end

make_new_small_biters()