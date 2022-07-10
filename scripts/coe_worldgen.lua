---World Gen code from Factorio world mod oddler_world_gen
---@class coe.WorldGen
local WorldGen = {}

local Config = require("config")
local Utils = require("utils/utils")
local Worlds = require("data/worlds")

---onLoad() Upvalue shortcut.
local worldgen ---@type coe.worldgen
local world ---@type coe.world
---onLoad() Compressed data does not change and does not need to be in global.
local compressed_data ---@type string[]
local decompressed_data ---@type coe.DecompressedData
local skip_generation = Utils.getStartupSetting("coe_dev_skip_generation") --[[@as boolean]]

---@alias coe.DecompressedData {[integer]: coe.DecompressedRow}
---@alias coe.DecompressedRow nil|{[integer]: terrain_code} A decompressed row of tile terrain codes
---@alias terrain_code '_'|'o'|'O'|'w'|'W'|'g'|'m'|'G'|'d'|'D'|'s'|'S'
---@alias terrain_tile_name 'out-of-map'|'deepwater'|'deepwater-green'|'water'|'water-green'
---| 'grass-1'|'grass-3'|'grass-2'|'dirt-3'|'dirt-6'|'sand-1'|'sand-3'

---Terrain codes must be in sync with the ConvertMap code.
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

local sqrt, max, random, floor, ceil = math.sqrt, math.max, math.random, math.floor, math.ceil
local debug_ignore = { __debugline = "Decompressed Map Data", __debugchildren = false }

-- =============================================================================

---Create a cities table by scaling the position, adding chunk_position, distance_to other cities.
---@param world_cities coe.Cities
---@param detailed_scale double
---@return coe.cities
local function initCities(world_cities, detailed_scale)
  local offset_cities = {} ---@type coe.Cities
  for _, world_city in pairs(world_cities) do
    local position = { x = world_city.position.x * detailed_scale, y = world_city.position.y * detailed_scale }
    local chunk_position = Utils.mapToChunk(position)
    local map_position = Utils.positionAdd(Utils.chunkToMap(chunk_position), { 16, 16 })
    local gui_grid = { x = world_city.gui_grid.x, y = world_city.gui_grid.y }
    offset_cities[world_city.name] = {
      full_name = world_city.full_name,
      name = world_city.name,
      position = map_position,
      gui_grid = gui_grid,
      chunk_position = chunk_position
    }
  end
  ---Populate distance_to other cities
  for _, city in pairs(offset_cities) do
    city.distance_to = { [city.name] = 0 }
    for _, other_city in pairs(offset_cities) do
      if city.name ~= other_city.name then
        city.distance_to[other_city.name] = Utils.positionDistance(city.position, other_city.position)
      end
    end
  end
  return offset_cities
end

-------------------------------------------------------------------------------

---@param cities coe.cities
local function initCityNames(cities)
  local city_names = {}
  for name in pairs(cities) do
    city_names[#city_names + 1] = name
  end
  return city_names
end

-------------------------------------------------------------------------------

---Create and [x][y] array of cities for quick lookup based on chunk position.
---@param cities coe.cities
---@return coe.city_chunks
local function initCityChunks(cities)
  local city_chunks = {} ---@type coe.city_chunks
  for _, city in pairs(cities) do
    city_chunks[city.chunk_position.x] = city_chunks[city.chunk_position.x] or {}
    local chunk_x = city_chunks[city.chunk_position.x] ---@cast chunk_x -nil
    if chunk_x[city.chunk_position.y] then error("Chunk position already exists in chunk map" .. city.name) end
    chunk_x[city.chunk_position.y] = city
  end
  return city_chunks
end

-------------------------------------------------------------------------------

---Create and [x][y] array of cities for quick lookup based on gui_grid position.
---@param cities coe.cities
---@return coe.city_chunks
local function initGuiGridPositions(cities)
  local gui_grid = {} ---@type coe.gui_grid
  for _, city in pairs(cities) do
    gui_grid[city.gui_grid.x] = gui_grid[city.gui_grid.x] or {}
    local grid_x = gui_grid[city.gui_grid.x] ---@cast grid_x -nil
    grid_x[city.gui_grid.y] = city
  end
  return gui_grid
end

-------------------------------------------------------------------------------

---Send a startup setting key to retrieve the value.
---@param cities coe.Cities
---@param this_world coe.World
---@param setting_key string
---@return coe.city
local function getCity(cities, this_world, setting_key)
  local key = settings.startup[setting_key].value --[[@as string]]
  local city = this_world.cities[key] and cities[this_world.cities[key].name]
  if not city then
    -- Get a random city, the first index is the string "Random City"
    city = cities[this_world.cities[this_world.city_names[random(2, #this_world.city_names)]].name]
  end
  return city
end

-------------------------------------------------------------------------------

---Pregenerate the city chunks.
---@param surface LuaSurface
---@param cities coe.cities
---@param radius uint
local function pregenerate_city_chunks(surface, cities, radius)
  local count = 0
  for _, city in pairs(cities) do
    count = count + 1
    surface.request_to_generate_chunks(city.position, radius)
  end
  log("Requesting generation of " .. count .. " cities with a radius of " .. radius .. " on " .. surface.name .. ".")
  surface.force_generate_chunk_requests()
  log("Generation request complete at tick " .. game.tick)
end

-------------------------------------------------------------------------------

---Create a surface by cloning the first surfaces map generation settings.
---@param spawn_city coe.city
---@return LuaSurface
local function createSurface(spawn_city)
  local surface = game.surfaces[1]
  local map_gen_settings = surface.map_gen_settings
  map_gen_settings.width = worldgen.width
  map_gen_settings.height = worldgen.height
  map_gen_settings.starting_points = { spawn_city.position }
  map_gen_settings.peaceful_mode = Utils.getStartupSetting("coe_dev_mode") --[[@as boolean]] or map_gen_settings.peaceful_mode
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

---Upvalue for weights to avoid creating a new table every time.
---All values must be reset to 0 before use.
local _weightMap = {}
for code in pairs(terrain_codes) do
  _weightMap[code] = 0
end

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
  if tile_lt == tile_rt and tile_lt == tile_lb and tile_lt == tile_rb then
    return terrain_codes[tile_rt]
  end

  -- Calculate weights
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

  -- update the weight map
  _weightMap[tile_lt] = _weightMap[tile_lt] + weight_lt
  _weightMap[tile_rt] = _weightMap[tile_rt] + weight_rt
  _weightMap[tile_lb] = _weightMap[tile_lb] + weight_lb
  _weightMap[tile_rb] = _weightMap[tile_rb] + weight_rb

  -- get the best code
  local best_code = tile_lt
  if _weightMap[tile_rt] > _weightMap[best_code] then
    best_code = tile_rt
  end
  if _weightMap[tile_lb] > _weightMap[best_code] then
    best_code = tile_lb
  end
  if _weightMap[tile_rb] > _weightMap[best_code] then
    best_code = tile_rb
  end

  -- Reset the weight map
  _weightMap[tile_lt] = 0
  _weightMap[tile_rt] = 0
  _weightMap[tile_lb] = 0
  _weightMap[tile_rb] = 0

  return terrain_codes[best_code]
end

-------------------------------------------------------------------------------

---Tile cache for set_tiles do not use this anywhere else.
---The values in the cache are overwritten before being read.
---This cache is faster to use and provides less GC churn.
local _tilesCache = {}
for i = 1, 1024 do
  _tilesCache[i] = { position = { 0, 0 } }
end

---@param event EventData.on_chunk_generated
function WorldGen.onChunkGenerated(event)
  if event.surface ~= world.surface then return end
  if skip_generation then return end
  if not worldgen.ready then return world.surface.delete_chunk(event.position) end

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
  event.surface.regenerate_decorative(nil, positions)
  event.surface.regenerate_entity(nil, positions)
  return true
end

-- ============================================================================

---Clear the surface in init and then pregenerate the city chunks.
---@param event EventData.on_surface_cleared
function WorldGen.onSurfaceCleared(event)
  log("Surface cleared at tick " .. event.tick)
  worldgen.ready = true
  pregenerate_city_chunks(world.surface, world.cities, Config.CITY_CHUNK_RADIUS)
end

-------------------------------------------------------------------------------

---Initialize World data
---This only needs to happen when a new map is created
---Maps are created with a maximum size based on scale, centered on 0, 0
function WorldGen.onInit()
  global.worldgen = {}
  global.world = {}
  worldgen = global.worldgen
  world = global.world

  worldgen.ready = false
  worldgen.world_name = settings.startup.coe_world_map.value --[[@as string]]
  local this_world = Worlds[worldgen.world_name]

  compressed_data = this_world.data
  decompressed_data = setmetatable({}, debug_ignore)

  -- A value of .5 will give you a 1 to 1 map at 2x (default) detail.
  worldgen.decompressed_data = decompressed_data
  worldgen.scale = settings.startup.coe_map_scale.value --[[@as double]]
  worldgen.detailed_scale = worldgen.scale * Config.DETAIL_LEVEL
  worldgen.decompressed_width = getWidth()
  worldgen.decompressed_width_radius = ceil(worldgen.decompressed_width / 2 - 1)
  worldgen.width = floor(worldgen.decompressed_width * worldgen.scale)
  worldgen.width_radius = floor(worldgen.width / 2)
  worldgen.decompressed_height = #compressed_data
  worldgen.decompressed_height_radius = ceil(worldgen.decompressed_height / 2 - 1)
  worldgen.height = floor(worldgen.decompressed_height * worldgen.scale)
  worldgen.height_radius = floor(worldgen.height / 2)
  worldgen.max_scale = max(worldgen.scale / Config.DETAIL_LEVEL, 10)
  worldgen.sqrt_detail = sqrt(Config.DETAIL_LEVEL)

  world.cities = initCities(this_world.cities, worldgen.detailed_scale)
  world.city_names = initCityNames(world.cities)
  world.city_chunks = initCityChunks(world.cities)
  world.gui_grid = initGuiGridPositions(world.cities)
  world.spawn_city = assert(getCity(world.cities, this_world, this_world.settings.spawn))
  world.spawn_city.is_spawn_city = true
  world.silo_city = assert(getCity(world.cities, this_world, this_world.settings.silo))
  world.silo_city.is_silo_city = true
  world.surface = createSurface(world.spawn_city)
  world.surface_index = world.surface.index
  world.cities_to_generate = #world.city_names
  world.cities_to_chart = #world.city_names
  world.force = game.forces[Config.PLAYER_FORCE]
  world.chunks_charted = 0

  log(string.format("World initialized: %s, spawn city: %s, silo city %s", worldgen.world_name, world.spawn_city.name, world.silo_city.name))
  log(string.format("World width: %d, height: %d, scale: %0.2f", worldgen.width, worldgen.height, worldgen.scale))
  world.surface.clear()
end

-------------------------------------------------------------------------------

---Assign local upvalues to global.worldgen and global.world and both data tables
function WorldGen.onLoad()
  worldgen = global.worldgen
  world = global.world
  compressed_data = Worlds[worldgen.world_name].data
  decompressed_data = setmetatable(worldgen.decompressed_data, debug_ignore)
end

-- =============================================================================

if __DebugAdapter then
  __DebugAdapter.stepIgnore(WorldGen.onChunkGenerated)
  __DebugAdapter.stepIgnore(decompressLine)
  __DebugAdapter.stepIgnore(generateTileName)
  __DebugAdapter.stepIgnore(_tilesCache)
  __DebugAdapter.stepIgnore(_weightMap)
end

return WorldGen

---@alias coe.city_chunks {[integer]: nil|{[integer]: nil|coe.city}}
---@alias coe.gui_grid {[integer]: nil|{[integer]: nil|coe.city}}
---@alias coe.city.distance_to {[string]: number}
---@alias coe.cities {[string]: coe.city}

---@class coe.global
---@field worldgen coe.worldgen
---@field world coe.world

---@class coe.worldgen
---@field decompressed coe.DecompressedData
---@field scale double
---@field detailed_scale double The scale * detail level of the compressed data
---@field max_scale double
---@field sqrt_detail double
---@field decompressed_height uint
---@field decompressed_height_radius uint
---@field decompressed_width uint
---@field decompressed_width_radius uint
---@field height uint The height of the map.
---@field height_radius uint Half the width of the map.
---@field width uint The width of the map.
---@field width_radius uint Half the height of the map.
---@field world_name string The current world
---@field ready boolean Whether the map is ready to be used.

---@class coe.world
---@field cities_to_chart uint Number of cities left to chart
---@field cities_to_generate uint Number of cities left to generate
---@field cities coe.cities
---@field city_names string[] The names of the cities in the world
---@field city_chunks coe.city_chunks chunk[x][y] array used to lookup city by chunk_position
---@field gui_grid coe.gui_grid gui_grid[x][y] array used to lookup gui_position
---@field surface LuaSurface The Earth surface.
---@field surface_index uint
---@field spawn_city coe.city
---@field silo_city coe.city
---@field force LuaForce
---@field chunks_charted uint

---@class coe.city
---@field name string
---@field full_name string
---@field position MapPosition
---@field gui_grid ChunkPosition Used for gui Positioning
---@field is_spawn_city boolean
---@field is_silo_city boolean
---@field chunk_position ChunkPosition Chunk position of the city
---@field distance_to coe.city.distance_to
