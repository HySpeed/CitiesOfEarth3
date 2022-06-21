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

local coeUtils      = require( "scripts/coe_utils" )
local coeInit       = require( "scripts/coe_init" )
local coeActions    = require( "scripts/coe_actions" )
local coeGui        = require( "scripts/coe_gui" )
local coeSilo       = require( "scripts/coe_silo" )
local coeTeleporter = require( "scripts/coe_teleporter" )
local coeWorldGen   = require( "scripts/oddler_world_gen" )

-- =============================================================================

local function onInit()
  coeUtils.SkipIntro()
  coeWorldGen.InitWorld( coeInit.InitSettings() )
  for _, player in pairs( game.players ) do
    coeInit.SetupPlayer( player.index )
  end
end -- onInit

--------------------------------------------------------------------------------

local function configurationChanged( event )
  -- version migrations
    for _, player in pairs( game.players ) do
      coeInit.SetupPlayer( player.index )
    end
  end -- configurationChanged

--------------------------------------------------------------------------------

local function onPlayerCreated( event )
  local player = coeInit.SetupPlayer( event.player_index )
  coeActions.PerformTeleport( player, global.coe.spawn_city )
end -- onPlayerCreated

--------------------------------------------------------------------------------

local function onPlayerJoined (event )
  coeInit.SetupPlayer( event.player_index )
end -- onPlayerJoined

--------------------------------------------------------------------------------

local function onChunkGenerated( event )
  coeWorldGen.GenerateChunk_World( event ) -- Setup terrain according to Earth map
  if global.coe.create_teleporters then
    coeTeleporter.CheckAndPlaceTeleporter( event ) -- Check and place Teleporter
  end
  coeSilo.CheckAndPlaceSilo( event ) -- Check and place Silo
end -- onChunkGenerated

--------------------------------------------------------------------------------

local function onChunkCharted( event )
  coeTeleporter.CheckAndDecorateTeleporter( event ) -- add concrete and map tag
  coeSilo.CheckAndDecorateSilo( event ) -- add concrete and map tag
end -- onChunkCharted

--------------------------------------------------------------------------------

local function onGuiOpened( event )
  if defines.gui_type.entity == event.gui_type and event.entity.name == "coe_teleporter" then
    coeGui.BuildTeleporterUI( event )
  end
end -- onGuiOpened

--------------------------------------------------------------------------------

local function recordPlayerDeath( event )
  -- only record a death if the setting is enabled and success hasn't completed
  if global.coe.launches_per_death <= 0 or global.coe.launch_success then return end

  global.coe.launches_to_win = global.coe.launches_to_win + global.coe.launches_per_death
  game.print( {"",  {"coe.text_mod_name"}, {"coe.text_death_of"},
              game.players[event.player_index].name, {"coe.text_increased_launches"},
              tostring(global.coe.launches_per_death)} )
  game.print( {"",  {"coe.text_mod_name"}, tostring(global.coe.launches_to_win -
              global.coe.rockets_launched), {"coe.text_more_rockets"}} )
end -- recordPlayerDeath

--------------------------------------------------------------------------------

local function runtimeSettingChanged( event )
  for _, player in pairs( game.players ) do
    coeInit.SetupPlayer( player.index )
  end
end -- runtimeSettingChanged

-- =============================================================================

script.on_init( onInit )

script.on_configuration_changed( configurationChanged )
script.on_event( defines.events.on_runtime_mod_setting_changed, runtimeSettingChanged )
script.on_event( defines.events.on_player_created,     onPlayerCreated )
script.on_event( defines.events.on_player_joined_game, onPlayerJoined  )

script.on_event( defines.events.on_chunk_generated,    onChunkGenerated )
script.on_event( defines.events.on_chunk_charted,      onChunkCharted   )

script.on_event( defines.events.on_research_finished,  coeGui.RemoveSiloCrafting )
script.on_event( defines.events.on_player_died,        recordPlayerDeath  )
script.on_event( defines.events.on_rocket_launched,    coeGui.RecordRocketLaunch )

script.on_event( defines.events.on_gui_opened,         onGuiOpened     )
script.on_event( defines.events.on_gui_click,          coeGui.ProcessGuiEvent )
--global.coe.teleporters_require_power