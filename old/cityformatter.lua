local U = require("__CitiesOfEarth3__/scripts/coe_utils")
local wr, hr = 7844, 3262
local blah = {}
for fullname, city in U.orderedPairs(cities_atlantic) do
  local x = city.position.x - (wr * .5)
  local y = city.position.y - (hr * .5)
  blah[fullname] = { position = { x = math.floor(x), y = math.floor(y) } }
  blah[fullname].map_grid = city.map_grid
  table.sort(blah)
  -- print(fullname, x, y)
  -- print()
end

print(serpent.block(blah))
-- 440,675
-- print(440 -  -1800.5)
