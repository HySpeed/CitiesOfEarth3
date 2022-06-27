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
