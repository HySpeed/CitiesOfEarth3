---Setup the mod configuration values (startup and runtime)
local Config = require( "config" )
local Worlds = require( "data/worlds" )

-- =============================================================================

-- Get the world names from worlds
local world_names = {}
for world_name in pairs( Worlds ) do
  table.insert( world_names, world_name )
end

local pre_place_choices = { Config.NONE, Config.SINGLE, Config.ALL }

-- startup settings for world and options
data:extend {
  {
    name = "coe_world_map",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = world_names,
    default_value = world_names[3],
    order = "d-map"
  },
  {
    name = "coe_map_scale",
    setting_type = "startup",
    type = "double-setting",
    allowed_values = { .25, .5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20 },
    minimum_value = .25,
    default_value = 2,
    order = "d-scale"
  },
  {
    name = "coe_create_teleporters",
    setting_type = "startup",
    type = "bool-setting",
    default_value = true,
    order = "h-create"
  },
  {
    name = "coe_source_teleporters_require_power",
    setting_type = "startup",
    type = "bool-setting",
    default_value = true,
    order = "i-a-source"
  },
  {
    name = "coe_dest_teleporters_require_power",
    setting_type = "startup",
    type = "bool-setting",
    default_value = true,
    order = "i-b-dest"
  },
  {
    name = "coe_all_teleporters_available",
    setting_type = "startup",
    type = "bool-setting",
    default_value = false,
    order = "j-enable-all"
  },
  {
    name = "coe_pre_place_silo",
    setting_type = "startup",
    type = "string-setting",
    default_value = pre_place_choices[1],
    allowed_values = pre_place_choices,
    order = "k-pre"
  },
  {
    name = "coe_pre_place_limit",
    setting_type = "startup",
    type = "bool-setting",
    default_value = false,
    order = "l-pp-limit"
  },
  {
    name = "coe_pre_place_limit",
    setting_type = "startup",
    type = "bool-setting",
    default_value = false,
    order = "l-pp-limit"
  },
  {
    name = "coe_team_coop",
    setting_type = "startup",
    type = "bool-setting",
    default_value = false,
    order = "m-teams"
  },
  {
    name = "coe_spawn_city_atlantic",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Atlantic"].city_names,
    default_value = Worlds["Earth - Atlantic"].city_names[1],
    order = "s-atl-sa"
  },
  {
    name = "coe_silo_city_atlantic",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Atlantic"].city_names,
    default_value = Worlds["Earth - Atlantic"].city_names[1],
    order = "s-atl-so"
  },
  {
    name = "coe_spawn_city_pacific",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Pacific"].city_names,
    default_value = Worlds["Earth - Pacific"].city_names[1],
    order = "s-pac-sa"
  },
  {
    name = "coe_silo_city_pacific",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Pacific"].city_names,
    default_value = Worlds["Earth - Pacific"].city_names[1],
    order = "s-pac-so"
  },
  {
    name = "coe_spawn_city_olde_world",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Olde World"].city_names,
    default_value = Worlds["Earth - Olde World"].city_names[1],
    order = "s-old-sa"
  },
  {
    name = "coe_silo_city_olde_world",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Olde World"].city_names,
    default_value = Worlds["Earth - Olde World"].city_names[1],
    order = "s-old-so"
  },
  {
    name = "coe_spawn_city_americas",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Americas"].city_names,
    default_value = Worlds["Earth - Americas"].city_names[1],
    order = "s-ami-sa"
  },
  {
    name = "coe_silo_city_americas",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Americas"].city_names,
    default_value = Worlds["Earth - Americas"].city_names[1],
    order = "s-ami-so"
  },
  {
    name = "coe_spawn_city_united_states",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - United States"].city_names,
    default_value = Worlds["Earth - United States"].city_names[1],
    order = "s-usa-sa"
  },
  {
    name = "coe_silo_city_united_states",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - United States"].city_names,
    default_value = Worlds["Earth - United States"].city_names[1],
    order = "s-usa-so"
  },
  {
    name = "coe_spawn_city_africa",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Africa"].city_names,
    default_value = Worlds["Earth - Africa"].city_names[1],
    order = "s-afr-sa"
  },
  {
    name = "coe_silo_city_africa",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Africa"].city_names,
    default_value = Worlds["Earth - Africa"].city_names[1],
    order = "s-afr-so"
  },
  {
    name = "coe_spawn_city_europe",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Europe"].city_names,
    default_value = Worlds["Earth - Europe"].city_names[1],
    order = "s-eur-sa"
  },
  {
    name = "coe_silo_city_europe",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Europe"].city_names,
    default_value = Worlds["Earth - Europe"].city_names[1],
    order = "s-eur-so"
  },
  {
    name = "coe_spawn_city_oceania",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Oceania"].city_names,
    default_value = Worlds["Earth - Oceania"].city_names[1],
    order = "s-oce-sa"
  },
  {
    name = "coe_silo_city_oceania",
    setting_type = "startup",
    type = "string-setting",
    allowed_values = Worlds["Earth - Oceania"].city_names,
    default_value = Worlds["Earth - Oceania"].city_names[1],
    order = "s-oce-so"
  }
}

-- runtime-global settings (can be changed in game)
data:extend {
  {
    name = "coe_teleporting_enabled",
    setting_type = "runtime-global",
    type = "bool-setting",
    default_value = true,
    order = "d"
  },
  {
    name = "coe_drain_energy_on_teleport",
    setting_type = "runtime-global",
    type = "bool-setting",
    default_value = true,
    order = "t"
  }
}

if Config.DEV_MODE then
  data:extend {
    {
      name = "coe_dev_mode",
      setting_type = "startup",
      type = "bool-setting",
      default_value = true,
      order = "z_end_a",
      localised_name = "Dev Mode",
    },
    {
      name = "coe_dev_skip_generation",
      setting_type = "startup",
      type = "bool-setting",
      default_value = false,
      order = "z_end_b",
      localised_name = "Skip Terrain Gen",
    },
  }
end
