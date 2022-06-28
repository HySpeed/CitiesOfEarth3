---Configuration Options
---@class coe.Config
local Config = {
  TP_ENERGY_REQ = 5000000, -- power required by teleporter
  PLAYER_FORCE = "player",
  SURFACE_NAME = "Earth",
  RANDOM_CITY = "Random City",
  ROCKET_SILO = "rocket-silo",
  TELEPORTER = "coe_teleporter",
  DEV_MODE = true,
  DEV_SKIP_GENERATION = false, --- Skips the set_tiles step for easier non world gen debugging
  DETAIL_LEVEL = 2,
  CITY_CHUNK_RADIUS = 1,
  TELEPORTER_OFFSET = {5, -5},
  SILO_OFFSET = {-5, 5}
}
return Config
