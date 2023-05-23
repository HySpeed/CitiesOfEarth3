---Utility functions called by other functions
local Config = require( "config" )

---@class coe.Utils
local Utils = {}
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

---Get the city of this rocket_silo object using the given entity.unit_number
---@param unit_number
---@return city
function Utils.findSiloByUnitNumber(unit_number)
  local city = {}
  for index = 1,  #global.world.city_names do
    local check_city = global.world.cities[global.world.city_names[index]]
    if unit_number == check_city.rocket_silo.entity.unit_number then
      city = check_city
      break
    end
  end
    return city
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
function Utils.positionAdd( pos, vec )
  return { x = (pos.x or pos[1]) + (vec.x or vec[1]), y = (pos.y or pos[2]) + (vec.y or vec[2]) }
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

-- given a position and a negative offset, return an area object with offset position first
function Utils.defineInverseArea( a, b )
  return {
    left_top = {
      x = (b.x or b[1]),
      y = (b.y or b[2])
    },
    right_bottom = {
      x = (a.x or a[1]),
      y = (a.y or a[2])
    }
  }
end

-------------------------------------------------------------------------------

---@param pos MapPosition
---@return BoundingBox
function Utils.positionToChunkArea( pos )
  local x, y = (pos.x or pos[1]), (pos.y or pos[2])
  local left_top = { x = floor(x), y = floor(y) }
  local right_bottom = { x = left_top.x + 32, y = left_top.y + 32 }
  return { left_top = left_top, right_bottom = right_bottom }
end

-------------------------------------------------------------------------------

---@param pos MapPosition
---@return BoundingBox
function Utils.positionToChunkTileArea(pos)
  local x, y = (pos.x or pos[1]), (pos.y or pos[2])
  local left_top = { x = floor(x), y = floor(y) }
  local right_bottom = { x = left_top.x + 31, y = left_top.y + 31 }
  return { left_top = left_top, right_bottom = right_bottom }
end

-------------------------------------------------------------------------------

---@param pos ChunkPosition
---@return BoundingBox
function Utils.chunkPositionToArea(pos)
  local left_top = { x = pos.x * 32, y = pos.y * 32 }
  local right_bottom = { x = left_top.x + 32, y = left_top.y + 32}
  return { left_top = left_top, right_bottom = right_bottom }
end

-------------------------------------------------------------------------------

---@param pos ChunkPosition
---@return BoundingBox
function Utils.chunkPositionToTileArea(pos)
  local left_top = { x = pos.x * 32, y = pos.y * 32 }
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
---@param vectorBox BoundingBox.1
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
  return "{" .. Utils.positionToStr(area.left_top) .. "} - {" .. Utils.positionToStr(area.right_bottom) .. "}"
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

-- loop through the city silos, count the number of 'launches_this_silo' > 0
-- this is the maximum - the number of silos that have been launched from
---@return integer
function Utils.calculateMaxLaunches()
  local max_launches = 0
  for index = 1,  #global.world.city_names do
    local city = global.world.cities[global.world.city_names[index]]
    if city.rocket_silo and city.rocket_silo.launches_this_silo and city.rocket_silo.launches_this_silo > 0 then
      max_launches = max_launches + 1
    end
  end
  return max_launches
end

-------------------------------------------------------------------------------

-- For ALL, loop throught the cities / silos.  Return a count of how many have non-zero launched rockets.
---@return integer
function Utils.calculateTotalLaunches()
  local total_launches = 0
  local pre_place_silo = global.settings.startup.coe_pre_place_silo.value

  if pre_place_silo == Config.ALL then
    local completed_launches_count = 0
    for index = 1,  #global.world.city_names do
      local city = global.world.cities[global.world.city_names[index]]
      if city.rocket_silo and city.rocket_silo.launches_this_silo
        and city.rocket_silo.launches_this_silo > 0 then
          total_launches = total_launches + city.rocket_silo.launches_this_silo
      end
    end
  elseif pre_place_silo == Config.NONE or pre_place_silo == Config.SINGLE then
    total_launches = global.world.rocket_silo.launches_this_silo
  end
  return total_launches
end


-------------------------------------------------------------------------------

-- For ALL, loop throught the cities / silos.  Count of how many have non-zero launched rockets.
---@return integer
function Utils.calculateRemainingLaunches()
  local remaining_launches = 0
  local pre_place_silo = global.settings.startup.coe_pre_place_silo.value

  if pre_place_silo == Config.ALL then
    local completed_launches_count = 0
    for index = 1,  #global.world.city_names do
      local city = global.world.cities[global.world.city_names[index]]
      if city.rocket_silo and city.rocket_silo.launches_this_silo
        and city.rocket_silo.launches_this_silo > 0 then
          completed_launches_count = completed_launches_count + 1
      end
    end
    remaining_launches =  global.world.rocket_silo.required_launches - completed_launches_count
  elseif pre_place_silo == Config.SINGLE then
    remaining_launches = global.world.rocket_silo.required_launches - global.world.rocket_silo.launches_this_silo
  end

  if remaining_launches < 0 then remaining_launches = 0 end
  return remaining_launches
end

-------------------------------------------------------------------------------

function Utils.createAndFillChest( surface, position, chest_name, contents, quantity )
  local chest_entity = {
    name = chest_name,
    position = position,
    force = Config.PLAYER_FORCE,
    create_build_effect_smoke = false
  }
  local chest = surface.create_entity( chest_entity )
  chest.insert({
    name = contents,
    count = quantity
  })

  -- put contents in chest
end

-------------------------------------------------------------------------------

function Utils.fillChest( )
end

-------------------------------------------------------------------------------

-- For ver 1.6.0, silo data is moved from global to 'silo_city'.
function Utils.moveSiloData()
  if global.world.rocket_silo == nil then
    global.world.rocket_silo = {
      required_launches = 1,
      total_launches = 0,
      launches_this_silo = 0
    }
  end

  if global.world.silo_city.rocket_silo == nil then
    global.world.silo_city.rocket_silo = global.rocket_silo
  end
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

-------------------------------------------------------------------------------

-- Gets all startup settings and preserves them in a local table so they are not read dynamically after init.
function Utils.saveStartupSettings()
  global.settings = { startup = {} }
  global.settings.startup.coe_pre_place_silo = settings.startup.coe_pre_place_silo
  if settings.startup["coe_team_coop"].value == true then
    global.settings.startup.coe_pre_place_silo.value = Config.ALL
  end
end

-------------------------------------------------------------------------------

---@param name string The startup setting to get.
function Utils.getStartupSetting(name)
  local setting = settings.startup[name]
  return setting and setting.value
end

-------------------------------------------------------------------------------

---@param msg LocalisedString
---@param skip_game_print? boolean
function Utils.print(msg, skip_game_print)
  if settings.startup.coe_dev_mode and settings.startup.coe_dev_mode.value then
    if not skip_game_print and game then game.print(msg) end
    log(msg)
  end
end

-------------------------------------------------------------------------------

function Utils.reload_mods()
  Utils.print("Reloading mods...")
  game.reload_mods()
end

-- =============================================================================

return Utils
