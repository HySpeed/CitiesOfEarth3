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


local Config = require("config")
local Log = require("utils/log")
local Utils = require("utils/utils.lua")
local Player = require("scripts/coe_player")
local Surface = require("scripts/coe_surface")
local WorldGen = require("scripts/coe_worldgen")
local Silo = require("scripts/coe_silo")
local Teleporter = require("scripts/coe_teleporter")
local TeleporterGUI = require("scripts/coe_teleporter_gui")
local StatsGUI = require("scripts/coe_stats_gui")

-- =============================================================================

---Load order matters for init and load
---WorldGen -> Player -> Others

script.on_init(function()
  ---@class global
  global = {}
  Utils.skipIntro()
  WorldGen.onInit()
  Player.onInit()
  Surface.onInit()
  Silo.onInit()
  Teleporter.onInit()
end)

script.on_load(function()
  WorldGen.onLoad()
  Player.onLoad()
  Surface.onLoad()
  Silo.onLoad()
  Teleporter.onLoad()
end)

script.on_event(defines.events.on_player_created, function(event)
  Player.onPlayerCreated(event)
end)

script.on_event(defines.events.on_player_died, Silo.onPlayerDied)

script.on_event(defines.events.on_chunk_generated, function(event)
  WorldGen.onChunkGenerated(event)
  Surface.onChunkGenerated(event)
end)

script.on_event(defines.events.on_chunk_charted, Surface.onChunkCharted)

script.on_event(Surface.on_city_generated, function(event)
  Surface.onCityGenerated(event)
  Teleporter.onCityGenerated(event)
  Silo.onCityGenerated(event)
  Player.onCityGenerated(event)
end)

script.on_event(Surface.on_city_charted, function(event)
  Surface.onCityCharted(event)
  Teleporter.onCityCharted(event)
  Silo.onCityCharted(event)
end)

script.on_event(defines.events.on_research_finished, Silo.onResearchFinished)

script.on_event(defines.events.on_rocket_launched, Silo.onRocketLaunched)

script.on_event(defines.events.on_surface_cleared, WorldGen.onSurfaceCleared)

script.on_event(defines.events.on_gui_opened, TeleporterGUI.onGuiOpened)

script.on_event(defines.events.on_gui_closed, TeleporterGUI.onGuiClosed)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "coe_teleporter_gui_close" or next( event.element.tags ) ~= nil then
    TeleporterGUI.onGuiClick(event)
  elseif event.element.name == "coe_button_statistics" then
    StatsGUI.onGuiClick(event)
  end
end)

script.on_nth_tick(60, TeleporterGUI.onNthTick)

if Config.DEV_MODE then
  script.on_event("coe-reload-mods", function()
    Log.print("Reloading mods...")
    game.reload_mods()
  end)

  script.on_event("coe-run-function", function(event) ---@diagnostic disable-line: unused-local

  end)
end

if script.active_mods["debugadapter"] then
  script.on_event("coe-trigger-breakpoint", function()
    __DebugAdapter.triggerBreakpoint()
  end)
end

require("commands")
