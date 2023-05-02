---@class coe.Surface
local Surface = {}

local Utils = require("utils/utils")
local floor = math.floor

local world ---@type coe.world

-- Resources & Offsets : Relative to the teleporter, the tile offsets for the starting resources for team co-op.
local RESOURCES = {
  OFFSET = {-100, -100}, -- offset from city position
  IRON   = { name = "iron-ore",   offset = {  5,   5}, diameter = 30, amount = 1000 },
  COAL   = { name = "coal",       offset = {  5,  50}, diameter = 30, amount = 1000 },
  COPPER = { name = "copper-ore", offset = { 50,   5}, diameter = 30, amount = 1000 },
  STONE  = { name = "stone",      offset = { 50,  50}, diameter = 30, amount = 1000 },
  TREE   = { name = "tree-02",    offset = { 35,  35}, diameter = 15, amount =  100 },
  WATER  = { name = "water",      offset = {-10, -10}, diameter =  4, amount =  100 },
  OIL    = { name = "crude-oil",  offset = { 40,   5}, diameter =  4, amount = 1000 },
}

Surface.on_city_generated = script.generate_event_name()
Surface.on_city_charted = script.generate_event_name()

-- ============================================================================

-- local function generateResourcePatch( surface, resource, position, diameter, amount )
local function generateResourcePatch( surface, city, resource )
  local position = Utils.positionAdd( city.position, Utils.positionAdd( RESOURCES.OFFSET, resource.offset ))
  local diameter = resource.diameter
  local midpoint = floor( diameter / 2 )

  if diameter > 0 then
    for y = 0, diameter do
      for x = 0, diameter do
        if ( x - midpoint ) ^ 2 + ( y - midpoint ) ^ 2 < midpoint ^ 2 then
          surface.create_entity({
            name = resource.name,
            position = {position.x + x, position.y + y},
            amount = resource.amount
          })
        end
      end
    end
  end
end

-------------------------------------------------------------------------------

-- local function to generate water in city's tile, top-left
-- because water is a tile, creating it with the other resources will cause it to be replaced when that chunk is generated.
local function generateWaterPatch( surface, city, resource )
  local waterTiles = {}
  local position = Utils.positionAdd( city.position, resource.offset )

  for y = 1, resource.diameter do
    for x = 1, resource.diameter do
      table.insert( waterTiles, { name = "water", position = Utils.positionAdd( position, {x, y} )} )
    end
  end
  surface.set_tiles( waterTiles )
end

-------------------------------------------------------------------------------

-- function to generate oil near resources
local function generateOilPatch( surface, city, resource )
  local position = Utils.positionAdd( city.position, Utils.positionAdd( RESOURCES.OFFSET, resource.offset ))
  local spacer = {x = 0, y = 0}
  for y = 1, (resource.diameter / 2) do
    for x = 1, (resource.diameter / 2) do
      surface.create_entity({
        name = resource.name,
        position = {position.x + x + spacer.x, position.y + y + spacer.y},
        amount = resource.amount
      })
      spacer.x = spacer.x + 4
    end
    spacer.x = 0
    spacer.y = spacer.y + 4
  end
end

-------------------------------------------------------------------------------

-- in an area to the top-left of the teleporter, create resources: iron, coal, copper, stone, water, oil, trees
local function generateStartingResources( event, city )
  print( "area" )
  -- TODO: need to ensure not generated twice
  local surface = event.surface

  -- create a chest with landfill to address rivers near resources
  Utils.createAndFillChest( surface, Utils.positionAdd( city.position, {-5, -5} ), "wooden-chest", "landfill", 1000 )

  -- clearArea does not work as the chunk with the resources has not been generated.
  -- local area = Utils.defineInverseArea( city.position, Utils.positionAdd( city.position, RESOURCES.OFFSET ))
  -- Surface.clearArea( surface, area )
  -- TODO: fill in water in area
  -- create surface resources
  generateResourcePatch( surface, city, RESOURCES.IRON   )
  generateResourcePatch( surface, city, RESOURCES.COAL   )
  generateResourcePatch( surface, city, RESOURCES.COPPER )
  generateResourcePatch( surface, city, RESOURCES.STONE  )
  generateResourcePatch( surface, city, RESOURCES.TREE   )
  -- create water
  generateWaterPatch( surface, city, RESOURCES.WATER )
  -- create oil
  generateOilPatch( surface, city, RESOURCES.OIL )

end

-- ============================================================================

---If the entity can't be placed at the first position find a nearby non_colliding position.
---If a non_colliding position can't be found then clear and tile the original position.
---@param surface LuaSurface
---@param build_params LuaSurface.create_entity_param
---@return LuaEntity?
function Surface.forceBuildParams( surface, build_params )
  build_params.build_check_type = defines.build_check_type.script_ghost
  if not surface.can_place_entity( build_params--[[@as LuaSurface.can_place_entity_param]] ) then
    local original_pos = build_params.position
    build_params.position = surface.find_non_colliding_position( build_params.name, build_params.position, 4, 1 )
    if not build_params.position then
      log( "Suitable position not found for " .. build_params.name .. " at " .. Utils.positionToStr( original_pos ) .. " terraforming the tiles." )
      build_params.position = original_pos
      local area = game.entity_prototypes[build_params.name].collision_box
      area = Utils.offsetArea( area, Utils.positionCenter( build_params.position ) )
      area = Utils.areaToTileArea( area )
      Surface.clearArea( surface, area )
      Surface.landfillArea( surface, area, "sand-1" )
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
function Surface.clearArea( surface, area, names )
  local ignore = Utils.makeDictionary( names )
  for _, entity in pairs( surface.find_entities( area ) ) do
    if entity and entity.valid then
      if not entity.type == "character" or not ignore[entity.name] then
        entity.destroy()
      end
    end
  end
  surface.destroy_decoratives( { area = area } )
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param area BoundingBox
function Surface.landfillArea( surface, area, tile_name )
  local tiles = {}
  for x = floor( area.left_top.x ), floor( area.right_bottom.x ) do
    for y = floor( area.left_top.y ), floor( area.right_bottom.y ) do
      tiles[#tiles + 1] = { name = tile_name, position = { x, y } }
    end
  end
  surface.set_tiles( tiles )
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param entity LuaEntity
function Surface.placeTiles( surface, entity, tile_name )
  local area = entity.bounding_box
  area = Utils.areaAdjust( area, { { -1, -1 }, { 1, 1 } })
  area = Utils.areaToTileArea( area )
  Surface.landfillArea( surface, area, tile_name )
  area = Utils.areaAdjust( area, { { -2, -2 }, { 2, 2 } } )
  Surface.clearArea( surface, area, entity.name )
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param position MapPosition
---@param radius? uint
function Surface.checkAndGenerateChunk( surface, position, radius )
  local chunk_pos = {x = floor( position.x / 32 ), y = floor( position.y / 32 )}
  if surface.is_chunk_generated( chunk_pos ) then return end
  radius = radius or 0
  surface.request_to_generate_chunks( position, radius )
  surface.force_generate_chunk_requests()
end

-------------------------------------------------------------------------------

---@param event EventData.on_chunk_generated
function Surface.onChunkGenerated( event )
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
  script.raise_event( Surface.on_city_generated, event_data )
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Surface.onCityGenerated( event )
  local city = world.cities[event.city_name]
  if city.is_spawn_city then
    world.force.chart( event.surface, Utils.areaAdjust( event.area, { { -2 * 32, -2 * 32 }, { (2 * 32) - 1,( 2 * 32) - 1 } } ) )
    game.forces["player"].set_spawn_position( city.position, event.surface )
  end
  city.generated = true

  if Utils.getStartupSetting( "coe_team_coop" ) then
    generateStartingResources( event, city )
  end

  log( "City Generated #" .. world.cities_to_generate .. ": " .. event.city_name .. " at tick " .. event.tick )
  world.cities_to_generate = world.cities_to_generate - 1
  if world.cities_to_generate == 0 then log( "All cities generated at tick " .. event.tick ) end

  return true
end

-------------------------------------------------------------------------------

---@param event EventData.on_chunk_charted
function Surface.onChunkCharted( event )
  if event.surface_index ~= world.surface_index then return end
  if event.force ~= world.force then return end
  if world.cities_to_chart <= 0 then return end

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
  script.raise_event( Surface.on_city_charted, event_data )
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_charted
function Surface.onCityCharted( event )
  local city = world.cities[event.city_name]
  city.charted = true

  log( "City Charted #" .. world.cities_to_chart .. ": " .. event.city_name .. " at tick " .. event.tick )
  world.cities_to_chart = world.cities_to_chart - 1
  if world.cities_to_chart == 0 then log( "All cities charted at tick " .. game.tick ) end

  return true
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

---@class coe.city
---@field generated boolean
---@field charted boolean
