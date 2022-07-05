data.raw.tile["out-of-map"].autoplace = { default_enabled = false }

    local my_map_gen_settings = {
        default_enable_all_autoplace_controls = false,
        property_expression_names = {cliffiness = 0},
        autoplace_settings = {tile = {settings = { ["out-of-map"] = {frequency="normal", size="normal", richness="normal"} }}},
        starting_area = "none"
    }
