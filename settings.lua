data:extend({
    {
        type = "int-setting",
        name = "pvp-num-ex1", -- explain use   
        setting_type = "startup",
        minimum_value = 1,
        maximum_value = 10,
        default_value = 1,
        order="pvp-0000"
    },
    {
        type = "string-setting",
        name = "pvp-st-ex1",     
        setting_type = "startup",
        allowed_values = {"Opt1", "Opt2", "Opt3"},
        default_value = "Opt1",
        order="pvp-1000"
    },    
    {
        type = "bool-setting",
        name = "pvp-bool-ex1",     
        setting_type = "startup",
        default_value = true,
        order="pvp-2000"
    }
})
