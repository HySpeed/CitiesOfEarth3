local Config = require("config")
local Player = require("scripts/coe_player")

if Config.DEV_MODE then
  commands.add_command("Teleport", "", function(command)
    local player = game.get_player(command.player_index)
    if not command.parameter then
      for _, target_city in pairs(global.map.cities) do
        Player.teleport(player, target_city, nil, 5)
      end
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
