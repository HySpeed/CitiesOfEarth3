
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
-- if script.active_mods["gvv"] then require("__gvv__.gvv")() end
-- TODO: in local.cfg, split 'text_' to a section, like ptpt
-- TODO: add "discharge equipment"

local Utils = require("scripts/coe_utils")
local Player = require("scripts/coe_player")
local Surface = require("scripts/coe_surface")
local WorldGen = require("scripts/coe_worldgen")
local Silo = require("scripts/coe_silo")
local Teleporter = require("scripts/coe_teleporter")
-- local Gui        = require( "scripts/coe_gui" )

-- =============================================================================

script.on_init(function()
  ---@class global
  global = {}
  Utils.skipIntro()
  WorldGen.onInit()
  Player.onInit()
  Silo.onInit()
  Teleporter.onInit()
end)

script.on_load(function()
  WorldGen.onLoad()
  Silo.onLoad()
end)

script.on_event(defines.events.on_player_created, Player.onPlayerCreated)

script.on_event(defines.events.on_player_died, Silo.onPlayerDied)

---Setup terrain according to Earth map
script.on_event(defines.events.on_chunk_generated, WorldGen.onChunkGenerated)

---@param event EventData.on_chunk_charted
script.on_event(defines.events.on_chunk_charted, function(event)
  Silo.onChunkCharted(event) -- add concrete and map tag
end)

---@param event EventData.on_city_generated
script.on_event(Surface.on_city_generated, function(event)
  Surface.onCityGenerated(event)
  Player.onCityGenerated(event)
  Silo.onCityGenerated(event)
  Teleporter.onCityGenerated(event)
end)

script.on_event(defines.events.on_research_finished, Silo.onResearchFinished)

script.on_event(defines.events.on_rocket_launched, Silo.onRocketLaunched )

-- script.on_event( defines.events.on_gui_opened,         Gui.BuildTeleporterUI )

-- script.on_event( defines.events.on_gui_click,          Gui.ProcessGuiEvent )
