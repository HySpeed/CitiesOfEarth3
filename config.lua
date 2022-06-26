---config.lua
---Configuration Options
---@class coe.Config
local coeConfig = {
  SHIFT = 10, -- offset / shift from target city location for Silo / Teleporter
  TP_ENERGY_REQ = 5000000, -- power required by teleporter
  PLAYER_FORCE = "player",
  SURFACE_NAME = "Earth",
  RANDOM_CITY = "Random City",
  ROCKET_SILO = "rocket-silo",
  DEV_MODE = true,
  DETAIL_LEVEL = 2,
  CITY_CHUNK_RADIUS = 1
}
return coeConfig
