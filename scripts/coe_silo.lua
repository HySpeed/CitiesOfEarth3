---@class coe.Silo
local Silo = {}

---@class global
---@field silo global.silo
---@class global.silo
---@field launch_success boolean
---@field launches_to_win number
---@field launches_per_death number

---@param event on_chunk_generated
function Silo.onChunkGenerated(event)
end

---@param event on_chunk_charted
function Silo.onChunkCharted(event)
end

---@param event on_player_died
function Silo.onPlayerDied(event)
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

function Silo.onInit()
  global.silo = {}
end

return Silo
