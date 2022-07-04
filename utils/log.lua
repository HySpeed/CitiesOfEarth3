---@class coe.log
local Log = {}

local Config = require("config")

-- =============================================================================

---@param msg LocalisedString
---@param skip_game_print? boolean
function Log.print(msg, skip_game_print)
  if Config.DEV_MODE then
    if not skip_game_print and game then game.print(msg) end
    log(msg)
  end
end

-- =============================================================================

return Log
