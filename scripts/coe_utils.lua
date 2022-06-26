---Utility functions called by other functions
---@class coe.Utils
local coeUtils = {}

local floor = math.floor

-- =============================================================================

---Clean the destination area so the silo or teleporter (market) can be placed
function coeUtils.ClearArea(surface, area)
  for _, entity in pairs(surface.find_entities_filtered { area = area, type = "character", invert = true }) do entity.destroy() end
end -- ClearArea

--------------------------------------------------------------------------------

function coeUtils.SkipIntro()
  -- In "sandbox" mode, freeplay is not available
  if remote.interfaces["freeplay"] then
    -- removes crashsite and cutscene start
    remote.call("freeplay", "set_disable_crashsite", true)
    -- Skips popup message to press tab to start playing
    remote.call("freeplay", "set_skip_intro", true)
  end
end -- SkipIntro

-------------------------------------------------------------------------------

---City names have "region, country, city".
---@param city_name string
---@return string
function coeUtils.parseCityName(city_name)
  return city_name:match(".*, .*, (.*)")
end

-------------------------------------------------------------------------------

---@param position MapPosition
---@return ChunkPosition
function coeUtils.mapToChunk(position)
  return {x = floor(position.x / 32), y = floor(position.y / 32)}
end

-------------------------------------------------------------------------------

---@param position ChunkPosition
---@return MapPosition
function coeUtils.chunkToMap(position)
  return {x = position.x * 32, y = position.y * 32}
end

-------------------------------------------------------------------------------

---@param position MapPosition
---@param num double
---@return MapPosition
function coeUtils.positionAdd(position, num)
  return {x = position.x + num, y = position.y + num}
end

-------------------------------------------------------------------------------

---Check if given position is in area bounding box (OARC code)
---@param pos MapPosition
---@param area BoundingBox
---@return boolean
function coeUtils.insideArea(pos, area)
  local lt = area.left_top
  local rb = area.right_bottom
  return pos.x >= lt.x and pos.x < rb.x and pos.y >= lt.y and pos.y < rb.y
end

-- =============================================================================

return coeUtils
