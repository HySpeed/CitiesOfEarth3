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
  player.print("Radius: {" .. worldgen.width_radius .. ", " .. worldgen.height_radius .. "}")
  player.print("Scale: " .. worldgen.scale)
  player.print("Spawn: " .. world.spawn_city.name)

  player.get_inventory(defines.inventory.character_armor).insert("power-armor-mk2")
  local armor = player.character.grid
  armor.put { name = "fusion-reactor-equipment" }
  armor.put { name = "fusion-reactor-equipment" }
  armor.put { name = "exoskeleton-equipment" }
  armor.put { name = "exoskeleton-equipment" }
  armor.put { name = "exoskeleton-equipment" }
  armor.put { name = "exoskeleton-equipment" }
  armor.put { name = "exoskeleton-equipment" }
  armor.put { name = "exoskeleton-equipment" }
  armor.put { name = "personal-roboport-mk2-equipment" }
  armor.put { name = "personal-roboport-mk2-equipment" }
  armor.put { name = "personal-roboport-mk2-equipment" }
  armor.put { name = "personal-roboport-mk2-equipment" }
  armor.put { name = "battery-mk2-equipment" }
  armor.put { name = "battery-mk2-equipment" }
  player.insert({ name = "construction-robot", count = 50 })
  player.insert({ name = "landfill", count = 200 })
  -- Steam Power
  player.insert({name="offshore-pump", count=10})
  player.insert({name="substation", count=20})
  player.insert({name="nuclear-fuel", count=49})
  player.insert({name="boiler", count=20})
  player.insert({name="steam-engine", count=40})
  player.insert({name="transport-belt", count=100})
  player.insert({name="pipe", count=100})
  player.insert({name="medium-electric-pole", count=50})
  player.insert({name="stack-inserter", count=50})
  player.insert({name="logistic-chest-requester", count=50})
  -- Rocket Silo
  player.insert({name="rocket-silo", count=1})
  player.insert({name="roboport", count=10})
  player.insert({name="logistic-robot", count=800})
  player.insert({name="beacon", count=20})
  player.insert({name="speed-module-3", count=50})
  player.insert({name="satellite", count=5})

end -- setupForDevMode

-------------------------------------------------------------------------------

---@param event EventData.on_player_created
function Player.onPlayerCreated(event)
  global.players[event.player_index] = { index = event.player_index }

  local player = game.get_player(event.player_index)
  if Utils.getStartupSetting("coe_dev_mode") then setupForDevMode(player) end
  Utils.print("Player " .. player.name .. " created at tick " .. event.tick, true)
end

-- ============================================================================

function Player.onInit()
  global.players = {}
  for index in pairs(game.players--[[@as table<uint>]] ) do
    Player.onPlayerCreated { player_index = index }
  end
end

-- ============================================================================

return Player

---@class coe.global
---@field players {[uint]: coe.player}

---@class coe.player
---@field index uint
