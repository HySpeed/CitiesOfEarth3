---Configuration Options
---@class coe.Config
local Config = {
  TP_MAX_ENERGY_STR = "500MW",
  TP_MAX_ENERGY = 8000000, -- max power required by teleporter
  TP_ENERGY_PER_CHUNK = 10000 * 5, -- energy required per chunk
  PLAYER_FORCE = "player",
  SURFACE_NAME = "Earth",
  RANDOM_CITY = "Random City",
  ROCKET_SILO = "rocket-silo",
  TELEPORTER = "coe_teleporter",
  NONE = "None",
  ALL = "All",
  SINGLE = "Single",
  DEV_MODE = false, -- Adds startup settings for toggling various developer features
  DETAIL_LEVEL = 2,
  CITY_CHUNK_RADIUS = 0,
  TELEPORTER_OFFSET = { 5, -10 },
  SILO_OFFSET = { -8, 8 }
}
return Config
