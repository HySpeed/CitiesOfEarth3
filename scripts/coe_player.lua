---@class coe.Player
local Player = {}

---@class global
---@field players {[uint]: global.player}
---@class global.player
---@field index uint

local coeConfig = require("config")
local Surface = require("scripts/coe_surface")

-- =============================================================================

if coeConfig.DEV_MODE then
  commands.add_command("Teleport", "", function(command)
    local player = game.get_player(command.player_index)
    if not command.parameter then
      for _, target_city in pairs(global.map.cities) do
        Player.Teleport(player, target_city, nil, 5)
      end
      player.force.chart_all(global.map.surface--[[@as SurfaceIdentification]])
      return
    end
    local city = global.map.cities[command.parameter]
    if city then
      Player.Teleport(player, city, nil, 0)
    else
      player.print("Invalid teleport target ".. command.parameter)
    end
  end)
end

--------------------------------------------------------------------------------

---@param player LuaPlayer
local function setupForDevMode(player)
  player.print("!!! DEV MODE ENABLED!!!")
  player.print("World: " .. global.map.world_name)
  player.print("Data Size: {" .. global.map.decompressed_width .. ", " .. global.map.decompressed_height .. "}")
  player.print("World Size: {" .. global.map.width .. ", " .. global.map.height .. "}")
  player.print("Radius: {" .. global.map.width_radius .. ", " .. global.map.height_radius .. "}")
  player.print("Scale: " .. global.map.scale)
  if settings.startup.coe_pre_place_silo then
    player.print("!(dev) silo: " .. global.map.silo_city.name)
    global.silo.launches_to_win = 2
  end

  player.get_inventory(defines.inventory.character_armor--[[@as defines.inventory]]).insert--[[@as ItemStackIdentification]]("power-armor-mk2")
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

-- =============================================================================

---Teleports player after checking if target is safe. Pass a teleporter to use it for teleporting
---@param player LuaPlayer
---@param target_city coe.City
---@param teleporter? LuaEntity
---@param radius? number
function Player.Teleport( player, target_city, teleporter, radius )
  radius = radius or 0
  local surface = global.map.surface
  Surface.CheckAndGenerateChunk( surface, target_city.position, radius )

  local target = target_city.position
  local teleport = surface.find_non_colliding_position("character", target_city.position, 8, .25)

  if teleport and player.teleport(teleport, surface--[[@as SurfaceIdentification]]) then
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

-- =============================================================================

---@param event on_player_created
function Player.onPlayerCreated(event)
  global.players[event.player_index] = {index = event.player_index}

  local player = game.get_player(event.player_index)
  if coeConfig.DEV_MODE then setupForDevMode(player) end
  Player.Teleport(player, global.map.spawn_city, nil)
end

--------------------------------------------------------------------------------

function Player.onInit()
  global.players = {}
  for index in pairs--[[@as uint]](game.players) do
    Player.onPlayerCreated { player_index = index}
  end
end

function Player.onLoad()
end

return Player
