-- coe_silo.lua
-- Functions relating to creating and using the Rocket Silo

local coeSilo = {}
local coeConfig  = require( "config" )
local coeUtils   = require( "scripts/coe_utils" )
local coeActions = require( "scripts/coe_actions" )
local util = require( "util" )

-- =============================================================================

local function placeSilo( surface, position )
  local area = {
    {position.x + coeConfig.SHIFT - 10, position.y + coeConfig.SHIFT- 10},
    {position.x + coeConfig.SHIFT + 10, position.y + coeConfig.SHIFT + 18}
  }
  coeUtils.ClearArea( surface, area )
  local silo = surface.create_entity({
    name = "rocket-silo",
    position = {position.x + coeConfig.SHIFT, position.y + coeConfig.SHIFT},
    force = "player",
    move_stuck_players = true
  })
  silo.destructible = false
  silo.minable = false
end -- placeSilo

--------------------------------------------------------------------------------

local function decorateSilo( surface, position )
  position.x = position.x + coeConfig.SHIFT
  position.y = position.y + coeConfig.SHIFT
  coeActions.CheckAndCreateChunk( surface, position )

  -- put tiles at target
  local tiles = {}
  local i = 1

  for dx = -6, 6 do
    for dy = -6, 6 do
      tiles[i] = {name = "concrete", position = {position.x + dx, position.y+ dy}}
      i = i + 1
    end
  end

  for df = -6, 6 do
    tiles[i]   = {name = "hazard-concrete-left", position = {position.x + df, position.y -  7}}
    tiles[i+1] = {name = "hazard-concrete-left", position = {position.x + df, position.y +  7}}
    tiles[i+2] = {name = "hazard-concrete-left", position = {position.x -  7, position.y + df}}
    tiles[i+3] = {name = "hazard-concrete-left", position = {position.x +  7, position.y + df}}
    i = i + 4
  end
  surface.set_tiles( tiles, true )

  -- tag / label for map view
  game.forces[coeConfig.PLAYER_FORCE].add_chart_tag( surface, {
    icon = {
      type = 'virtual', 
      name = "signal-info"
    }, 
    position = position, 
    text = "   Rocket Silo"
  })
end -- decorateSilo

-- =============================================================================

function coeSilo.CheckAndPlaceSilo( event )
  if global.coe.pre_place_silo and not global.coe.silo_created then
    local position = util.table.deepcopy( global.coe.silo_city.position )
    if coeUtils.CheckIfInArea( position, event.area ) then
      placeSilo( global.coe.surface, position )
      global.coe.silo_created = true;
      if global.coe.dev_mode then
        game.print( {"",  {"coe.text_silo_placed"}, global.coe.silo_city.name} )
      end
    end
  end
end -- CheckAndPlaceSilo

--------------------------------------------------------------------------------

function coeSilo.CheckAndDecorateSilo( event )
  if global.coe.pre_place_silo and not global.coe.silo_decorated then
    local position = global.coe.silo_city.position
    if coeUtils.CheckIfInArea( position, event.area ) then
        decorateSilo( global.coe.surface, position )
      global.coe.silo_decorated = true
    end
  end
end -- CheckAndDecorateSilo

-- =============================================================================

return coeSilo
