---Utility functions called by other functions
---@class coe.Utils
local Utils = {}

-- local Config = require("config")
local floor, ceil = math.floor, math.ceil

--- Load factorio util but undo all the global clobbering it does.
local _old_util = util
local _orig_deepcopy = table.deepcopy
local _orig_compare = table.compare
Utils.factorio = require("util")
table.deepcopy = _orig_deepcopy
table.compare = _orig_compare
util = _old_util

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
  local str = city_name:match(".*, .*, (.*)")
  return str
end

-------------------------------------------------------------------------------

---@param position MapPosition
---@return ChunkPosition
function Utils.mapToChunk(position)
  return { x = floor(position.x / 32), y = floor(position.y / 32) }
end

-------------------------------------------------------------------------------

---@param position ChunkPosition
---@return MapPosition
function Utils.chunkToMap(position)
  return { x = position.x * 32, y = position.y * 32 }
end

-------------------------------------------------------------------------------

---@param pos MapPosition
---@param vec MapPosition
---@return MapPosition
function Utils.positionAdd(pos, vec)
  return { x = pos.x + (vec.x or vec[1]), y = pos.y + (vec.x or vec[2]) }
end

-------------------------------------------------------------------------------

---@param pos MapPosition
---@return MapPosition
function Utils.positionCenter(pos)
  return { x = floor(pos.x) + 0.5, y = floor(pos.x) + 0.5 }
end

-------------------------------------------------------------------------------

---@param self MapPosition
---@param other MapPosition
---@return double
function Utils.positionDistance(self, other)
    local ax_bx = self.x - other.x
    local ay_by = self.y - other.y
    return (ax_bx * ax_bx + ay_by * ay_by) ^ 0.5
end

-------------------------------------------------------------------------------

---@param pos MapPosition
---@return BoundingBox
function Utils.positionToChunkArea(pos)
  local x, y = (pos.x or pos[1]), (pos.y or pos[2])
  local left_top = { x = floor(x), y = floor(y) }
  local right_bottom = { x = left_top.x + 31, y = left_top.y + 31 }
  return { left_top = left_top, right_bottom = right_bottom }
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
---@return BoundingBox# Mutated
function Utils.offsetArea(area, vector)
  local lt, rb = area.left_top, area.right_bottom
  local x, y = (vector.x or vector[1]), (vector.y or vector[2])
  lt.x, lt.y = lt.x + x, lt.y + y
  rb.x, rb.y = rb.x + x, rb.y + y
  return area
end

-------------------------------------------------------------------------------

---@param area BoundingBox
function Utils.areaToTileArea(area)
  local lt, rb = area.left_top, area.right_bottom
  lt.x = floor(lt.x)
  lt.y = floor(lt.y)
  rb.x = ceil(rb.x) - 1
  rb.y = ceil(rb.y) - 1
  return area
end

-------------------------------------------------------------------------------

---@param area BoundingBox
---@param vectorBox VectorBox
---@return BoundingBox
function Utils.areaAdjust(area, vectorBox)
  local lt, rb = area.left_top, area.right_bottom
  lt.x = lt.x + vectorBox[1][1]
  lt.y = lt.y + vectorBox[1][2]

  rb.x = rb.x + vectorBox[2][1]
  rb.y = rb.y + vectorBox[2][2]
  return area
end

-------------------------------------------------------------------------------

---@param area BoundingBox
function Utils.areaToStr(area)
  return "{" .. Utils.positionToStr(area.left_top) .. "} - {" .. Utils.positionToStr(area.right_bottom) .."}"
end

-------------------------------------------------------------------------------

---Return a random non-zero value from negative to positive
---@param limit integer
---@return integer
function Utils.getRandomNonZeroSwing(limit)
  if limit == 0 then return 0 end
  local result = 0
  repeat
    result = math.random(-limit, limit)
  until result ~= 0
  return result
end

-------------------------------------------------------------------------------

function Utils.titleCase(str)
  return str:gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param position MapPosition
---@param radius? uint
function Utils.checkAndGenerateChunk(surface, position, radius)
  if surface.is_chunk_generated({ position.x / 32, position.y / 32 }) then return end
  radius = radius or 0
  surface.request_to_generate_chunks(position, radius)
  surface.force_generate_chunk_requests()
end

-------------------------------------------------------------------------------

---@param tab? string|string[]
---@return {[string]: boolean}
function Utils.makeDictionary(tab)
  if not tab then return {} end
  if type(tab) == "string" then return { [tab] = true } end

  local dict = {}
  for _, v in ipairs(tab) do
    dict[v] = true
  end
  return dict
end

---@param name string The startup setting to get.
function Utils.getStartupSetting(name)
  local setting = settings.startup[name]
  return setting and setting.value
end

-- =============================================================================

return Utils
