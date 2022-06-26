---@class coe.Surface
local coeSurface = {}

---@class on_city_generated : on_tick
---@field city_name string
---@field position MapPosition
---@field surface LuaSurface
---@field chunk ChunkPosition
---@field area BoundingBox
coeSurface.on_city_generated = script.generate_event_name()

---@param city_name string
---@return coe.City
function coeSurface.getCity(city_name)
  return global.map.cities[city_name]
end

---@return coe.City
function coeSurface.getSpawnCity()
  return global.map.cities[global.map.spawn_city]
end

---@return coe.City
function coeSurface.getSiloCity()
  return global.map.cities[global.map.silo_city]
end

---@param surface LuaSurface
---@param position MapPosition
---@param radius? uint
function coeSurface.CheckAndGenerateChunk( surface, position, radius)
  if surface.is_chunk_generated( {position.x / 32, position.y / 32}) then return end
  radius = radius or 0
  surface.request_to_generate_chunks( position, radius )
  surface.force_generate_chunk_requests()
end

function coeSurface.OnCityGenerated(event)
  log("City Generated: " .. event.city_name)
  local city = coeSurface.getCity(event.city_name)
  city.generated = true
end

return coeSurface
