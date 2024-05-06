local td_prototypes = { -- just here so i can see our data easier
    ["small-biter"] = {
        ai_settings = {
            allow_try_return_to_spawner = false,
            destroy_when_commands_fail = false
        },
        attack_parameters = {
            ammo_type = {
                action = {
                    action_delivery = {
                        target_effects = {
                            damage = {
                                amount = 7,
                                type = "physical"
                            },
                            type = "damage"
                        },
                        type = "instant"
                    },
                    type = "direct"
                },
                category = "melee",
                target_type = "entity"
            },
            cooldown = 35,
            cooldown_deviation = 0.15,
            range = 0.5,
            type = "projectile"
        },
        distance_per_frame = 0.125,
        distraction_cooldown = 300,
        healing_per_tick = 0.01,
        icon = "__base__/graphics/icons/small-biter.png",
        icon_mipmaps = 4,
        icon_size = 64,
        max_health = 15,
        max_pursue_distance = 50,
        min_pursue_time = 600,
        movement_speed = 0.2,
        name = "small-biter",
        order = "b-a-a",
        pollution_to_join_attack = 4,
        resistances = {},
        vision_distance = 30,
    },
    
    ["medium-biter"] = {
        ai_settings = {
            allow_try_return_to_spawner = false,
            destroy_when_commands_fail = false
        },
        attack_parameters = {
            ammo_type = {
                action = {
                    action_delivery = {
                        target_effects = {
                            damage = {
                                amount = 15,
                                type = "physical"
                            },
                            type = "damage"
                        },
                        type = "instant"
                    },
                    type = "direct"
                },
                category = "melee",
                target_type = "entity"
            },
            cooldown = 35,
            cooldown_deviation = 0.15,
            range = 1,
            range_mode = "bounding-box-to-bounding-box",
            type = "projectile"
        },
        corpse = "medium-biter-corpse",
        distance_per_frame = 0.18799999999999999,
        distraction_cooldown = 300,
        healing_per_tick = 0.01,
        icon = "__base__/graphics/icons/medium-biter.png",
        icon_mipmaps = 4,
        icon_size = 64,
        max_health = 75,
        max_pursue_distance = 50,
        min_pursue_time = 600,
        movement_speed = 0.23999999999999999,
        name = "medium-biter",
        order = "b-a-b",
        pollution_to_join_attack = 20,
        resistances = {
            {
                decrease = 4,
                percent = 10,
                type = "physical"
            },
            {
                percent = 10,
                type = "explosion"
            }
        },
        subgroup = "enemies",
        type = "unit",
        vision_distance = 30,
    }
}

-- level up a single attribute
local lvl_item = function(v, m)
    return v + _C.round(v * (m or 0.1))
end

-- level up attributes dealing with attack, speed, the normal things you'd increase
-- resistances not included, yet
local lvl_up = function(pt)
    local new = {}
    new.attack_parameters = pt.attack_parameters

    new.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount =
    lvl_item(pt.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount)
    new.attack_parameters.cooldown =
    lvl_item(pt.attack_parameters.cooldown, -0.01)
    new.healing_per_tick =
    lvl_item(pt.healing_per_tick)
    new.max_health =
    lvl_item(pt.max_health)
    new.movement_speed =
    lvl_item(pt.movement_speed)
    return new
end

-- push the new through?
local make_td_unit = function(unit)
    data:extend{unit}
end

-- the function i want to call to test
local make_new_small_biters = function()
    local pt = table.deepcopy(data.raw["unit"]["small-biter"])
    for i = 2, 5 do
        pt.name = "small-biter-"..i
        pt.localised_name = {"", "Small Biter Lvl", i}
        pt = lvl_up(pt)
        make_td_unit(pt)
    end
end

make_new_small_biters()