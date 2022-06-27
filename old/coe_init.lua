
local function getCityFirstLetter( city_name )
  -- city names have "region, country, city".  Parse the name to the 2nd comma, get first letter after that
  -- this could probably be refactored to be better.
    local letter = ""
    local first_comma = string.find( city_name, "," )
    local second_comma = string.find( city_name, ",", first_comma + 1 )
    letter = string.sub( city_name, second_comma + 2, second_comma + 2 )
    return letter
  end -- getCityFirstLetter

-------------------------------------------------------------------------------

local function buildDestinationsTable()
-- called at init to create table with all destiations disabled
-- for the city list, build a grid of cities with each icon as a city destination's first letter.
-- The grid is built by the number of cities and the grid they build, based on rows & columns.

  local dest_grid = {}
  for y = 1, 10 do
    for x = 1, 20 do
      local create = false
      local city_entity = nil
      local city_name = ""
      local city_letter = ""
      for _, city in pairs( global.cities ) do
        if x == city.map_grid.x and y == city.map_grid.y then
          if global.all_teleporters_available then
            create = true
          end
          city_entity = city
          city_name = city.name
          city_letter = getCityFirstLetter( city_name )
          break
        end
      end
      local grid_data = {
        create = create,
        city_name = city_name,
        letter = city_letter,
        tags = {
          action = "coe_city_tp_button",
          city_name = city_name
        }
      }
      table.insert( dest_grid, grid_data )
    end
  end
  return dest_grid
end -- buildDestinationsTable

-- =============================================================================

function Init.InitSettings()
  -- Teleporters

  global.all_teleporters_available = settings.global["coe_all_teleporters_available"].value
  -- global.discharge_equipment       = settings.global["coe_discharge_equipment"].value
  global.dest_grid                 = buildDestinationsTable()
  -- Teleport controls (stored for displaying messages later)
  global.tp_to_city = settings.global["coe_teleporting_enabled"].value
end -- InitSettings

--------------------------------------------------------------------------------
