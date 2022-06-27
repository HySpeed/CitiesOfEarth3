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
