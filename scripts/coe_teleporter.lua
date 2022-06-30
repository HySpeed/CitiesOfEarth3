---@class coe.Teleporter
local Teleporter = {}

local Config = require("config")
local Utils = require("scripts/coe_utils")
local Surface = require("scripts/coe_surface")

local teleporters ---@type {[uint]: global.teleporter}
local world ---@type global.world

-- ============================================================================

---@param surface LuaSurface
---@param city global.city
---@return LuaEntity?
local function create_teleporter(surface, city)
  if not settings.global["coe_create_teleporters"].value then return end

  local pos = Utils.positionAdd(city.position, Config.TELEPORTER_OFFSET)

  ---@type LuaSurface.create_entity_param
  local build_params = {
    name = Config.TELEPORTER,
    force = Config.PLAYER_FORCE,
    position = pos,
    move_stuck_players = true,
    raise_built = true,
    create_build_effect_smoke = false,
  }

  local teleporter = Surface.forceBuildParams(surface, build_params)

  if not teleporter then
    Utils.devPrint("WARNING: Failed to build teleporter: " ..
      city.name .. " " .. Utils.positionToStr(build_params.position))
    return --It really shouldn't fail at this point.
  end

  teleporter.destructible = false
  teleporter.minable = false
  teleporter.energy = 0
  teleporter.backer_name = city.full_name

  ---@type global.teleporter
  local teleporter_data = {
    entity = teleporter,
    city = city,
    position = teleporter.position
  }

  teleporters[teleporter.unit_number] = teleporter_data
  city.teleporter = teleporter_data

  return teleporter
end

-- ============================================================================

---Create the gui
---TODO create the gui if teleporters are enabled
---@param event EventData.on_player_created
function Teleporter.onPlayerCreated(event)
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Teleporter.onCityGenerated(event) end

-------------------------------------------------------------------------------

---@param event EventData.on_city_charted
function Teleporter.onCityCharted(event)
  local surface = event.surface
  local city = world.cities[event.city_name]
  local position ---@type MapPosition

  local teleporter
  if settings.global.coe_create_teleporters then
    teleporter = create_teleporter(surface, city)
    position = teleporter and teleporter.position
  end

  local tag = {
    icon = { type = 'virtual', name = "signal-info" },
    position = position or city.position,
    text = "     " .. city.name
  }
  world.force.add_chart_tag(surface, tag)
end

-- ============================================================================

function Teleporter.onInit()
  global.teleporters = {}
  teleporters = global.teleporters
  world = global.world
end

-------------------------------------------------------------------------------

function Teleporter.onLoad()
  teleporters = global.teleporters
  world = global.world
end

-- ============================================================================

return Teleporter

---@class global
---@field teleporters {[uint]: global.teleporter}

---@class global.teleporter
---@field entity LuaEntity
---@field city global.city
---@field position MapPosition

---@class global.city
---@field teleporter global.teleporter
