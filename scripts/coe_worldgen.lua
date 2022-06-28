---World Gen code from Factorio world mod oddler_world_gen
---@class coe.WorldGen
local WorldGen = {}

local Config = require("config")
local Utils = require("scripts/coe_utils")
local Surface = require("scripts/coe_surface")
local Worlds = require("data/worlds")

---onLoad() Upvalue shortcut
local worldgen ---@type global.worldgen
local world ---@type global.world
---onLoad() Compressed data does not change and does not need to be in global
local compressed_data ---@type string[]
local decompressed_data ---@type coe.DecompressedData

---@alias coe.DecompressedData {[integer]: coe.DecompressedRow}
---@alias coe.DecompressedRow nil|{[integer]: terrain_code} A decompressed row of tile terrain codes
---@alias terrain_code '_'|'o'|'O'|'w'|'W'|'g'|'m'|'G'|'d'|'D'|'s'|'S'
---@alias terrain_tile_name 'out-of-map'|'deepwater'|'deepwater-green'|'water'|'water-green'
---| 'grass-1'|'grass-3'|'grass-2'|'dirt-3'|'dirt-6'|'sand-1'|'sand-3'

---Terrain codes must be in sync with the ConvertMap code
---TODO: add support for cliffs from the images
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

-------------------------------------------------------------------------------

---Send a startup setting key to retrieve the value
---@param cities coe.Cities
---@param this_world coe.World
---@param setting_key string
---@return global.city
local function getCity(cities, this_world, setting_key)
  local key = settings.startup[setting_key].value--[[@as string]]
  local city = this_world.cities[key] and cities[this_world.cities[key].name]
  if not city then
    city = cities[this_world.cities[this_world.city_names[random(2, #this_world.city_names)]].name]
  end
  return city
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param cities coe.Cities
---@param radius uint
local function pregenerate_city_chunks(surface, cities, radius)
  local count = 0
  for _, city in pairs(cities) do
    count = count + 1
    surface.request_to_generate_chunks(city.position, radius)
  end
  log("Requesting genertion " .. count .. " cities with a radius of ".. radius ..".")
    surface.force_generate_chunk_requests()
  log("Generation request complete.")
end

-------------------------------------------------------------------------------

---Create a surface by cloning the first surfaces settings.
---@param spawn_city global.city
---@return LuaSurface
local function createSurface(spawn_city)
  local surface = game.surfaces[1]
  local map_gen_settings = surface.map_gen_settings
  map_gen_settings.width = worldgen.width
  map_gen_settings.height = worldgen.height
  map_gen_settings.starting_points = {spawn_city.position}
  return game.create_surface(Config.SURFACE_NAME, map_gen_settings)
end

-------------------------------------------------------------------------------

---Get the width of a row of decompressed data. All compressed rows must be the same width.
---@param row? uint
---@return uint
local function getWidth(row)
  row = row or 1
  local total_count = 0
  local compressed_line = compressed_data[row]
  for _, count in compressed_line:gmatch("(%a+)(%d+)") do total_count = total_count + count end
  return total_count
end

-------------------------------------------------------------------------------

---@param y integer
---@return coe.DecompressedRow
local function decompressLine(y)
  local decompressed_row = decompressed_data[y]
  if decompressed_row then return decompressed_row end
  decompressed_row = {} ---@type coe.DecompressedRow
  local height = worldgen.decompressed_height
  local width_radius, height_radius = worldgen.decompressed_width_radius, worldgen.decompressed_height_radius
  -- Convert column from 1 - width to -half_width - half_width
  local left_x = -width_radius
  -- Convert row from -half_height - half_height to 1 - height
  local row = height - (height_radius - y)
  local compressed_line = compressed_data[row]
  for letter, count in compressed_line:gmatch("(%a+)(%d+)") do
    for x = left_x, left_x + count do
      decompressed_row[x] = letter
    end
    left_x = left_x + count
  end
  decompressed_data[y] = decompressed_row
  return decompressed_row
end

---@diagnostic disable-next-line: unused-local
local function decompressData()
  log("Decompressing all Data")
  for y = -worldgen.decompressed_height_radius, worldgen.decompressed_height_radius do
    decompressLine(y)
  end
  log("Decompressing all Data finished.")
end

-------------------------------------------------------------------------------

---@param x integer
---@param y integer
---@return terrain_code #A character tile code
local function getTileCode(x, y)
  local hr, wr = worldgen.decompressed_height_radius, worldgen.decompressed_width_radius
  if (y < -hr or y > hr) or (x < -wr or x > wr) then return "_" end
  return decompressLine(y)[x]
end

-------------------------------------------------------------------------------

---@param totals table
---@param weight number
---@param code terrain_code
local function addToTotal(totals, weight, code)
  local result = totals[code]
  totals[code] = result and (result + weight) or weight
end

-------------------------------------------------------------------------------

---@param x double
---@param y double
---@return terrain_tile_name
local function generateTileName(x, y)

  local scale = worldgen.scale
  local max_scale = worldgen.max_scale
  local sqrt_detail = worldgen.sqrt_detail

  x = x / scale
  y = y / scale

  -- get cells this data point is between
  local top = floor(y)
  local bottom = top + 1
  local left = floor(x)
  local right = left + 1

  -- get codes
  local tile_lt = getTileCode(left, top)
  local tile_rt = getTileCode(right, top)
  local tile_lb = getTileCode(left, bottom)
  local tile_rb = getTileCode(right, bottom)

  -- If all the tiles are the same, we don't need to calcuate weights
  if tile_rt == tile_lt and tile_lb == tile_lt and tile_rb == tile_lt then
    return terrain_codes[tile_rt]
  end

  -- -- Calculate weights
  -- 1 - sqrt( (top - y) * (top - y) + (left - x) * (left - x) ) / sqrt(2)
  local ty = top - y
  ty = ty * ty
  local by = bottom - y
  by = by * by
  local lx = left - x
  lx = lx * lx
  local rx = right - x
  rx = rx * rx
  local weight_lt = 1 - sqrt(ty + lx) / sqrt_detail
  weight_lt = weight_lt * weight_lt + random() / max_scale
  local weight_rt = 1 - sqrt(ty + rx) / sqrt_detail
  weight_rt = weight_rt * weight_rt + random() / max_scale
  local weight_lb = 1 - sqrt(by + lx) / sqrt_detail
  weight_lb = weight_lb * weight_lb + random() / max_scale
  local weight_rb = 1 - sqrt(by + rx) / sqrt_detail
  weight_rb = weight_rb * weight_rb + random() / max_scale

  -- calculate total weights for codes
  local totals = {} ---@type {[terrain_code]: number}
  addToTotal(totals, weight_lt, tile_lt)
  addToTotal(totals, weight_rt, tile_rt)
  addToTotal(totals, weight_lb, tile_lb)
  addToTotal(totals, weight_rb, tile_rb)

  -- choose final code
  local best_code ---@type terrain_code
  local best_weight = 0
  for code, weight in pairs(totals) do
    if weight > best_weight then
      best_code = code
      best_weight = weight
    end
  end
  return terrain_codes[best_code]
end

-------------------------------------------------------------------------------

---@param event EventData.on_chunk_generated
local function tryGenerateCities(event)
  for _, city in pairs(world.cities) do
    if Utils.insideArea(city.position, event.area) then
      worldgen.cities_to_generate = worldgen.cities_to_generate - 1
      ---@type EventData.on_city_generated
      local event_data = {
        surface = event.surface,
        city_name = city.name,
        position = city.position,
        chunk = event.position,
        area = event.area
      }
      script.raise_event(Surface.on_city_generated, event_data)
    end
  end
end

-------------------------------------------------------------------------------

---Tile cache for set_tiles do not use this anywhere else.
---The values in the cache are overwritten before being read.
---This cache is faster to use and provides less GC churn.
local _tilesCache = {}
for i = 1, 1024 do
  _tilesCache[i] = {position = {0, 0}}
end

---@param event EventData.on_chunk_generated
function WorldGen.onChunkGenerated(event)
  if (event.surface ~= world.surface) then return end

  if not Config.DEV_SKIP_GENERATION then
    local lt = event.area.left_top
    local rb = event.area.right_bottom
    local count = 0
    for y = lt.y, rb.y - 1 do
      for x = lt.x, rb.x - 1 do
        count = count + 1
        local tile = _tilesCache[count]
        tile.name = generateTileName(x, y)
        tile.position[1] = x
        tile.position[2] = y
      end
    end

    event.surface.set_tiles(_tilesCache, true)
    local positions = { event.position }
    event.surface.regenerate_decorative( nil, positions )
    event.surface.regenerate_entity( nil, positions )
  end

  if worldgen.cities_to_generate >= 0 then tryGenerateCities(event) end
end

-- ============================================================================

---Initialize World data
---This only needs to happen when a new map is created
---Maps are created with a maximum size based on scale, centered on 0, 0
function WorldGen.onInit()
  global.worldgen = {}
  global.world = {}
  worldgen = global.worldgen
  world = global.world

  worldgen.world_name = settings.startup.coe_world_map.value--[[@as string]]
  local this_world = Worlds[worldgen.world_name]

  compressed_data = this_world.data
  decompressed_data = setmetatable({}, debug_ignore)

  -- A value of .5 with give you a 1 to 1 map at 2x (default) detail.
  worldgen.decompressed_data = decompressed_data
  worldgen.scale = settings.startup.coe_map_scale.value--[[@as double]]
  worldgen.detailed_scale = worldgen.scale * Config.DETAIL_LEVEL
  worldgen.decompressed_width = getWidth()
  worldgen.decompressed_width_radius = floor(worldgen.decompressed_width / 2)
  worldgen.width = floor(worldgen.decompressed_width * worldgen.detailed_scale)
  worldgen.width_radius = floor(worldgen.width / 2)
  worldgen.decompressed_height = #compressed_data
  worldgen.decompressed_height_radius = floor(worldgen.decompressed_height / 2)
  worldgen.height = floor(worldgen.decompressed_height * worldgen.detailed_scale)
  worldgen.height_radius = floor(worldgen.height / 2)
  worldgen.cities_to_generate = #this_world.city_names - 1
  worldgen.max_scale = max(worldgen.scale / Config.DETAIL_LEVEL, 10)
  worldgen.sqrt_detail = sqrt(Config.DETAIL_LEVEL)

  world.cities = initCities(this_world.cities, worldgen.detailed_scale)
  world.spawn_city = assert(getCity(world.cities, this_world, this_world.settings.spawn))
  world.spawn_city.is_spawn_city = true
  world.silo_city = assert(getCity(world.cities, this_world, this_world.settings.silo))
  world.silo_city.is_silo_city = true
  world.surface = createSurface(world.spawn_city)

  pregenerate_city_chunks(world.surface, world.cities, Config.CITY_CHUNK_RADIUS)
end

-------------------------------------------------------------------------------

function WorldGen.onLoad()
  -- load the data externally
  worldgen = global.worldgen
  world = global.world
  compressed_data = Worlds[worldgen.world_name].data
  decompressed_data = setmetatable(worldgen.decompressed_data, debug_ignore)
end

-- =============================================================================

return WorldGen

---@class global
---@field worldgen global.worldgen
---@field world global.world
---@class global.worldgen
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
---@field cities_to_generate uint Number of cities left to generate
---@class global.world
---@field cities {[string]: global.city}
---@field surface LuaSurface The Earth surface.
---@field spawn_city global.city
---@field silo_city global.city

---@class global.city
---@field name string
---@field fullname string
---@field position MapPosition
---@field map_grid ChunkPosition
---@field is_spawn_city boolean
---@field is_silo_city boolean
