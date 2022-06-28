---@class coe.Player
local Player = {}

local Config = require("config")
local Utils = require("scripts/coe_utils")

local worldgen ---@type global.worldgen
local world ---@type global.world

-- =============================================================================

---@param player LuaPlayer
local function setupForDevMode(player)
  player.print("!!! DEV MODE ENABLED!!!")
  player.print("World: " .. worldgen.world_name)
  player.print("Data Size: {" .. worldgen.decompressed_width .. ", " .. worldgen.decompressed_height .. "}")
  player.print("World Size: {" .. worldgen.width .. ", " .. worldgen.height .. "}")
  player.print("Radius: {" .. worldgen.width_radius .. ", " .. worldgen.height_radius .. "}")
  player.print("Scale: " .. worldgen.scale)
  player.print("Spawn: " .. world.spawn_city.name)
  if global.silo_settings.pre_place_silo then
    player.print("Silo: " .. world.silo_city.name)
    global.silo_settings.required_launches = 2
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

Player.checkAndGenerateChunk = Utils.checkAndGenerateChunk

---Teleports player after checking if target is safe. Pass a teleporter to use it for teleporting
---@param player LuaPlayer
---@param target_city global.city
---@param teleporter? LuaEntity
---@param radius? number
function Player.teleport( player, target_city, teleporter, radius )
  radius = radius or 0
  local surface = world.surface
  Player.checkAndGenerateChunk( surface, target_city.position, radius )

  local target = target_city.position
  local teleport = surface.find_non_colliding_position("character", target_city.position, 8, .25)

  if teleport and player.teleport(teleport, surface) then
    player.force.chart(world.surface, Utils.positionToChunkArea(target))
    game.print( {"",  {"coe.text_mod_name"}, {"coe.text_teleported"}, player.name,
                {"coe.text_to"}, target_city.full_name,
                "  (", teleport.x, ",", teleport.y, ") "} )
  else
    game.print( {"",  {"coe.text_mod_name"}, {"coe.text_unable_to_teleport"},
                player.name, {"coe.text_to"}, target_city.full_name, "  (", target.x,
                ",", target.y, ") ", {"coe.text_count"}, 100} )
  end
  if teleporter then teleporter.energy = 0 end
end -- PerformTeleport

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Player.onCityGenerated(event)
  local city = world.cities[event.city_name]
  if not city.is_spawn_city then return end
  game.forces["player"].set_spawn_position(city.position, event.surface)

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
  global.players[event.player_index] = {index = event.player_index}

  local player = game.get_player(event.player_index)
  if Config.DEV_MODE then setupForDevMode(player) end
  Utils.devPrint("Player " .. player.name.. " created.", true)

  if world.spawn_city.generated and player.surface ~= world.surface then
    Player.teleport(player, world.spawn_city, nil)
  end
end

-- ============================================================================

function Player.onInit()
  global.players = {}
  worldgen = global.worldgen
  world = global.world
  for index in pairs(game.players) do
    Player.onPlayerCreated { player_index = index--[[@as uint]]}
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
