---@class coe.Surface
local Surface = {}

local Utils = require("utils/utils")
local floor = math.floor

local world ---@type global.world

Surface.on_city_generated = script.generate_event_name()
Surface.on_city_charted = script.generate_event_name()

-- ============================================================================

---If the entity can't be placed at the first position find a nearby non_colliding position.
---If a non_colliding position can't be found then clear and tile the original position.
---@param surface LuaSurface
---@param build_params LuaSurface.create_entity_param
---@return LuaEntity?
function Surface.forceBuildParams(surface, build_params)
  build_params.build_check_type = defines.build_check_type.script_ghost
  if not surface.can_place_entity(build_params--[[@as LuaSurface.can_place_entity_param]] ) then
    local original_pos = build_params.position
    build_params.position = surface.find_non_colliding_position(build_params.name, build_params.position, 4, 1)
    if not build_params.position then
      log("Suitable position not found for " .. build_params.name .. " at " .. Utils.positionToStr(original_pos) .. " terraforming the tiles.")
      build_params.position = original_pos
      local area = game.entity_prototypes[build_params.name].collision_box
      area = Utils.offsetArea(area, Utils.positionCenter(build_params.position))
      area = Utils.areaToTileArea(area)
      Surface.clearArea(surface, area)
      Surface.landfillArea(surface, area, "sand-1")
    end
  end

  local entity = surface.create_entity(build_params)
  return entity
end

-------------------------------------------------------------------------------

---Clean the area of entities
---@param surface LuaSurface
---@param area BoundingBox
---@param names? string|string[]
function Surface.clearArea(surface, area, names)
  local ignore = Utils.makeDictionary(names)
  for _, ent in pairs(surface.find_entities(area)) do
    if not ent.type == "character" or not ignore[ent.name] then
      ent.destroy()
    end
  end
  surface.destroy_decoratives { area = area }
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param area BoundingBox
function Surface.landfillArea(surface, area, tile_name)
  local tiles = {}
  for x = floor(area.left_top.x), floor(area.right_bottom.x) do
    for y = floor(area.left_top.y), floor(area.right_bottom.y) do
      tiles[#tiles + 1] = { name = tile_name, position = { x, y } }
    end
  end
  surface.set_tiles(tiles)
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param entity LuaEntity
function Surface.decorate(surface, entity)
  local area = entity.bounding_box
  area = Utils.areaAdjust(area, { { -1, -1 }, { 1, 1 } })
  area = Utils.areaToTileArea(area)
  Surface.landfillArea(surface, area, "hazard-concrete-right")
  area = Utils.areaAdjust(area, { { -2, -2 }, { 2, 2 } })
  Surface.clearArea(surface, area, entity.name)
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param position MapPosition
---@param radius? uint
function Surface.checkAndGenerateChunk(surface, position, radius)
  if surface.is_chunk_generated { position.x / 32, position.y / 32 } then return end
  radius = radius or 0
  surface.request_to_generate_chunks(position, radius)
  surface.force_generate_chunk_requests()
end

-------------------------------------------------------------------------------

---@param event EventData.on_chunk_generated
function Surface.onChunkGenerated(event)
  if world.cities_to_generate <= 0 then return end

  local chunk_x = world.city_chunks[event.position.x]
  local city = chunk_x and chunk_x[event.position.y]
  if not city or city.generated then return end

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

-------------------------------------------------------------------------------

---@param event EventData.on_chunk_charted
function Surface.onChunkCharted(event)
  if world.cities_to_chart <= 0 then return end
  if event.surface_index ~= world.surface_index then return end
  if event.force ~= world.force then return end

  local chunk_x = world.city_chunks[event.position.x]
  local city = chunk_x and chunk_x[event.position.y]
  if not city or city.charted then return end

  ---@type EventData.on_city_generated
  local event_data = {
    surface = world.surface,
    city_name = city.name,
    position = city.position,
    chunk = event.position,
    area = event.area
  }
  script.raise_event(Surface.on_city_charted, event_data)
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Surface.onCityGenerated(event)
  log("City Generated #" .. world.cities_to_generate .. ": " .. event.city_name .. " at tick " .. event.tick)
  world.cities_to_generate = world.cities_to_generate - 1
  if world.cities_to_generate == 0 then log("All cities generated at tick " .. event.tick) end

  local city = world.cities[event.city_name]
  if city.is_spawn_city then
    world.force.chart(event.surface, Utils.areaAdjust(event.area, { { -2 * 32, -2 * 32 }, { 2 * 32, 2 * 32 } }))
    game.forces["player"].set_spawn_position(city.position, event.surface)
  end
  city.generated = true
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_charted
function Surface.onCityCharted(event)
  log("City Charted #" .. world.cities_to_chart .. ": " .. event.city_name .. " at tick " .. event.tick)
  world.cities_to_chart = world.cities_to_chart - 1
  if world.cities_to_chart == 0 then log("All cities charted at tick " .. game.tick) end
  local city = world.cities[event.city_name]
  city.charted = true
end

-- ============================================================================

function Surface.onInit()
  world = global.world
end

-------------------------------------------------------------------------------

function Surface.onLoad()
  world = global.world
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
---@field charted boolean
