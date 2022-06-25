--- @class coe.Surface
local Surface = {}
--- @param surface LuaSurface
--- @param position MapPosition
--- @param radius? uint
function Surface.CheckAndGenerateChunk( surface, position, radius)
  if surface.is_chunk_generated( {position.x / 32, position.y / 32}) then return end
  radius = radius or 0
  surface.request_to_generate_chunks( position, radius )
  surface.force_generate_chunk_requests()
end

return Surface
