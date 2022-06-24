local function getIndex( table, search )
  local result = 1
  for index, value in ipairs( table ) do
    if value == search then
      result = index
      break
    end
  end
  return result
end -- getIndex

-------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------

local function getSpawnCityName( world_map )
  local spawn_city_names = {
    ["Earth - Atlantic"]   = settings.startup["coe_spawn_city_atlantic"].value,
    ["Earth - Pacific"]    = settings.startup["coe_spawn_city_pacific"].value,
    ["Earth - Olde World"] = settings.startup["coe_spawn_city_olde_world"].value,
    ["Earth - Americas"]   = settings.startup["coe_spawn_city_americas"].value
  }
  return spawn_city_names[world_map]
end -- getSpawnCityName

-------------------------------------------------------------------------------

local function getSiloCityName( world_map )
  local silo_city_names = {
    ["Earth - Atlantic"]   = settings.startup["coe_silo_city_atlantic"].value,
    ["Earth - Pacific"]    = settings.startup["coe_silo_city_pacific"].value,
    ["Earth - Olde World"] = settings.startup["coe_silo_city_olde_world"].value,
    ["Earth - Americas"]   = settings.startup["coe_silo_city_americas"].value
  }
  return silo_city_names[world_map]
end -- getSiloCityName

--------------------------------------------------------------------------------

local function logInitData( world_map, city_varname )
  log( "~ coe_world_map : " .. world_map )
  log( "~ coe_city_var  : " .. city_varname)
  log( "~ coe_scale     : " .. global.map_scale )
  log( "~ coe_spawn_city: " .. global.spawn_city.name )
  log( "~ coe_create_tp : " .. tostring( global.create_teleporters ))
  log( "~ coe_tp_power  : " .. tostring( global.teleporters_require_power ))
  --log( "~ coe_discharge : " .. tostring( global.discharge_equipment ))
  log( "~ coe_pp_silo   : " .. tostring( global.pre_place_silo ))
    if global.pre_place_silo then
      log( "~ coe_silo_city : " .. global.silo_city.name )
    log( "~ coe_silo_pos  : " .. global.silo_city.position.x .. ", " .. global.silo_city.position.y)
  end
  log( "~ coe_lpd       : " .. tostring( global.launches_per_death ))
  log( "~ coe_tp_enabled: " .. tostring( global.tp_to_city ))
end -- logInitData

--------------------------------------------------------------------------------

-- local function getCityData( city_varname )
--   if city_varname == "cities_atlantic"   then return coeAtlantic   end
--   if city_varname == "cities_pacific"    then return coePacific    end
--   if city_varname == "cities_olde_world" then return coeOlde_World end
--   if city_varname == "cities_americas"   then return coeAmericas   end
-- end -- getCityData

-------------------------------------------------------------------------------



-------------------------------------------------------------------------------

local function setupSiloCity( world_map, city_names )
  local silo_city_name  = getSiloCityName( world_map )
  local silo_city_index = getIndex( city_names, silo_city_name )
  if silo_city_name == coeConfig.RANDOM_CITY then
    silo_city_index = math.random( 1, #city_names )
    silo_city_name = city_names[silo_city_index]
  end
  global.silo_city = util.table.deepcopy( global.cities[silo_city_name] )
  global.silo_city.name  = silo_city_name
  global.silo_city.index = silo_city_index
  global.silo_city.position = global.silo_city.offsets
  log("~ silo : " .. silo_city_name)
end -- setupSiloCity

--------------------------------------------------------------------------------



-- =============================================================================

function Init.InitSettings()
-- Load mod startup settings
  initGlobal()

  -- World Map & Cities factor
  local world_map = settings.startup["coe_world_map"].value
  local city_varname = Worlds[world_map].cities_varname
  global.cities = getCityData( city_varname )
  global.map_scale = settings.startup["coe_map_scale"].value
  local city_names = coeUtils.GetCityNames( global.cities )

  -- Spawn City
  setupSpawnCity( world_map, city_names )

  -- Pre-Place Silo
  global.pre_place_silo = settings.startup["coe_pre_place_silo"].value
  if global.pre_place_silo then
    setupSiloCity( world_map, city_names )
  end

  -- Teleporters
  global.create_teleporters        = settings.global["coe_create_teleporters"].value
  global.all_teleporters_available = settings.global["coe_all_teleporters_available"].value
  -- global.discharge_equipment       = settings.global["coe_discharge_equipment"].value
  global.dest_grid                 = buildDestinationsTable()
  global.restore_silo_crafting     = settings.global["coe_launches_to_restore_silo_crafting"].value

  -- Launches per Death
  global.launches_per_death = settings.global["coe_launches_per_death"].value
  -- this disables freeplay rocket launch victory so victory can be tied to extra launches
  if global.launches_per_death > 0 then
    remote.call( "silo_script", "set_no_victory", true )
  end

  -- Teleport controls (stored for displaying messages later)
  global.tp_to_city = settings.global["coe_teleporting_enabled"].value

  -- logInitData( world_map, city_varname )

  return world_map
end -- InitSettings

--------------------------------------------------------------------------------
