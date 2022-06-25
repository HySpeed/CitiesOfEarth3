-- coe_utils
-- utility functions called by other functions

local coeUtils = {}

-- =============================================================================

-- Check if given position is in area bounding box (OARC code)
function coeUtils.CheckIfInArea( position, area )
  if ((position.x >= area.left_top.x) and (position.x < area.right_bottom.x)) then
    if ((position.y >= area.left_top.y) and (position.y < area.right_bottom.y)) then
      return true
    end
  end
  return false
end -- CheckIfInArea

-------------------------------------------------------------------------------

-- Clean the destination area so the silo or teleporter (market) can be placed
function coeUtils.ClearArea( surface, area )
  for _, entity in pairs( surface.find_entities_filtered{ area = area, type = "character", invert = true }) do
    entity.destroy()
  end
end -- ClearArea

--------------------------------------------------------------------------------

function coeUtils.SkipIntro()
  -- In "sandbox" mode, freeplay is not available
  if remote.interfaces["freeplay"] then
    -- removes crashsite and cutscene start
    remote.call( "freeplay", "set_disable_crashsite", true )
    -- Skips popup message to press tab to start playing
    remote.call( "freeplay", "set_skip_intro", true )
  end
end -- SkipIntro

-------------------------------------------------------------------------------

--- City names have "region, country, city".
---@param city_name string
---@return string
function coeUtils.parseCityName( city_name )
  return city_name:match(".*, .*, (.*)")
end

-- =============================================================================

  local function __genOrderedIndex( t )
      local orderedIndex = {}
      for key in pairs(t) do
          table.insert( orderedIndex, key )
      end
      table.sort( orderedIndex )
      return orderedIndex
  end

  --- Equivalent of the next function, but returns the keys in the alphabetic
  --- order. We use a temporary ordered key table that is stored in the
  --- table being iterated.
  function coeUtils.orderedNext(t, state)
      local key = nil
      if state == nil then
          -- the first time, generate the index
          t.__orderedIndex = __genOrderedIndex( t )
          key = t.__orderedIndex[1]
      else
          -- fetch the next value
          for i = 1,#t.__orderedIndex do
              if t.__orderedIndex[i] == state then key = t.__orderedIndex[i+1] end
          end
      end
      if key then return key, t[key] end
      -- no more value to return, cleanup
      t.__orderedIndex = nil
  end

  -- Ordered table iterator, allow to iterate on the natural order of the keys of a table.
  function coeUtils.orderedPairs(t)
      return coeUtils.orderedNext, t, nil
  end

return coeUtils
