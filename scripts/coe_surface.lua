--- @class coe.Surface
local Surface = {}
--- @param surface LuaSurface
--- @param position MapPosition
--- @param radius? uint
function Surface.CheckAndGenerateChunk( surface, position, radius)
  radius = radius or 0
  if surface.is_chunk_generated( {position.x / 32, position.y / 32}) then return end
  surface.request_to_generate_chunks( position, radius )
  surface.force_generate_chunk_requests()
end -- CheckAndCreateChunk

return Surface
