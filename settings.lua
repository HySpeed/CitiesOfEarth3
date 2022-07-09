---Setup the mod configuration values (startup and runtime)
local Config = require("config")
local Worlds = require("data/worlds")

-- =============================================================================

-- Get the world names from worlds
local world_names = {}
for world_name in pairs(Worlds) do
  table.insert(world_names, world_name)
end

-- startup settings for world and options
data:extend {
  {
    name = "coe_world_map",
    type = "string-setting",
    setting_type = "startup",
    default_value = world_names[3],
    allowed_values = world_names,
    order = "a"
  },
  {
    name = "coe_map_scale",
    type = "double-setting",
    setting_type = "startup",
    minimum_value = .25,
    default_value = 2,
    order = "b"
  },
  {
    name = "coe_pre_place_silo",
    type = "bool-setting",
    setting_type = "startup",
    default_value = false,
    order = "c"
  },
  {
    name = "coe_spacer_atlantic",
    type = "string-setting",
    setting_type = "startup",
    default_value = "----------",
    order = "da"
  },
  {
    name = "coe_spawn_city_atlantic",
    type = "string-setting",
    setting_type = "startup",
    default_value = Worlds["Earth - Atlantic"].city_names[1],
    allowed_values = Worlds["Earth - Atlantic"].city_names,
    order = "db"
  },
  {
    name = "coe_silo_city_atlantic",
    type = "string-setting",
    setting_type = "startup",
    default_value = Worlds["Earth - Atlantic"].city_names[1],
    allowed_values = Worlds["Earth - Atlantic"].city_names,
    order = "dc"
  },
  {
    name = "coe_spacer_pacific",
    type = "string-setting",
    setting_type = "startup",
    default_value = "----------",
    order = "ea"
  },
  {
    name = "coe_spawn_city_pacific",
    type = "string-setting",
    setting_type = "startup",
    default_value = Worlds["Earth - Pacific"].city_names[1],
    allowed_values = Worlds["Earth - Pacific"].city_names,
    order = "eb"
  },
  {
    name = "coe_silo_city_pacific",
    type = "string-setting",
    setting_type = "startup",
    default_value = Worlds["Earth - Pacific"].city_names[1],
    allowed_values = Worlds["Earth - Pacific"].city_names,
    order = "ec"
  },
  {
    name = "coe_spacer_olde_world",
    type = "string-setting",
    setting_type = "startup",
    default_value = "----------",
    order = "fa"
  },
  {
    name = "coe_spawn_city_olde_world",
    type = "string-setting",
    setting_type = "startup",
    default_value = Worlds["Earth - Olde World"].city_names[1],
    allowed_values = Worlds["Earth - Olde World"].city_names,
    order = "fb"
  },
  {
    name = "coe_silo_city_olde_world",
    type = "string-setting",
    setting_type = "startup",
    default_value = Worlds["Earth - Olde World"].city_names[1],
    allowed_values = Worlds["Earth - Olde World"].city_names,
    order = "fc"
  },
  {
    name = "coe_spacer_americas",
    type = "string-setting",
    setting_type = "startup",
    allow_blank = true,
    default_value = "----------",
    order = "ga"
  },
  {
    name = "coe_spawn_city_americas",
    type = "string-setting",
    setting_type = "startup",
    default_value = Worlds["Earth - Americas"].city_names[1],
    allowed_values = Worlds["Earth - Americas"].city_names,
    order = "gb"
  },
  {
    name = "coe_silo_city_americas",
    type = "string-setting",
    setting_type = "startup",
    default_value = Worlds["Earth - Americas"].city_names[1],
    allowed_values = Worlds["Earth - Americas"].city_names,
    order = "gc"
  },
  {
    type = "bool-setting",
    name = "coe_create_teleporters",
    setting_type = "startup",
    default_value = true,
    order = "fa-create"
  },
  {
    type = "bool-setting",
    name = "coe_all_teleporters_available",
    setting_type = "startup",
    default_value = false,
    order = "fa-enbable-all"
  },
}

-- these are marked as 'runtime-global', but only read at on_init
-- this puts them on the 'map' page.  This is to 'de-clutter' the startup page
data:extend {
  {
    type = "double-setting",
    name = "coe_launches_to_restore_silo_crafting",
    setting_type = "runtime-global",
    default_value = 0,
    minimum_value = 0,
    order = "g"
  },
  {
    type = "double-setting",
    name = "coe_launches_per_death",
    setting_type = "runtime-global",
    default_value = 0,
    minimum_value = 0,
    order = "h"
  }
}

-- runtime-global settings (can be changed in game)
data:extend {
  {
    type = "bool-setting",
    name = "coe_teleporting_enabled",
    setting_type = "runtime-global",
    default_value = true,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "coe_teleporters_require_power",
    setting_type = "runtime-global",
    default_value = true,
    order = "b"
  },
  {
    type = "bool-setting",
    name = "coe_drain_energy_on_teleport",
    setting_type = "runtime-global",
    default_value = true,
    order = "c"
  }
}

if Config.DEV_MODE then
  data:extend {
    {
      name = "coe_dev_mode",
      type = "bool-setting",
      setting_type = "startup",
      default_value = true,
      order = "z_end_a",
      localised_name = "Dev Mode",
    },
    {
      name = "coe_dev_skip_generation",
      type = "bool-setting",
      setting_type = "startup",
      default_value = false,
      order = "z_end_b",
      localised_name = "Skip Terrain Gen",
    },
  }
end
