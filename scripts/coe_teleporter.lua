-- coe_teleporter
-- Functions relating to creating and using the Teleporter

local coeTeleporter = {}
local coeConfig  = require( "config" )
local coeUtils   = require( "scripts/coe_utils" )
local coeActions = require( "scripts/coe_actions" )
local util = require( "util" )

-- =============================================================================

local function fillAreaForTeleporter( surface, position )
  local fill = {}
  for x = position.x-2, position.x+2 do
    for y = position.y-2, position.y+4 do
      table.insert( fill, {name = "landfill", position = {x,y}} )
    end
  end
  surface.set_tiles(fill)
end -- fillAreaForTeleporter

--------------------------------------------------------------------------------

local function createTeleporter( surface, position, city_name )
  position.y = position.y - coeConfig.SHIFT

  local area = {{position.x - 4, position.y - 2}, {position.x + 4, position.y + 8}}
  coeUtils.ClearArea( surface, area )
  fillAreaForTeleporter( surface, position )

  local teleporter = surface.create_entity( {name = "coe_teleporter", position = position,
                                             force = "neutral", move_stuck_players = true} )
  teleporter.destructible = false
  teleporter.minable = false
  teleporter.backer_name = "- " .. city_name

  game.print( {"",  {"coe.text_teleporter_created"}, city_name} )
end -- createTeleporter

--------------------------------------------------------------------------------

local function decorateTeleporter( surface, position, city_name )
  coeActions.CheckAndCreateChunk( surface, position )

    -- put tiles at target
    local tiles = {}
    local i = 1
    for dx = -2, 2 do
      for dy = -2, 4 do
        tiles[i] = {
          name = "hazard-concrete-right",
          position = {position.x + dx, position.y + dy - coeConfig.SHIFT}}
        i = i + 1
      end
    end
    surface.set_tiles( tiles, true )

  -- tag / label for map view
  game.forces[coeConfig.PLAYER_FORCE].add_chart_tag( surface, {
    icon = {type = 'virtual', name = "signal-info"},
    position = position,
    text = "     " .. city_name
  })

end -- decorateTeleporter

--------------------------------------------------------------------------------

local function updateDestinationTable( city_name )
-- called whenever a desitation is charted, to enable the city button on the UI
  for index = 1, #global.coe.dest_grid do
    local grid_data = global.coe.dest_grid[index]
    if city_name == grid_data.city_name then
      grid_data.create = true
    end
  end
end -- updateDestinationTable

-- =============================================================================

function coeTeleporter.CheckAndPlaceTeleporter( event )
  for city_name, _ in pairs( global.coe.cities ) do
    local city = global.coe.cities[city_name]
    if not city.teleporter.created then
      local offsets = util.table.deepcopy( city.offsets )
      if coeUtils.CheckIfInArea( offsets, event.area ) then
        createTeleporter( global.coe.surface, offsets, city_name )
        city.teleporter.created = true
      end
    end
  end
end -- CheckAndPlaceTeleporter

-------------------------------------------------------------------------------

function coeTeleporter.CheckAndDecorateTeleporter( event )
-- Always decorate to mark the city, even without the teleporter
  for city_name, _ in pairs( global.coe.cities ) do
    local city = global.coe.cities[city_name]
    if not city.teleporter.charted then
      local offsets = util.table.deepcopy( city.offsets )
      if coeUtils.CheckIfInArea( offsets, event.area ) then
        decorateTeleporter( global.coe.surface, offsets, city_name )
        updateDestinationTable( city_name )
        city.teleporter.charted = true
      end
    end
  end
end -- CheckAndDecorateTeleporter

-- =============================================================================

return coeTeleporter
