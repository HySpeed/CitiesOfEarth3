-- Credit:
-- -- The Oddlers Factorio World
-- -- -- The world loader is done via his code
-- -- MojoD -- Frontier Extended
-- -- -- The Pre-Placed Silo is from his work
-- -- OARC
-- -- -- Terrain manipulation
-- -- Nexela
-- -- -- code reviews and guidance
-- You may re-use what is written here. It would be nice to give credit where you can.


local Utils = require("utils/utils")
local Player = require("scripts/coe_player")
local Surface = require("scripts/coe_surface")
local WorldGen = require("scripts/coe_worldgen")
local Silo = require("scripts/coe_silo")
local Teleporter = require("scripts/coe_teleporter")
local TeleporterGUI = require("scripts/coe_teleporter_gui")
local StatsGUI = require("scripts/coe_stats_gui")

require("commands")

---@param event EventData.CustomInputEvent
local function run_test_function(event)
end

-- =============================================================================

---Load order matters for init and load
---WorldGen -> Player -> Others

script.on_init(function()
  ---@class coe.global
  global = {}
  Utils.skipIntro()
  WorldGen.onInit()
  Player.onInit()
  Surface.onInit()
  Silo.onInit()
  Teleporter.onInit()
end)

---Use on_load to setup metatables and link local upvalues
script.on_load(function()
  WorldGen.onLoad()
  Surface.onLoad()
  Silo.onLoad()
  Teleporter.onLoad()
end)

script.on_event(defines.events.on_player_created, function(event)
  Player.onPlayerCreated(event)
  Teleporter.onPlayerCreated(event)
  StatsGUI.onPlayerCreated(event)
end)

script.on_event(defines.events.on_player_died, Silo.onPlayerDied)

script.on_event(defines.events.on_chunk_generated, function(event)
  if not WorldGen.onChunkGenerated(event) then return end
  Surface.onChunkGenerated(event)
end)

script.on_event(defines.events.on_chunk_charted, Surface.onChunkCharted)

script.on_event(Surface.on_city_generated, function(event)
  if not Surface.onCityGenerated(event) then return end
  Teleporter.onCityGenerated(event)
  Silo.onCityGenerated(event)
end)

script.on_event(Surface.on_city_charted, function(event)
  if not Surface.onCityCharted(event) then return end
  Teleporter.onCityCharted(event)
  Silo.onCityCharted(event)
end)

script.on_event(defines.events.on_research_finished, Silo.onResearchFinished)

script.on_event(defines.events.on_rocket_launched, Silo.onRocketLaunched)

script.on_event(defines.events.on_surface_cleared, WorldGen.onSurfaceCleared)

script.on_event(defines.events.on_gui_opened, TeleporterGUI.onGuiOpened)

script.on_event(defines.events.on_gui_closed, TeleporterGUI.onGuiClosed)

---Return any truthy value from these events to stop processing the next event
script.on_event(defines.events.on_gui_click, function(event)
  if TeleporterGUI.onGuiClick(event) then return end
  if StatsGUI.onGuiClick(event) then return end
end)

script.on_nth_tick(60, TeleporterGUI.onNthTick)

if Utils.getStartupSetting("coe_dev_mode") then
  script.on_event("coe-reload-mods", Utils.reload_mods)
  script.on_event("coe-run-function", run_test_function)
end
