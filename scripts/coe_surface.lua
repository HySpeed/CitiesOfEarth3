---@class coe.Surface
local Surface = {}

local Utils = require("scripts/coe_utils")
local floor = math.floor

Surface.on_city_generated = script.generate_event_name()
Surface.on_city_charted = script.generate_event_name()

-- ============================================================================

---If the entity can't be placed at the first position find a nearby non_colliding position.
---If a non_colliding position can't be found then clear and tile the original position.
---@param surface LuaSurface
---@param build_params LuaSurface.create_entity_param
---@return LuaEntity
function Surface.forceBuildParams(surface, build_params)
  if not surface.can_place_entity(build_params--[[@as LuaSurface.can_place_entity_param]]) then
    local original_pos = build_params.position
    build_params.position = surface.find_non_colliding_position(build_params.name, build_params.position, 8, 1)
    if not build_params.position then build_params.position = original_pos end
  end

  local area = game.entity_prototypes[build_params.name].collision_box
  area = Utils.offsetArea(area, Utils.positionCenter(build_params.position))
  area = Utils.areaToTileArea(area)
  Surface.clearArea(surface, area)
  Surface.landfillArea(surface, area, "sand-1")

  local entity = surface.create_entity(build_params)
  build_params.area = area

  return entity
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

---@param event EventData.on_city_charted
function Surface.onChunkCharted(event)

end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Surface.onCityGenerated(event)
  log("City Generated: " .. event.city_name)
  local city = global.world.cities[event.city_name]
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

---A custom event raised when city chunks are generated.
---@class EventData.on_city_generated : EventData
---@field city_name string
---@field position MapPosition
---@field surface LuaSurface
---@field chunk ChunkPosition
---@field area BoundingBox

---@class EventData.on_city_charted : EventData.on_city_generated

---@class global.city
---@field generated boolean
