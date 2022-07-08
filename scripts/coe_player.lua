---Helper class, should not require other script files
---@class coe.Player
local Player = {}

local Utils = require("utils/utils")

-- =============================================================================

---@param player LuaPlayer
local function setupForDevMode(player)
  local worldgen = global.worldgen
  local world = global.world

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

---@param event EventData.on_player_created
function Player.onPlayerCreated(event)
  global.players[event.player_index] = { index = event.player_index }

  local player = game.get_player(event.player_index)
  if Utils.getStartupSetting("coe_dev_mode") then setupForDevMode(player) end
  Utils.print("Player " .. player.name .. " created.", true)
end

-- ============================================================================

function Player.onInit()
  global.players = {}
  for index in pairs(game.players)--[[@as uint]] do
    Player.onPlayerCreated { player_index = index  }
  end
end

-- ============================================================================

return Player

---@class global
---@field players {[uint]: global.player}
---@class global.player
---@field index uint
