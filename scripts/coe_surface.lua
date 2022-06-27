---@class coe.Surface
local Surface = {}

---@class coe.City
---@field name string
---@field fullname string
---@field position MapPosition
---@field map_grid ChunkPosition
---@field generated boolean
---@field spawn_city boolean
---@field teleporter LuaEntity|nil
---@field silo LuaEntity|nil

---A custom event raised when city chunks are generated.
---@class EventData.on_city_generated : EventData
---@field city_name string
---@field position MapPosition
---@field surface LuaSurface
---@field chunk ChunkPosition
---@field area BoundingBox

local Utils = require("scripts/coe_utils")
local floor = math.floor

Surface.on_city_generated = script.generate_event_name()

-- ============================================================================

---@param city_name string
---@return coe.City
function Surface.getCity(city_name)
  return global.map.cities[city_name]
end

-------------------------------------------------------------------------------

---@return coe.City
function Surface.getSpawnCity()
  return global.map.cities[global.map.spawn_city]
end

-------------------------------------------------------------------------------

---@return coe.City
function Surface.getSiloCity()
  return global.map.cities[global.map.silo_city]
end

-------------------------------------------------------------------------------

---If the entity can't be placed at the first position find a nearby non_colliding position.
---If a non_colliding position can't be found then clear and tile the original position.
---@param surface LuaSurface
---@param build_params LuaSurface.create_entity_param
---@return LuaSurface.create_entity_param build_params
function Surface.forceBuildParams(surface, build_params)
  if not surface.can_place_entity(build_params--[[@as LuaSurface.can_place_entity_param]]) then
    local new_pos = surface.find_non_colliding_position(build_params.name, build_params.position, 8, 1)
    if not new_pos then
      local area = game.entity_prototypes[build_params.name].collision_box
      area = Utils.offsetArea(area, build_params.position)
      Surface.clearArea(surface, area)
      Surface.landfillArea(surface, area, "sand-1")
    else
      build_params.position = new_pos
    end
  end
  return build_params
end

-------------------------------------------------------------------------------

---Clean the area of entities
---@param surface LuaSurface
---@param area BoundingBox
function Surface.clearArea(surface, area)
  for _, entity in pairs(surface.find_entities_filtered { area = area, type = "character", invert = true })
    do entity.destroy()
  end
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param area BoundingBox
function Surface.landfillArea(surface, area, tile_name)
  local tiles = {}
  for x = floor(area.left_top.x), floor(area.right_bottom.x) do
    for y = floor(area.left_top.y), floor(area.right_bottom.y) do
      tiles[#tiles + 1] = {name = tile_name, position = {x, y}}
    end
  end
  surface.set_tiles(tiles)
end

-------------------------------------------------------------------------------

Surface.checkAndGenerateChunk = Utils.checkAndGenerateChunk

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Surface.onCityGenerated(event)
  log("City Generated: " .. event.city_name)
  local city = Surface.getCity(event.city_name)
  if city.name == global.map.spawn_city then
    city.spawn_city = true
  end
  city.generated = true
end

-- ============================================================================

function Surface.onInit()
end

-------------------------------------------------------------------------------

function Surface.onLoad()
end

-- ============================================================================

return Surface
