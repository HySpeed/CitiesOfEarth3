---@class coe.Player
local Player = {}

---@class global
---@field players {[uint]: global.player}
---@class global.player
---@field index uint

local Config = require("config")
local Utils = require("scripts/coe_utils")

local Map ---@type global.map

-- =============================================================================

---@param player LuaPlayer
local function setupForDevMode(player)
  player.print("!!! DEV MODE ENABLED!!!")
  player.print("World: " .. Map.world_name)
  player.print("Data Size: {" .. Map.decompressed_width .. ", " .. Map.decompressed_height .. "}")
  player.print("World Size: {" .. Map.width .. ", " .. Map.height .. "}")
  player.print("Radius: {" .. Map.width_radius .. ", " .. Map.height_radius .. "}")
  player.print("Scale: " .. Map.scale)
  player.print("Spawn: " .. Map.spawn_city)
  if global.silo.pre_place_silo then
    player.print("Silo: " .. Map.silo_city)
    global.silo.required_launches = 2
  end

  local inv = defines.inventory.character_armor
  local parmor = "power-armor-mk2"

  player.get_inventory(inv).insert(parmor)
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

Player.checkAndGenerateChunk = Utils.checkAndGenerateChunk

---Teleports player after checking if target is safe. Pass a teleporter to use it for teleporting
---@param player LuaPlayer
---@param target_city coe.City
---@param teleporter? LuaEntity
---@param radius? number
function Player.teleport( player, target_city, teleporter, radius )
  radius = radius or 0
  local surface = Map.surface
  Player.checkAndGenerateChunk( surface, target_city.position, radius )

  local target = target_city.position
  local teleport = surface.find_non_colliding_position("character", target_city.position, 8, .25)

  if teleport and player.teleport(teleport, surface) then
    player.force.chart(Map.surface, Utils.positionToChunkArea(target))
    game.print( {"",  {"coe.text_mod_name"}, {"coe.text_teleported"}, player.name,
                {"coe.text_to"}, target_city.fullname,
                "  (", teleport.x, ",", teleport.y, ") "} )
  else
    game.print( {"",  {"coe.text_mod_name"}, {"coe.text_unable_to_teleport"},
                player.name, {"coe.text_to"}, target_city.fullname, "  (", target.x,
                ",", target.y, ") ", {"coe.text_count"}, 100} )
  end
  if teleporter then teleporter.energy = 0 end
end -- PerformTeleport

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Player.onCityGenerated(event)
  local city = Map.cities[event.city_name]
  if not city.spawn_city then return end
  game.forces["player"].set_spawn_position(city.position, event.surface)
  for _, player in pairs(game.players) do
    if player.surface ~= event.surface then
      Player.teleport(player, city, nil)
    end
  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_player_created
function Player.onPlayerCreated(event)
  global.players[event.player_index] = {index = event.player_index}

  local player = game.get_player(event.player_index)
  if Config.DEV_MODE then setupForDevMode(player) end
  log("Player " .. player.name.. " created.")
  local spawn_city = Map.cities[Map.spawn_city]
  if spawn_city.generated and player.surface ~= Map.surface then
    Player.teleport(player, spawn_city, nil)
  end
end

-- ============================================================================

function Player.onInit()
  global.players = {}
  Map = global.map
  for index in pairs(game.players) do
    Player.onPlayerCreated { player_index = index--[[@as uint]]}
  end
end

-------------------------------------------------------------------------------

function Player.onLoad()
  Map = global.map
end

-- ============================================================================

return Player
