---Utility functions called by other functions
---@class coe.Utils
local Utils = {}

local Config = require("config")
local floor = math.floor

-- =============================================================================

function Utils.skipIntro()
  -- In "sandbox" mode, freeplay is not available
  if remote.interfaces["freeplay"] then
    -- removes crashsite and cutscene start
    remote.call("freeplay", "set_disable_crashsite", true)
    -- Skips popup message to press tab to start playing
    remote.call("freeplay", "set_skip_intro", true)
  end
end -- skipIntro

-------------------------------------------------------------------------------

---City names have "region, country, city".
---@param city_name string
---@return string
function Utils.parseCityName(city_name)
  return city_name:match(".*, .*, (.*)")
end

-------------------------------------------------------------------------------

---@param position MapPosition
---@return ChunkPosition
function Utils.mapToChunk(position)
  return {x = floor(position.x / 32), y = floor(position.y / 32)}
end

-------------------------------------------------------------------------------

---@param position ChunkPosition
---@return MapPosition
function Utils.chunkToMap(position)
  return {x = position.x * 32, y = position.y * 32}
end

-------------------------------------------------------------------------------

---@param pos MapPosition
---@param vec MapPosition
---@return MapPosition
function Utils.positionAdd(pos, vec)
  return {x = pos.x + (vec.x or vec[1]), y = pos.y + (vec.x or vec[2])}
end

-------------------------------------------------------------------------------

---@param pos MapPosition
---@return BoundingBox
function Utils.positionToChunkArea(pos)
  local x, y = (pos.x or pos[1]), (pos.y or pos[2])
  local left_top = {x = floor(x), y = floor(y)}
  local right_bottom = {x = left_top.x + 31, y = left_top.y + 31}
  return {left_top = left_top, right_bottom = right_bottom}
end

-------------------------------------------------------------------------------

---@param position MapPosition
---@return string
function Utils.positionToStr(position)
return position and (position.x .. ", " .. position.y) or ""
end

-------------------------------------------------------------------------------

---Check if given position is in area bounding box (OARC code)
---@param pos MapPosition
---@param area BoundingBox
---@return boolean
function Utils.insideArea(pos, area)
  local lt = area.left_top
  local rb = area.right_bottom
  return pos.x >= lt.x and pos.x < rb.x and pos.y >= lt.y and pos.y < rb.y
end

-------------------------------------------------------------------------------

---@param area BoundingBox
---@param vector MapPosition
---@return BoundingBox
function Utils.offsetArea(area, vector)
local ltx, lty = area.left_top.x, area.left_top.y
local rbx, rby = area.left_top.x, area.left_top.y
local x, y = (vector.x or vector[1]), (vector.y or vector[2])
return {left_top = {x = ltx + x, y = lty + y}, right_bottom = {x = rbx + x, y = rby + y}}
end

-------------------------------------------------------------------------------

---@param msg LocalisedString
function Utils.devPrint(msg)
  if Config.DEV_MODE then
    game.print(msg)
    log(msg)
  end
end

-------------------------------------------------------------------------------

---Return a random non-zero value from negative to positive
---@param limit integer
---@return integer
function Utils.getRandomNonZeroSwing(limit)
  if limit == 0 then return 0 end
  local result = 0
  repeat
    result = math.random( -limit, limit )
  until result ~= 0
  return result
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param position MapPosition
---@param radius? uint
function Utils.checkAndGenerateChunk( surface, position, radius)
  if surface.is_chunk_generated( {position.x / 32, position.y / 32}) then return end
  radius = radius or 0
  surface.request_to_generate_chunks( position, radius )
  surface.force_generate_chunk_requests()
end

-- =============================================================================

return Utils
