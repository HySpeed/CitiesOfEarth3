---Helper class, should not require other script files
---@class coe.Player
local Player = {}

local Utils = require("utils/utils")

-- =============================================================================

---@param player LuaPlayer
local function setupForDevMode( player )
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
  armor.put { name = "battery-mk2-equipment" }
  armor.put { name = "battery-mk2-equipment" }
  armor.put { name = "battery-mk2-equipment" }
  armor.put { name = "battery-mk2-equipment" }
  armor.put { name = "personal-roboport-mk2-equipment" }
  armor.put { name = "personal-roboport-mk2-equipment" }
  player.insert({ name = "landfill",    count = 200 })
  player.insert({ name = "grenade",     count = 100 })
  player.insert({ name = "rocket-launcher", count = 1 })
  player.insert({ name = "rocket",      count = 200 })
  player.insert({ name = "atomic-bomb", count = 10 })

  player.insert({ name = "satellite",   count = 5 })
  player.insert({ name = "rocket-fuel", count = 3 })
  player.insert({ name = "small-electric-pole", count = 50 })

end

-------------------------------------------------------------------------------

---@param event EventData.on_player_created
function Player.onPlayerCreated( event )
  global.players[event.player_index] = {
    index = event.player_index 
  }
  local player = game.get_player( event.player_index )

  if Utils.getStartupSetting( "coe_team_coop" ) then
    for _, city in pairs( global.world.cities ) do
      local tag = {
        icon = { type = "virtual", name = "signal-info" },
        position = city.position,
        text = "     " .. city.name
      }
        --   -- loop through forces, add chart tags to each
      for _, force in pairs( game.forces ) do
        player.force = force
        force.add_chart_tag( global.world.surface, tag )
      end
    end
  end

  player.force = game.forces[global.world.spawn_city.name]
  if settings.startup.coe_dev_mode then setupForDevMode( player ) end

  -- TODO add check for # of cities.  3 == dev mode
  Utils.print("Player " .. player.name .. " created", true)
end

-- ============================================================================

function Player.onInit()
  global.players = {}
  for index in pairs(game.players--[[@as table<uint>]] ) do
    Player.onPlayerCreated( { player_index = index } )
  end
end

-- ============================================================================

return Player

---@class coe.global
---@field players {[uint]: coe.player}

---@class coe.player
---@field index uint
