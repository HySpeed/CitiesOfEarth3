--- World Gen code from Factorio world mod oddler_world_gen
---@class coe.WorldGen
local WorldGen = {}

---@class global
---@field map global.map
---@class global.map
---@field surface LuaSurface
---@field scale double
---@field max_scale integer
---@field decompressed coe.DecompressedData
---@field width uint
---@field height_radius uint
---@field height uint
---@field width_radius uint
---@field spawn_city coe.City
---@field silo_city coe.City
---@field world_name string
---@field cities coe.Cities

local Config = require("config")
local Worlds = require("data/worlds")

--- onLoad() Compressed data does not change and does not need to be in global
local Data ---@type string[]
--- onLoad() Upvalue shortcut for global.map values
local Map ---@type global.map

---@alias coe.DecompressedData {[integer]: nil|coe.DecompressedLine}
---@alias coe.DecompressedLine {[integer]: terrain_code}
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
local sqrt2 = sqrt(2)
local debug_ignore = { __debugline = "Decompressed Map Data", __debugchildren = false }

-- =============================================================================

---Scale positions from spawn position
---@param cities coe.Cities
---@param scale double
---@return coe.Cities
local function initCities(cities, scale)
  local offset_cities = {} ---@type coe.Cities
  scale = scale * Config.DETAIL_LEVEL
  for name, city in pairs(cities) do
    offset_cities[city.name] = {
      fullname = name,
      name = city.name,
      position = {
        x = (city.position.x - (Map.width_radius * Map.scale)) * scale,
        y = (city.position.y - (Map.height_radius * Map.scale)) * scale
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
local function get_city(cities, world, setting_key)
  local key = settings.startup[setting_key].value--[[@as string]]
  local city = world.cities[key] and cities[world.cities[key].name]
  if not city then
    city = cities[world.cities[world.city_names[random(2, #world.city_names)]].name]
  end
  return city
end

--------------------------------------------------------------------------------

---Create a surface by cloning the first surfaces settings.
---@param cities coe.Cities
local function create_surface(cities)
  local surface = game.surfaces[1] --- @type LuaSurface
  local map_gen_settings = surface.map_gen_settings
  map_gen_settings.width = Map.width * Map.scale --[[@as uint]]
  map_gen_settings.height = Map.height * Map.scale --[[@as uint]]
  map_gen_settings.starting_points = {}
  for _, city in pairs(cities) do table.insert(map_gen_settings.starting_points, city.position) end
  map_gen_settings.starting_area = 2
  return game.create_surface(Config.SURFACE_NAME, map_gen_settings)
end

--------------------------------------------------------------------------------

local function get_width()
  local total_count = 0
  local compressed_line = Data[1]
  for _, count in compressed_line:gmatch("(%a+)(%d+)") do total_count = total_count + count end
  return total_count
end

--------------------------------------------------------------------------------

---@param y integer
---@return coe.DecompressedLine
local function decompressLine(y)
  -- Decompressed map data
  local decompressed_line = Map.decompressed[y]
  if decompressed_line then return decompressed_line end
  decompressed_line = {}
  local total_count = -Map.width_radius
  --- Convert range -half_height, half_height to 1 - height
  local compressed_line = Data[Map.height - (Map.height_radius - y)]
  for letter, count in compressed_line:gmatch("(%a+)(%d+)") do
    for x = total_count, total_count + count do
      decompressed_line[x] = letter
    end
    total_count = total_count + count
  end
  Map.decompressed[y] = decompressed_line
  return decompressed_line
end -- decrompressLine

--------------------------------------------------------------------------------

---@param x integer
---@param y integer
---@return terrain_code #A character tile code
local function getTileCode(x, y)
  local hr, wr = Map.height_radius, Map.width_radius
  if (y < -hr or y > hr) or (x < -wr or x > wr) then return "_" end
  return decompressLine(y)[x]
end -- getWorldTileCodeRaw

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
end -- addToTotal

--------------------------------------------------------------------------------

---@param x integer
---@param y integer
---@return terrain_tile_name
local function generateTileName(x, y)

  local scale = Map.scale
  local max_scale = Map.max_scale

  x = floor(x / scale)
  y = floor(y / scale)

  -- get cells this data point is between
  local top = y
  local bottom = top + 1
  local left = x
  local right = left + 1

  -- Calculate weights
  -- 1 - sqrt( (top - y) * (top - y) + (left - x) * (left - x) ) / sqrt(2)
  local ty, by = top - y, bottom - y -- subtract
  ty, by = ty * ty, by * by -- square

  local lx, rx = left - x, right - x
  lx, rx = lx * lx, rx * rx

  local w_top_left = 1 - sqrt(ty + lx) / sqrt2
  w_top_left = w_top_left * w_top_left + random() / max_scale

  local w_top_right = 1 - sqrt(ty + rx) / sqrt2
  w_top_right = w_top_right * w_top_right + random() / max_scale

  local w_bottom_left = 1 - sqrt(by + lx) / sqrt2
  w_bottom_left = w_bottom_left * w_bottom_left + random() / max_scale

  local w_bottom_right = 1 - sqrt(by + rx) / sqrt2
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
end -- getWorldTileName

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
function WorldGen.onInit()
  global.map = {}
  Map = global.map
  local world_name = settings.startup.coe_world_map.value--[[@as string]]
  Map.world_name = world_name
  local World = Worlds[world_name]
  Data = World.data
  Map.height = #Data
  Map.height_radius = floor(Map.height / 2)
  Map.decompressed = setmetatable({}, debug_ignore)
  Map.width = get_width()
  Map.width_radius = floor(Map.width / 2)

  Map.scale = settings.startup.coe_map_scale.value--[[@as double]] -- A value of .5 with give you a 1 to 1 map
  Map.max_scale = max--[[@as integer]] (Map.scale / Config.DETAIL_LEVEL, 10)
  Map.cities = initCities(World.cities, Map.scale)
  Map.surface = create_surface(Map.cities)
  Map.spawn_city = assert(get_city(Map.cities, World, World.settings.spawn))
  Map.silo_city = assert(get_city(Map.cities, World, World.settings.silo))

  --- TODO set in Forces
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
