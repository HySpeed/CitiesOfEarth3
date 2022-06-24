--- World Gen code from Factorio world mod oddler_world_gen
---@class coe.WorldGen
local WorldGen = {}

---@class global
---@field map global.map
---@class global.map
---@field max_scale integer
---@field surface LuaSurface
---@field decompressed coe.DecompressedData
---@field width integer
---@field height integer
---@field scale integer
---@field spawn_city coe.City
---@field silo_city coe.City
---@field world_name string
---@field cities coe.Cities

local Config = require( "config" )
local Worlds = require( "data/worlds" )

--- onLoad() Compressed data does not change and does not need to be in global
local Data ---@type string[]
--- onLoad() Upvalue shortcut for global.map values
local Map ---@type global.map

--- Terrain codes must be in sync with the ConvertMap code
--- TODO: add support for cliffs from the images
local terrain_codes = {
  ["_"] = "out-of-map",
  ["o"] = "deepwater", -- ocean
  ["O"] = "deepwater-green",
  ["w"] = "water",
  ["W"] = "water-green",
  ["g"] = "grass-1",
  ["m"] = "grass-3",
  ["G"] = "grass-2",
  ["d"] = "dirt-3",
  ["D"] = "dirt-6",
  ["s"] = "sand-1",
  ["S"] = "sand-3"
}

local sqrt, max, random, floor = math.sqrt, math.max, math.random, math.floor
local sqrt2 = sqrt( 2 )

---Debugger assistance
local debug_ignore = {__debugline = "Decompressed Map Data", __debugchildren = false}

-- =============================================================================

---Scale positions from spawn position
---@param cities coe.Cities
---@param scale uint
---@return coe.Cities
local function initCities(cities, scale)
  local offset_cities = {} ---@type coe.Cities
  scale = scale * Config.DETAIL_LEVEL
  for name, city in pairs(cities) do
    offset_cities[city.name] = {
      fullname = name,
      name = city.name,
      position = {x = city.position.x * scale, y = city.position.y * scale},
      map_grid = city.map_grid
    }
  end
  return offset_cities
end

--------------------------------------------------------------------------------

---Send a startup setting key to retrieve the value
---@param cities coe.Cities
---@param world coe.World
---@param setting_key string
---@return coe.City
local function get_city( cities, world, setting_key)
  local key = settings.startup[setting_key].value--[[@as string]]
  local city = world.cities[key] and cities[world.cities[key].name]
  if not city then
    -- print(key, world.city_names[random( 2, #world.city_names )])
    city = cities[world.cities[world.city_names[random( 2, #world.city_names )]].name]
  end
  return city
end

--------------------------------------------------------------------------------

---Create a surface by cloning the first surfaces settings.
---@param cities coe.Cities
local function create_surface(cities)
  local surface = game.surfaces[1] --- @type LuaSurface
  local map_gen_settings = surface.map_gen_settings
  map_gen_settings.width = Map.width * Map.scale * Config.DETAIL_LEVEL
  map_gen_settings.height = Map.height * Map.scale * Config.DETAIL_LEVEL
  map_gen_settings.starting_points = {}
  for _, city in pairs(cities) do
    table.insert(map_gen_settings.starting_points, city.position)
  end
  map_gen_settings.starting_area = 2
  return game.create_surface( Config.SURFACE_NAME, map_gen_settings)
end

--------------------------------------------------------------------------------

local function get_width()
  local total_count = 0
  local compressed_line = Data[1]
  for _, count in compressed_line:gmatch( "(%a+)(%d+)" ) do
    total_count = total_count + count
  end
  return total_count
end

---@param y integer
---@return string[]
---@return integer
local function decompressLine( y )
  -- Decompress map data
  local decompressed_line = Map.decompressed[y] or {}
  if #decompressed_line ~= 0 then return decompressed_line end

  local total_count = 0
  local compressed_line = Data[y + 1]
  for letter, count in compressed_line:gmatch( "(%a+)(%d+)" ) do
    for x = total_count, total_count + count do
      decompressed_line[x] = letter
    end
    total_count = total_count + count
  end
  -- assert(global.map.width == total_count, "Mismatching width: " .. global.map.width .. " vs " .. total_count)
  Map.decompressed[y] = decompressed_line
  return decompressed_line, total_count
end -- decrompressLine

--------------------------------------------------------------------------------

---@param x double
---@param y double
---@return string
local function getWorldTileCodeRaw( x, y )
  local y_wrap = y % Map.height
  local x_wrap = x % Map.width
  local repeat_map = false -- carry over from factorio_world that allows tiling map

  if not repeat_map and (x ~= x_wrap or y ~= y_wrap) then
    return "o" -- The terrain to use for everything outside the map
  end
  return decompressLine( y_wrap )[x_wrap]
end -- getWorldTileCodeRaw

--------------------------------------------------------------------------------

local function addToTotal( totals, weight, code )
  if totals[code] == nil then
    totals[code] = { code = code, weight = weight }
  else
    totals[code].weight = totals[code].weight + weight
  end
end -- addToTotal

--------------------------------------------------------------------------------

---@param x double
---@param y double
---@return string
local function getWorldTileName( x, y )

  local scale = Map.scale
  local max_scale = Map.max_scale

  x = x / scale
  y = y / scale

  -- get cells this data point is between
  local top = floor( y )
  local bottom = (top + 1)
  local left = floor( x )
  local right = (left + 1)

  -- Calculate weights
  -- 1 - sqrt( (top - y) * (top - y) + (left - x) * (left - x) ) / sqrt(2)
  local ty, by = top - y, bottom - y -- subtract
  ty, by = ty * ty, by * by -- square

  local lx, rx = left - x, right - x
  lx, rx = lx * lx, rx * rx

  local w_top_left = 1 - sqrt( ty + lx) / sqrt2
  w_top_left = w_top_left * w_top_left + random() / max_scale

  local w_top_right = 1 - sqrt( ty + rx ) / sqrt2
  w_top_right = w_top_right * w_top_right + random() / max_scale

  local w_bottom_left = 1 - sqrt( by + lx ) / sqrt2
  w_bottom_left = w_bottom_left * w_bottom_left + random() / max_scale

  local w_bottom_right = 1 - sqrt( by + rx ) / sqrt2
  w_bottom_right = w_bottom_right * w_bottom_right + random() / max_scale

  -- get codes
  local c_top_left = getWorldTileCodeRaw( left, top )
  local c_top_right = getWorldTileCodeRaw( right, top )
  local c_bottom_left = getWorldTileCodeRaw( left, bottom )
  local c_bottom_right = getWorldTileCodeRaw( right, bottom )

  -- calculate total weights for codes
  local totals = {}
  addToTotal( totals, w_top_left, c_top_left )
  addToTotal( totals, w_top_right, c_top_right )
  addToTotal( totals, w_bottom_left, c_bottom_left )
  addToTotal( totals, w_bottom_right, c_bottom_right )

  -- choose final code
  local code
  local weight = 0
  for _, total in pairs( totals ) do
    if total.weight > weight then
      code = total.code
      weight = total.weight
    end
  end
  return terrain_codes[code]
end -- getWorldTileName

-- =============================================================================

---@param event on_chunk_generated
function WorldGen.onChunkGenerated( event )
  local surface = event.surface
  if (surface ~= Map.surface) then return end

  local lt = event.area.left_top
  local rb = event.area.right_bottom
  local tiles = {}

  for y = lt.y - 1, rb.y do
    for x = lt.x - 1, rb.x do
      table.insert( tiles,
        {
          name = getWorldTileName( x, y ), position = { x, y } } )
    end
  end

  surface.set_tiles( tiles )
  local positions = { event.position }
  -- surface.destroy_decoratives( { area = event.area } )
  -- surface.regenerate_decorative( nil, positions )
  -- surface.regenerate_entity( nil, positions )
end -- GenerateChunk_World

--------------------------------------------------------------------------------

---Initialize World data
---This only needs to happen when a new map is created
function WorldGen.onInit()
  global.map = {}
  Map = global.map
  local world_name = settings.startup.coe_world_map.value--[[@as string]]
  Map.world_name = world_name
  local World = Worlds[world_name]
  Data = World.data
  Map.height = #Data
  Map.decompressed = setmetatable( {}, debug_ignore)
  local _, width = decompressLine(0)
  Map.width = width

  Map.scale = settings.startup.coe_map_scale.value --A value of .5 with give you a 1 to 1 map
  Map.max_scale = max( Map.scale / Config.DETAIL_LEVEL, 10 )
  Map.cities = initCities(World.cities, Map.scale)
  Map.surface = create_surface(Map.cities)
  Map.spawn_city = assert( get_city( Map.cities, World, World.settings.spawn ) )
  Map.silo_city = assert( get_city( Map.cities, World, World.settings.silo) )

  --- TODO set in Forces
  game.forces['player'].set_spawn_position(Map.spawn_city.position, Map.surface)
end -- InitWorld

function WorldGen.onLoad()
  -- load the data externally
  setmetatable(global.map.decompressed, debug_ignore)
  Map = global.map
  Data = Worlds[global.map.world_name].data
end

-- =============================================================================

return WorldGen
