-- settings.lua

-- setup the mod configuration values (startup and runtime)
local coeConfig     = require( "config" )
local coeUtils      = require( "scripts/coe_utils" )
local coeWorlds     = require( "data/worlds" )
local coeAtlantic   = require( "data/cities_atlantic"   )
local coePacific    = require( "data/cities_pacific"    )
local coeOlde_World = require( "data/cities_olde_world" )
local coeAmericas   = require( "data/cities_americas"   )

-- =============================================================================


-- =============================================================================

-- Get the world names from worlds
local world_names = {}
for world_name, _ in pairs( coeWorlds ) do
  table.insert( world_names, world_name )
end

local         city_names_atlantic = coeUtils.GetCityNames( coeAtlantic )
table.insert( city_names_atlantic, 1, coeConfig.RANDOM_CITY )
local         city_names_pacific = coeUtils.GetCityNames( coePacific )
table.insert( city_names_pacific, 1, coeConfig.RANDOM_CITY )
local         city_names_olde_world = coeUtils.GetCityNames( coeOlde_World )
table.insert( city_names_olde_world, 1, coeConfig.RANDOM_CITY )
local         city_names_americas = coeUtils.GetCityNames( coeAmericas )
table.insert( city_names_americas, 1, coeConfig.RANDOM_CITY )


-- startup settings for world and options
data:extend({
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
    minimum_value = 1,
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
    default_value = city_names_atlantic[1],
    allowed_values = city_names_atlantic,
    order = "db"
  },
  {
    name = "coe_silo_city_atlantic",
    type = "string-setting",
    setting_type = "startup",
    default_value = city_names_atlantic[1],
    allowed_values = city_names_atlantic,
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
    default_value = city_names_pacific[1],
    allowed_values = city_names_pacific,
    order = "eb"
  },
  {
    name = "coe_silo_city_pacific",
    type = "string-setting",
    setting_type = "startup",
    default_value = city_names_pacific[1],
    allowed_values = city_names_pacific,
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
    default_value = city_names_olde_world[1],
    allowed_values = city_names_olde_world,
    order = "fb"
  },
  {
    name = "coe_silo_city_olde_world",
    type = "string-setting",
    setting_type = "startup",
    default_value = city_names_olde_world[1],
    allowed_values = city_names_olde_world,
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
    default_value = city_names_americas[1],
    allowed_values = city_names_americas,
    order = "gb"
  },
  {
    name = "coe_silo_city_americas",
    type = "string-setting",
    setting_type = "startup",
    default_value = city_names_americas[1],
    allowed_values = city_names_americas,
    order = "gc"
  }
})

-- these are marked as 'runtime-global', but only read at on_init
-- this puts them on the 'map' page.  This is to 'de-clutter' the startup page
data:extend({
  {
    type = "bool-setting",
    name = "coe_create_teleporters",
    setting_type = "runtime-global",
    default_value = true,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "coe_all_teleporters_available",
    setting_type = "runtime-global",
    default_value = false,
    order = "b"
  },
  -- {
  --   type = "bool-setting",
  --   name = "coe_discharge_equipment",
  --   setting_type = "runtime-global",
  --   default_value = true,
  --   order = "d"
  -- },
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
})

-- runtime-global settings (can be changed in game)
data:extend({
  {
    type = "bool-setting",
    name = "coe_teleporters_require_power",
    setting_type = "runtime-global",
    default_value = true,
    order = "zc"
  },
  {
    type = "bool-setting",
    name = "coe_teleporting_enabled",
    setting_type = "runtime-global",
    default_value = true,
    order = "zh"
  }
})
