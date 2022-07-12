---@class coe.Teleporter
local Teleporter = {}

local Config = require("config")
local Utils = require("utils/utils")
local Surface = require("scripts/coe_surface")

local teleporters ---@type {[uint]: coe.teleporter}
local world ---@type coe.world

---Allow our Teleporter object to directly reference the teleporter entity
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
---@param city coe.city
---@return LuaEntity?
local function create_teleporter(surface, city)
  if not settings.startup["coe_create_teleporters"].value then return end

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
    Utils.print("WARNING: Failed to build teleporter: " ..
      city.name .. " " .. Utils.positionToStr(build_params.position))
    return --It really shouldn't fail at this point.
  end

  return teleporter
end

-------------------------------------------------------------------------------

---@param position MapPosition
---@return string
local function make_gps_tag(position)
  local gps = { " [img=utility/map]", "[color=green]", " [", position.x, ", ", position.y, "]", "[/color]", }
  return table.concat(gps)
end

-------------------------------------------------------------------------------

---@param player LuaPlayer
local function drain_equipment(player)
  local character = player.character
  local grid = character and character.grid
  if not grid then return end
  for _, equipment in pairs(grid.equipment) do
    equipment.energy = 0
  end
end

-- ============================================================================

---Teleports player after checking if target is safe. Pass a teleporter to use it for teleporting
---@param player LuaPlayer
---@param target_city coe.city
---@param source_teleporter? LuaEntity
---@param energy_usage? double
function Teleporter.teleport(player, target_city, source_teleporter, energy_usage)
  local surface = world.surface
  Surface.checkAndGenerateChunk(surface, target_city.position, 0)

  local target = target_city.position
  if target_city.teleporter and target_city.teleporter.valid then
    target = Utils.positionAdd(target_city.teleporter.position, { 0, 2 })
  end
  target = surface.find_non_colliding_position("character", target, 8, .25)

  if target and player.teleport(target, surface) then
    local should_drain = settings.global.coe_drain_energy_on_teleport.value
    player.force.chart(world.surface, Utils.positionToChunkTileArea(target))
    local gps = make_gps_tag(target)
    player.print { "coe-player.teleported", player.name, target_city.full_name, gps }
    if should_drain then
      if source_teleporter then source_teleporter.energy = source_teleporter.energy - (energy_usage or 0) end
      drain_equipment(player)
    end
  else
    local gps = make_gps_tag(target_city.position)
    player.print { "coe-player.teleport-failed", player.name, target_city.full_name, gps }
  end
end

-- ============================================================================

---@param event EventData.on_player_created
function Teleporter.onPlayerCreated(event)
  local player = game.get_player(event.player_index)
  if world.spawn_city.generated and player.surface ~= world.surface then
    Teleporter.teleport(player, world.spawn_city, nil)
    log("Teleporting player " .. player.name .. " to " .. world.spawn_city.name)
  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Teleporter.onCityGenerated(event)
  local city = world.cities[event.city_name]

  if city.is_spawn_city then
    for _, player in pairs(game.players) do
      if player.surface ~= event.surface then
        Teleporter.teleport(player, city, nil)
        log("Teleporting player " .. player.name .. " to " .. world.spawn_city.name)
      end
    end
  end

  if not settings.startup.coe_create_teleporters.value then return end

  local surface = event.surface
  local teleporter = create_teleporter(surface, city)
  if not teleporter then return end

  Surface.decorate(event.surface, teleporter)
  local position = teleporter.position
  if Utils.getStartupSetting("coe_dev_mode") then
    surface.create_entity {
      name = "small-electric-pole",
      position = Utils.positionAdd(position, { 0, -2 }),
      force = Config.PLAYER_FORCE,
      create_build_effect_smoke = false
    }
    surface.create_entity {
      name = "solar-panel",
      position = Utils.positionAdd(position, { -3, 0 }),
      force = Config.PLAYER_FORCE,
      create_build_effect_smoke = false
    }
  end

  teleporter.destructible = false
  teleporter.minable = false
  teleporter.energy = 0
  teleporter.backer_name = city.full_name

  ---@type coe.teleporter
  local teleporter_data = {
    entity = teleporter,
    city = city,
  }
  setmetatable(teleporter_data, tele_meta)

  teleporters[teleporter.unit_number] = teleporter_data
  city.teleporter = teleporter_data

  if not city.is_spawn_city and settings.startup.coe_all_teleporters_available.value then
    world.force.chart(event.surface, Utils.chunkPositionToTileArea(event.chunk))
  end
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
    icon = { type = "virtual", name = "signal-info" },
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
  ---@todo 1.1.62, use script.register_metatable
  for _, teleporter in pairs(global.teleporters) do
    setmetatable(teleporter, tele_meta)
  end
  teleporters = global.teleporters
  world = global.world
end

-- ============================================================================

return Teleporter

---@class coe.global
---@field teleporters {[uint]: coe.teleporter}

---@class coe.teleporter: LuaEntity
---@field entity LuaEntity
---@field city coe.city

---@class coe.city
---@field teleporter coe.teleporter
