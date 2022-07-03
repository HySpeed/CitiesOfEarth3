---@class coe.Teleporter
local Teleporter = {}

local Config = require("config")
local Log = require("log")
local Utils = require("scripts/coe_utils")
local Surface = require("scripts/coe_surface")

local teleporters ---@type {[uint]: global.teleporter}
local world ---@type global.world

local tele_meta = {
  __index = function(self, key)
    return self.entity[key]
  end,
  __newindex = function(self, key, value)
    self.entity[key] = value
  end,
  __eq = function(self, other)
    return self.entity == other.entity
  end
}

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
    Log.print("WARNING: Failed to build teleporter: " ..
      city.name .. " " .. Utils.positionToStr(build_params.position))
    return --It really shouldn't fail at this point.
  end

  return teleporter
end

-- ============================================================================

---@param event EventData.on_city_generated
function Teleporter.onCityGenerated(event)
  if not settings.global.coe_create_teleporters.value then return end

  local surface = event.surface
  local city = world.cities[event.city_name]

  local teleporter = create_teleporter(surface, city)
  if not teleporter then return end

  Surface.decorate(event.surface, teleporter)
  local position = teleporter.position
  if Config.DEV_MODE then
    surface.create_entity{
      name = "small-electric-pole",
      position = Utils.positionAdd(position, {0, -2}),
      force = Config.PLAYER_FORCE,
      create_build_effect_smoke = false
    }
    surface.create_entity{
      name = "solar-panel",
      position = Utils.positionAdd(position, {-3, 0}),
      force = Config.PLAYER_FORCE,
      create_build_effect_smoke = false
    }
  end

  teleporter.destructible = false
  teleporter.minable = false
  teleporter.energy = 0
  teleporter.backer_name = city.full_name

  ---@type global.teleporter
  local teleporter_data = {
    entity = teleporter,
    city = city,
  }
  setmetatable(teleporter_data, tele_meta)

  teleporters[teleporter.unit_number] = teleporter_data
  city.teleporter = teleporter_data
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_charted
function Teleporter.onCityCharted(event)
  local surface = event.surface
  local city = world.cities[event.city_name]
  local teleporter = city.teleporter
  local position = city.position
  if teleporter and teleporter.valid then
    position = teleporter.position
  end

  local tag = {
    icon = { type = 'virtual', name = "signal-info" },
    position = position,
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
  for _, teleporter in pairs(global.teleporters) do
    setmetatable(teleporter, tele_meta)
  end
  teleporters = global.teleporters
  world = global.world
end

-- ============================================================================

return Teleporter

---@class global
---@field teleporters {[uint]: global.teleporter}

---@class global.teleporter: LuaEntity
---@field entity LuaEntity
---@field city global.city

---@class global.city
---@field teleporter global.teleporter
