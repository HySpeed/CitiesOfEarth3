---@class coe.Teleporter
local Teleporter = {}

local Config = require("config")
local Utils = require("scripts/coe_utils")
local Surface = require("scripts/coe_surface")

local teleporters ---@type {[uint]: global.teleporter}
local world ---@type global.world

-- ============================================================================

---Create the gui
---TODO create the gui if teleporters are enabled
---@param event EventData
function Teleporter.onPlayerCreated(event) end

---@param event EventData.on_city_generated
function Teleporter.onCityGenerated(event)
  if not settings.global["coe_create_teleporters"].value then return end

  local city = world.cities[event.city_name]
  local surface = event.surface

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

  local teleporter= Surface.forceBuildParams(surface, build_params)

  if not teleporter then
    Utils.devPrint("WARNING: Failed to build teleporter: ".. city.name .. " " .. Utils.positionToStr(build_params.position))
    return --It really shouldn't fail at this point.
  end

  teleporter.destructible = false
  teleporter.minable = false
  teleporter.energy = 0
  teleporter.backer_name = city.name

  ---@type global.teleporter
  local teleporter_data = {
    entity = teleporter,
    city = city
  }

  teleporters[teleporter.unit_number] = teleporter_data
  city.teleporter = teleporter_data
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_charted
function Teleporter.onCityCharted(event)
  local surface = event.surface
  local city = world.cities[event.city_name]

  if city.teleporter then
    local area = city.teleporter.entity.bounding_box
    area = Utils.areaAdjust(area, {{-1,-1}, {1, 1}})
    area = Utils.areaToTileArea(area)
    Surface.landfillArea(surface, area, "hazard-concrete-right")
    Surface.clearArea(surface, area, Config.TELEPORTER)
  end

  local tag = {
    icon = {type = 'virtual', name = "signal-info"},
    position = city.teleporter and city.teleporter.entity.position or event.position,
    text = "     " .. event.city_name
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

---@class global.city
---@field teleporter global.teleporter
