-- coe_utils
-- utility functions called by other functions

local coeUtils = {}

-- =============================================================================


-- =============================================================================

function coeUtils.CheckIfInArea( position, area )
-- Check if given position is in area bounding box (OARC code)
  if ((position.x >= area.left_top.x) and (position.x < area.right_bottom.x)) then
    if ((position.y >= area.left_top.y) and (position.y < area.right_bottom.y)) then
      return true
    end
  end
  return false
end -- CheckIfInArea

-------------------------------------------------------------------------------

function coeUtils.ClearArea( surface, area )
  -- Clean the destination area so the silo or teleporter (market) can be placed
  for _, entity in pairs( surface.find_entities_filtered({ area = area })) do
    if entity and entity.valid and entity.type ~= "character" then -- Don't destroy players
      entity.destroy()
    end
  end
end -- ClearArea

--------------------------------------------------------------------------------

function coeUtils.GetCityNames( cities )
  local city_names = {}
  for city_name, _ in pairs( cities ) do
    table.insert( city_names, city_name )
  end
  return city_names
end -- GetCityNames

--------------------------------------------------------------------------------

function coeUtils.SkipIntro()
  -- In "sandbox" mode, freeplay is not available
  if remote.interfaces["freeplay"] then
  -- removes crashsite and cutscene start
  remote.call( "freeplay", "set_disable_crashsite", true )
	-- Skips popup message to press tab to start playing
    remote.call( "freeplay", "set_skip_intro", true )
  end
end -- SkipIntrow

-- =============================================================================

return coeUtils
