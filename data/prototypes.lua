local td_prototypes = {
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

td_prototypes.make_td_unit = function(definition)
   local unit =
   {

   }
    data:extend{unit}
end