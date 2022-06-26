---@class coe.Silo
local coeSilo = {}

local coeUtils = require("scripts.coe_utils")
local Silo
local Map ---@type global.map

---@class global
---@field silo global.silo
---@class global.silo
---@field launch_success boolean
---@field launches_to_win number
---@field launches_per_death number

---@param event on_city_generated
function coeSilo.onCityGenerated(event)
  -- if Silo.placed or not Silo.pre_place_silo then return end
  -- local silo_position = coeUtils.add_position(Map.silo_city.position, 0, 10
  -- local silo_chunk = coeUtils.to_chunk_position(Map.silo_city.position)
  -- event.position == silo_chunk

  -- --   local position = util.table.deepcopy( global.coe.silo_city.position )
  -- --   if coeUtils.CheckIfInArea( position, event.area ) then
  -- --     placeSilo( global.coe.surface, position )
  -- --     global.coe.silo_created = true;
  -- --     if global.coe.dev_mode then
  -- --       game.print( {"",  {"coe.text_silo_placed"}, global.coe.silo_city.name} )
  -- --     end
  -- --   end
  -- -- end
end

---@param event on_chunk_charted
function coeSilo.onChunkCharted(event)
end

---@param event on_player_died
function coeSilo.onPlayerDied(event)
  -- only record a death if the setting is enabled and success hasn't completed
  local launches_per_death = settings.global.coe_launches_per_death.value ---@type number

  if launches_per_death <= 0 or global.silo.launch_success then return end
  global.silo.launches_to_win = global.silo.launches_to_win + launches_per_death

  game.print({
    "", { "coe.text_mod_name" }, { "coe.text_death_of" }, game.players[event.player_index].name, { "coe.text_increased_launches" },
    tostring(launches_per_death)
  })
  game.print({ "", { "coe.text_mod_name" }, tostring(global.silo.launches_to_win), { "coe.text_more_rockets" } })
end -- recordPlayerDeath

function coeSilo.onInit()
  global.silo = {
    pre_place_silo = settings.startup.coe_pre_place_silo.value--[[@as boolean]],
    silo_placed = false,
  }
  Silo = global.silo
  Map = global.map
end

function coeSilo.onLoad()
  Silo = global.silo
  Map = global.map
end

return coeSilo
