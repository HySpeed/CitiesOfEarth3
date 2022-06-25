--- World Gen code from Factorio world mod oddler_world_gen
---@class coe.WorldGen
local WorldGen = {}

---@class global
---@field map global.map
---@class global.map
---@field surface LuaSurface The Earth surface.
---@field decompressed coe.DecompressedData
---@field scale double
---@field detailed_scale double The scale * detail level of the compressed data
---@field max_scale double
---@field sqrt_detail double
---@field decompressed_height uint
---@field decompressed_height_radius uint
---@field height_radius uint Half the width of the map.
---@field height uint The height of the map.
---@field decompressed_width uint
---@field decompressed_width_radius uint
---@field width uint The width of the map.
---@field width_radius uint Half the height of the map.
---@field world_name string The current world
---@field cities coe.Cities
---@field spawn_city coe.City
---@field silo_city coe.City

local Config = require("config")
local Worlds = require("data/worlds")

--- onLoad() Compressed data does not change and does not need to be in global
local Data ---@type string[]
--- onLoad() Upvalue shortcut for global.map values
local Map ---@type global.map

---@alias coe.DecompressedData {[integer]: coe.DecompressedRow}
---@alias coe.DecompressedRow nil|{[integer]: terrain_code} A decompressed row of tile terrain codes
---@alias terrain_code '_'|'o'|'O'|'w'|'W'|'g'|'m'|'G'|'d'|'D'|'s'|'S'
---@alias terrain_tile_name string

--- Terrain codes must be in sync with the ConvertMap code
--- TODO: add support for cliffs from the images
---@class terrain_codes
---@field [terrain_code] terrain_tile_name
local terrain_codes = {
  ["_"] = "out-of-map",
  ["o"] = "deepwater",
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
local debug_ignore = { __debugline = "Decompressed Map Data", __debugchildren = false }

-- =============================================================================

---Scale positions from spawn position
---@param cities coe.Cities
---@param detailed_scale double
---@return coe.Cities
local function initCities(cities, detailed_scale)
  local offset_cities = {} ---@type coe.Cities
  for _, city in pairs(cities) do
    offset_cities[city.name] = {
      fullname = city.fullname,
      name = city.name,
      position = {
        x = city.position.x * detailed_scale,
        y = city.position.y * detailed_scale
      },
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
local function getCity(cities, world, setting_key)
  local key = settings.startup[setting_key].value--[[@as string]]
  local city = world.cities[key] and cities[world.cities[key].name]
  if not city then
    city = cities[world.cities[ world.city_names[random(2, #world.city_names)] ].name]
  end
  return city
end

--------------------------------------------------------------------------------

---Create a surface by cloning the first surfaces settings.
---@param cities coe.Cities
---@param city_size uint
---@return LuaSurface
local function createSurface(cities, city_size)
  local surface = game.surfaces[1]
  local map_gen_settings = surface.map_gen_settings
  map_gen_settings.width = Map.width
  map_gen_settings.height = Map.width
  map_gen_settings.starting_points = {}
  for _, city in pairs(cities) do table.insert(map_gen_settings.starting_points, city.position) end
  map_gen_settings.starting_area = city_size
  return game.create_surface(Config.SURFACE_NAME, map_gen_settings)
end

--------------------------------------------------------------------------------

---Get the width of a row of decompressed data. All compressed rows must be the same width.
---@param row? uint
---@return uint
local function getWidth(row)
  row = row or 1
  local total_count = 0
  local compressed_line = Data[row]
  for _, count in compressed_line:gmatch("(%a+)(%d+)") do total_count = total_count + count end
  return total_count
end

--------------------------------------------------------------------------------

---@param y integer
---@return coe.DecompressedRow
local function decompressLine(y)
  local decompressed_row = Map.decompressed[y]
  if decompressed_row then return decompressed_row end
  decompressed_row = {} ---@type coe.DecompressedRow
  -- Convert column from 1 - width to -half_width - half_width
  local left_x = -Map.decompressed_width_radius
  -- Convert row from -half_height - half_height to 1 - height
  local row = Map.decompressed_height - (Map.decompressed_height_radius - y)
  local compressed_line = Data[row]
  for letter, count in compressed_line:gmatch("(%a+)(%d+)") do
    for x = left_x, left_x + count do
      decompressed_row[x] = letter
    end
    left_x = left_x + count
  end
  Map.decompressed[y] = decompressed_row
  return decompressed_row
end

--------------------------------------------------------------------------------

---@param x integer
---@param y integer
---@return terrain_code #A character tile code
local function getTileCode(x, y)
  local hr, wr = Map.decompressed_height_radius, Map.decompressed_width_radius
  if (y < -hr or y > hr) or (x < -wr or x > wr) then return "_" end
  return decompressLine(y)[x]
end

--------------------------------------------------------------------------------

---@param totals table
---@param weight number
---@param code terrain_code
local function addToTotal(totals, weight, code)
  if totals[code] == nil then
    totals[code] = { code = code, weight = weight }
  else
    totals[code].weight = totals[code].weight + weight
  end
end

--------------------------------------------------------------------------------

---@param x double
---@param y double
---@return terrain_tile_name
local function generateTileName(x, y)

  local scale = Map.scale
  local max_scale = Map.max_scale
  local sqrt_detail = Map.sqrt_detail

  x = x / scale
  y = y / scale

  -- get cells this data point is between
  local top = floor(y)
  local bottom = top + 1
  local left = floor(x)
  local right = left + 1

  -- Calculate weights
  -- 1 - sqrt( (top - y) * (top - y) + (left - x) * (left - x) ) / sqrt(2)
  local ty, by = top - y, bottom - y -- subtract
  ty, by = ty * ty, by * by -- square

  local lx, rx = left - x, right - x
  lx, rx = lx * lx, rx * rx

  local w_top_left = 1 - sqrt(ty + lx) / sqrt_detail
  w_top_left = w_top_left * w_top_left + random() / max_scale

  local w_top_right = 1 - sqrt(ty + rx) / sqrt_detail
  w_top_right = w_top_right * w_top_right + random() / max_scale

  local w_bottom_left = 1 - sqrt(by + lx) / sqrt_detail
  w_bottom_left = w_bottom_left * w_bottom_left + random() / max_scale

  local w_bottom_right = 1 - sqrt(by + rx) / sqrt_detail
  w_bottom_right = w_bottom_right * w_bottom_right + random() / max_scale

  -- get codes
  local c_top_left = getTileCode(left, top)
  local c_top_right = getTileCode(right, top)
  local c_bottom_left = getTileCode(left, bottom)
  local c_bottom_right = getTileCode(right, bottom)

  -- calculate total weights for codes
  local totals = {}
  addToTotal(totals, w_top_left, c_top_left)
  addToTotal(totals, w_top_right, c_top_right)
  addToTotal(totals, w_bottom_left, c_bottom_left)
  addToTotal(totals, w_bottom_right, c_bottom_right)

  -- choose final code
  local code ---@type terrain_code
  local weight = 0

  for _, total in pairs(totals) do
    if total.weight > weight then
      code = total.code
      weight = total.weight
    end
  end
  return terrain_codes[code]
end

-- =============================================================================

---@param event on_chunk_generated
function WorldGen.onChunkGenerated(event)
  if (event.surface ~= Map.surface) then return end

  local lt = event.area.left_top
  local rb = event.area.right_bottom
  local tiles = {}

  for y = lt.y, rb.y do
    for x = lt.x, rb.x do
      table.insert(tiles, { name = generateTileName(x, y), position = { x, y } })
    end
  end

  event.surface.set_tiles(tiles, true)
  -- local positions = { event.position }
  -- surface.destroy_decoratives( { area = event.area } )
  -- surface.regenerate_decorative( nil, positions )
  -- surface.regenerate_entity( nil, positions )
end

--------------------------------------------------------------------------------

---Initialize World data
---This only needs to happen when a new map is created
---Maps are created with a maximum size based on scale, centered on 0, 0
---
function WorldGen.onInit()
  global.map = {}
  Map = global.map
  local world_name = settings.startup.coe_world_map.value--[[@as string]]
  Map.world_name = world_name
  local World = Worlds[world_name]
  Data = World.data

  -- A value of .5 with give you a 1 to 1 map at 2x (default) detail.
  Map.scale = settings.startup.coe_map_scale.value--[[@as double]]
  Map.detailed_scale = Map.scale * Config.DETAIL_LEVEL
  Map.decompressed = setmetatable({}, debug_ignore)

  Map.decompressed_width = getWidth()
  Map.decompressed_width_radius = floor(Map.decompressed_width / 2)

  Map.width = floor(Map.decompressed_width * Map.detailed_scale)
  Map.width_radius = floor(Map.width / 2)

  Map.decompressed_height = #Data
  Map.decompressed_height_radius = floor(Map.decompressed_height / 2)

  Map.height = floor(Map.decompressed_height * Map.detailed_scale)
  Map.height_radius = floor(Map.height / 2)

  Map.max_scale = max(Map.scale / Config.DETAIL_LEVEL, 10)
  Map.sqrt_detail = sqrt(Config.DETAIL_LEVEL)

  Map.cities = initCities(World.cities, Map.detailed_scale)
  Map.surface = createSurface(Map.cities, 1)

  --- TODO set in Forces
  Map.spawn_city = assert(getCity(Map.cities, World, World.settings.spawn))
  Map.silo_city = assert(getCity(Map.cities, World, World.settings.silo))
  game.forces["player"].set_spawn_position(Map.spawn_city.position, Map.surface--[[@as SurfaceIdentification]] )
end -- InitWorld

function WorldGen.onLoad()
  -- load the data externally
  setmetatable(global.map.decompressed, debug_ignore)
  Map = global.map
  Data = Worlds[global.map.world_name].data
end

-- =============================================================================

return WorldGen
