-- control.lua
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

local coeUtils = require("scripts/coe_utils")
local Player = require("scripts/coe_player")
local WorldGen = require("scripts/coe_worldgen")
local Silo = require("scripts/coe_silo")
-- local Gui        = require( "scripts/coe_gui" )
-- local Teleporter = require( "scripts/coe_teleporter" )

-- =============================================================================

---@diagnostic disable DIAG_PARAM_TYPE_MISMATCH
script.on_init(function()
  --- @class global
  global = {}
  coeUtils.SkipIntro()
  WorldGen.onInit()
  Player.onInit()
  Silo.onInit()
end)

script.on_load(WorldGen.onLoad)

script.on_event(defines.events.on_player_created, Player.onPlayerCreated)

script.on_event(defines.events.on_player_died, Silo.onPlayerDied)

script.on_event(defines.events.on_chunk_generated, function(event)
  WorldGen.onChunkGenerated(event) -- Setup terrain according to Earth map
  -- Teleporter.CheckAndPlaceTeleporter( event ) -- Check and place Teleporter
  Silo.onChunkGenerated(event)
end)

script.on_event(defines.events.on_chunk_charted, function(event)
  -- Teleporter.CheckAndDecorateTeleporter( event ) -- add concrete and map tag
  Silo.onChunkCharted(event) -- add concrete and map tag
end)

-- script.on_event( defines.events.on_research_finished,  Gui.RemoveSiloCrafting )

-- script.on_event( defines.events.on_rocket_launched,    Gui.RecordRocketLaunch )

-- script.on_event( defines.events.on_gui_opened,         Gui.BuildTeleporterUI )

-- script.on_event( defines.events.on_gui_click,          Gui.ProcessGuiEvent )
