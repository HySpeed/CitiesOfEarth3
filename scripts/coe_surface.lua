--- @class coe.Surface
local Surface = {}

--- @param surface LuaSurface
--- @param position MapPosition
--- @param radius? number
function Surface.CheckAndGenerateChunk( surface, position, radius)
  radius = radius or 1
  if surface.is_chunk_generated( position ) then return end
  surface.request_to_generate_chunks( position, radius )
  surface.force_generate_chunk_requests()
end -- CheckAndCreateChunk

return Surface
