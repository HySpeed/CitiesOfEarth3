---@class coe.Player
local Player = {}

local Utils = require("utils/utils")

local worldgen ---@type global.worldgen
local world ---@type global.world

-- =============================================================================

Player.checkAndGenerateChunk = Utils.checkAndGenerateChunk

---@param player LuaPlayer
local function setupForDevMode(player)
  player.print("!!! DEV MODE ENABLED!!!")
  player.print("World: " .. worldgen.world_name)
  player.print("Data Size: {" .. worldgen.decompressed_width .. ", " .. worldgen.decompressed_height .. "}")
  player.print("World Size: {" .. worldgen.width .. ", " .. worldgen.height .. "}")
  player.print("Radius: {" .. worldgen.width_radius .. ", " .. worldgen.height_radius .. "}")
  player.print("Scale: " .. worldgen.scale)
  player.print("Spawn: " .. world.spawn_city.name)
  if settings.startup.coe_pre_place_silo.value then
    player.print("Silo: " .. world.silo_city.name)
    global.rocket_silo.required_launches = 2
  end

  player.get_inventory(defines.inventory.character_armor).insert("power-armor-mk2")
  local armor = player.character.grid
  armor.put({ name = "fusion-reactor-equipment" })
  armor.put({ name = "fusion-reactor-equipment" })
  armor.put({ name = "exoskeleton-equipment" })
  armor.put({ name = "exoskeleton-equipment" })
  armor.put({ name = "exoskeleton-equipment" })
  armor.put({ name = "exoskeleton-equipment" })
  armor.put({ name = "exoskeleton-equipment" })
  armor.put({ name = "exoskeleton-equipment" })
  armor.put({ name = "personal-roboport-mk2-equipment" })
  armor.put({ name = "personal-roboport-mk2-equipment" })
  armor.put({ name = "personal-roboport-mk2-equipment" })
  armor.put({ name = "personal-roboport-mk2-equipment" })
  armor.put({ name = "battery-mk2-equipment" })
  armor.put({ name = "battery-mk2-equipment" })
  player.insert { name = "construction-robot", count = 100 }
  player.insert { name = "landfill", count = 500 }
end -- setupForDevMode

-------------------------------------------------------------------------------

---@param position MapPosition
---@return string
local function makeGpsTag(position)
  local gps = {
    " [img=utility/map]",
    "[color=green]",
    " [",
    position.x,
    ", ",
    position.y,
    "]",
    "[/color]",
  }
  return table.concat(gps)
end

---Teleports player after checking if target is safe. Pass a teleporter to use it for teleporting
---@param player LuaPlayer
---@param target_city global.city
---@param source_teleporter? LuaEntity
---@param energy_usage? double
function Player.teleport(player, target_city, source_teleporter, energy_usage)
  local surface = world.surface
  Player.checkAndGenerateChunk(surface, target_city.position, 0)

  local target = target_city.position
  if target_city.teleporter and target_city.teleporter.valid then
    target = Utils.positionAdd(target_city.teleporter.position, {0, 2})
  end
  target = surface.find_non_colliding_position("character", target, 8, .25)

  if target and player.teleport(target, surface) then
    player.force.chart(world.surface, Utils.positionToChunkArea(target))
    local gps = makeGpsTag(target)
    player.print{"coe-player.teleported", player.name, target_city.full_name, gps}
  else
    local gps = makeGpsTag(target_city.position)
    player.print{"coe-player.teleport-failed", player.name, target_city.full_name, gps}
  end
  if source_teleporter then
    source_teleporter.energy = source_teleporter.energy - (energy_usage or 0) end
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Player.onCityGenerated(event)
  local city = world.cities[event.city_name]
  if not city.is_spawn_city then return end

  -- Teleport all players who havn't been teleported to spawn city.
  for _, player in pairs(game.players) do
    if player.surface ~= event.surface then
      Player.teleport(player, city, nil)
    end
  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_player_created
function Player.onPlayerCreated(event)
  global.players[event.player_index] = { index = event.player_index }

  local player = game.get_player(event.player_index)
  if Utils.getStartupSetting("coe_dev_mode") then setupForDevMode(player) end
  Utils.print("Player " .. player.name .. " created.", true)

  if world.spawn_city.generated and player.surface ~= world.surface then
    Player.teleport(player, world.spawn_city, nil)
  end
end

-- ============================================================================

function Player.onInit()
  global.players = {}
  worldgen = global.worldgen
  world = global.world
  for index in pairs(game.players)--[[@as uint]] do
    Player.onPlayerCreated { player_index = index  }
  end
end

-------------------------------------------------------------------------------

function Player.onLoad()
  worldgen = global.worldgen
  world = global.world
end

-- ============================================================================

return Player

---@class global
---@field players {[uint]: global.player}
---@class global.player
---@field index uint
