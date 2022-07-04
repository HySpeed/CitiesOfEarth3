local Config = require("config")
local Utils = require("utils/utils.lua")
local Player = require("scripts/coe_player")

if Config.DEV_MODE then
  commands.add_command("Teleport", "", function(command)
    local player = game.get_player(command.player_index)

    if not command.parameter then
      local random_city_name = global.world.city_names[math.random(1, #global.world.city_names)]
      return Player.teleport(player, global.world.cities[random_city_name])
    end

    local city_name = Utils.titleCase(command.parameter)
    if global.world.cities[city_name] then
      return Player.teleport(player, global.world.cities[city_name])
    end

    if city_name == "All" then
      for _, target_city in pairs(global.world.cities) do
        Player.teleport(player, target_city)
        global.world.force.chart(global.world.surface, Utils.positionToChunkArea(target_city.position))
      end
      return
    end
    player.print("Invalid teleport target ".. command.parameter .." no parameter for random teleport, or city name, or All")
  end)
end

-------------------------------------------------------------------------------
