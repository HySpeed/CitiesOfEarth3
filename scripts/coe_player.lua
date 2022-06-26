---@class coe.Player
local Player = {}

---@class global
---@field players {[uint]: global.player}
---@class global.player
---@field index uint

local Config = require("config")
local Surface = require("scripts/coe_surface")

-- =============================================================================

if Config.DEV_MODE then
  commands.add_command("Teleport", "", function(command)
    local player = game.get_player(command.player_index)
    if not command.parameter then
      for _, target_city in pairs(global.map.cities) do
        Player.teleport(player, target_city, nil, 5)
      end
      player.force.chart_all(global.map.surface)
      return
    end
    local city = global.map.cities[command.parameter]
    if city then
      Player.teleport(player, city, nil, 0)
    else
      player.print("Invalid teleport target ".. command.parameter)
    end
  end)
end

-------------------------------------------------------------------------------

---@param player LuaPlayer
local function setupForDevMode(player)
  player.print("!!! DEV MODE ENABLED!!!")
  player.print("World: " .. global.map.world_name)
  player.print("Data Size: {" .. global.map.decompressed_width .. ", " .. global.map.decompressed_height .. "}")
  player.print("World Size: {" .. global.map.width .. ", " .. global.map.height .. "}")
  player.print("Radius: {" .. global.map.width_radius .. ", " .. global.map.height_radius .. "}")
  player.print("Scale: " .. global.map.scale)
  if settings.startup.coe_pre_place_silo then
    player.print("!(dev) silo: " .. global.map.silo_city)
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

---Teleports player after checking if target is safe. Pass a teleporter to use it for teleporting
---@param player LuaPlayer
---@param target_city coe.City
---@param teleporter? LuaEntity
---@param radius? number
function Player.teleport( player, target_city, teleporter, radius )
  radius = radius or 0
  local surface = global.map.surface
  Surface.checkAndGenerateChunk( surface, target_city.position, radius )

  local target = target_city.position
  local teleport = surface.find_non_colliding_position("character", target_city.position, 8, .25)

  if teleport and player.teleport(teleport, surface) then
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
  local city = Surface.getCity(event.city_name)
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
  local spawn_city = Surface.getSpawnCity()
  if spawn_city.generated and player.surface ~= global.map.surface then
    Player.teleport(player, spawn_city, nil)
  end
end

-- ============================================================================

function Player.onInit()
  global.players = {}
  for index in pairs(game.players) do
    Player.onPlayerCreated { player_index = index--[[@as uint]]}
  end
end

-------------------------------------------------------------------------------

function Player.onLoad()
end

-- ============================================================================

return Player
