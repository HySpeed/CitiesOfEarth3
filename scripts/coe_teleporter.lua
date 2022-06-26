---@class coe.Teleporter
local Teleporter = {}

---@class global
---@field teleporters {[uint]: LuaEntity}

local Config = require("config")
local Utils = require("scripts/coe_utils")
local Surface = require("scripts/coe_surface")

local Teleporters ---@type {[uint]: LuaEntity}

-- ============================================================================

---@param event EventData.on_city_generated
function Teleporter.onCityGenerated(event)
  local tp_city = Surface.getCity(event.city_name)
  local surface = event.surface

  ---@type LuaSurface.create_entity_param
  local build_params = {
    name = Config.TELEPORTER,
    force = Config.PLAYER_FORCE,
    position = Utils.positionAdd(tp_city.position, {10.5, -10.5}),
    move_stuck_players = true,
    raise_built = true,
  }

  build_params = Surface.forceBuildParams(surface, build_params)

  local teleporter = surface.create_entity(build_params)

  if not teleporter then
    log("WARNING: Failed to build teleporter: ".. tp_city.name .. " " .. Utils.positionToStr(build_params.position))
    return --It really shouldn't fail at this point.
  end

  teleporter.destructible = false
  teleporter.minable = false
  teleporter.energy = 0
  teleporter.backer_name = tp_city.name

  Teleporters[teleporter.unit_number] = teleporter
end

-- ============================================================================

function Teleporter.onInit()
global.teleporters = {}
Teleporters = global.teleporters
end

-------------------------------------------------------------------------------

function Teleporter.onLoad()
  Teleporters = global.teleporters
end

-- ============================================================================

return Teleporter
