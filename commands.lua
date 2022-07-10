local Utils = require("utils/utils")
local Teleporter = require("scripts/coe_teleporter")

if Utils.getStartupSetting("coe_dev_mode") then
  commands.add_command("Teleport", "", function(command)
    local player = game.get_player(command.player_index)

    if not command.parameter then
      local random_city_name = global.world.city_names[math.random(1, #global.world.city_names)]
      return Teleporter.teleport(player, global.world.cities[random_city_name])
    end

    local city_name = Utils.titleCase(command.parameter)
    if global.world.cities[city_name] then
      return Teleporter.teleport(player, global.world.cities[city_name])
    end

    if city_name == "All" then
      for _, target_city in pairs(global.world.cities) do
        Teleporter.teleport(player, target_city)
        global.world.force.chart(global.world.surface, Utils.positionToChunkArea(target_city.position))
      end
      return
    end
    player.print("Invalid teleport target " .. command.parameter .. " no parameter for random teleport, or city name, or All")
  end)

  commands.add_command("ChartWorld", "", function()
    local mgs = global.world.surface.map_gen_settings
    global.world.force.chart(global.world.surface, { { -mgs.width / 2, -mgs.height / 2 }, { mgs.width / 2, mgs.height / 2 } })
  end)
end

-------------------------------------------------------------------------------
