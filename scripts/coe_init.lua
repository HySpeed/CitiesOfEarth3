-- coe_init
-- initialize settings for new game

local coeInit = {}
local coeConfig     = require( "config" )
local coeUtils      = require( "scripts/coe_utils" )
local coeGui        = require( "scripts/coe_gui" )
local coeWorlds     = require( "data/worlds" )
local coeAtlantic   = require( "data/cities_atlantic"   )
local coePacific    = require( "data/cities_pacific"    )
local coeOlde_World = require( "data/cities_olde_world" )
local coeAmericas   = require( "data/cities_americas"   )

-- =============================================================================

local function initDataStructure()
  global.coe = {
    surface = game.surfaces[coeConfig.SURFACE_NAME],
    force = game.forces[coeConfig.PLAYER_FORCE],
    player_ui = {},
    cities = {},
    spawn_city = {},
    silo_city = {},
    launches_to_win = 1,
    launches_per_death = 0,
    science_per_death = 0,
    rockets_launched = 0,
    launch_success = false
  }
end -- initDataStructure

-------------------------------------------------------------------------------

local function calcOffsets( spawn_city, size_multiplier )
  -- loop through the cities and add the offset from the spawn.
  -- This is used by teleporting, placing silo, and creating teleporters

  local offsets = {}
  for city_name, _ in pairs( global.coe.cities ) do
    local city = global.coe.cities[city_name]
    global.coe.city = city
    global.coe.city.name = city_name
    global.coe.city.offsets = {
      x = (-(spawn_city.position.x - city.position.x)) * size_multiplier,
      y = (-(spawn_city.position.y - city.position.y)) * size_multiplier
    }
    city.teleporter = {}
    city.teleporter.created = false
    city.teleporter.charted = false
    table.insert( offsets, city )
  end
end -- calcOffsets

-------------------------------------------------------------------------------

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
      for _, city in pairs( global.coe.cities ) do
        if x == city.map_grid.x and y == city.map_grid.y then
          if global.coe.all_teleporters_available then
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
  log( "~ coe_scale     : " .. global.coe.map_scale )
  log( "~ coe_spawn_city: " .. global.coe.spawn_city.name )
  log( "~ coe_create_tp : " .. tostring( global.coe.create_teleporters ))
  log( "~ coe_tp_power  : " .. tostring( global.coe.teleporters_require_power ))
  --log( "~ coe_discharge : " .. tostring( global.coe.discharge_equipment ))
  log( "~ coe_pp_silo   : " .. tostring( global.coe.pre_place_silo ))
    if global.coe.pre_place_silo then
      log( "~ coe_silo_city : " .. global.coe.silo_city.name )
    log( "~ coe_silo_pos  : " .. global.coe.silo_city.position.x .. ", " .. global.coe.silo_city.position.y)
  end
  log( "~ coe_lpd       : " .. tostring( global.coe.launches_per_death ))
  log( "~ coe_tp_enabled: " .. tostring( global.coe.tp_to_city ))
end -- logInitData

--------------------------------------------------------------------------------

local function getCityData( city_varname )
  if city_varname == "cities_atlantic"   then return coeAtlantic   end
  if city_varname == "cities_pacific"    then return coePacific    end
  if city_varname == "cities_olde_world" then return coeOlde_World end
  if city_varname == "cities_americas"   then return coeAmericas   end
end -- getCityData

-------------------------------------------------------------------------------

local function setupSpawnCity( world_map, city_names )
  local spawn_city_name  = getSpawnCityName( world_map )
  local spawn_city_index = getIndex( city_names, spawn_city_name )
  if spawn_city_name == coeConfig.RANDOM_CITY then
    spawn_city_index = math.random( 1, #city_names )
    spawn_city_name  = city_names[spawn_city_index]
  end
  global.coe.spawn_city = global.coe.cities[spawn_city_name]
  global.coe.spawn_city.name  = spawn_city_name
  global.coe.spawn_city.index = spawn_city_index
  local size_multipler = global.coe.map_scale * 2 -- maps are 'detailed', which has doubled size
  calcOffsets( global.coe.spawn_city, size_multipler )
  global.coe.spawn_city.position = {
    x = global.coe.spawn_city.position.x * size_multipler,
    y = global.coe.spawn_city.position.y * size_multipler
  }
  log( "~ spawn init: " .. global.coe.spawn_city.position.x .. ", " .. global.coe.spawn_city.position.y )
end -- setupSpawnCity

-------------------------------------------------------------------------------

local function setupSiloCity( world_map, city_names )
  local silo_city_name  = getSiloCityName( world_map )
  local silo_city_index = getIndex( city_names, silo_city_name )
  if silo_city_name == coeConfig.RANDOM_CITY then
    silo_city_index = math.random( 1, #city_names )
    silo_city_name = city_names[silo_city_index]
  end
  global.coe.silo_city = util.table.deepcopy( global.coe.cities[silo_city_name] )
  global.coe.silo_city.name  = silo_city_name
  global.coe.silo_city.index = silo_city_index
  global.coe.silo_city.position = global.coe.silo_city.offsets
  log("~ silo : " .. silo_city_name)
end -- setupSiloCity

--------------------------------------------------------------------------------

local function setupForDevMode( player )

  game.print( "!!! DEV MODE ENABLED!!!")
  if global.coe.pre_place_silo then
    game.print( "!(dev) silo: " .. global.coe.silo_city.name )
    global.coe.launches_to_win = 2
  end

  player.insert{name="power-armor-mk2", count = 1}
  local armor = player.get_inventory(5)[1].grid
    armor.put({name = "fusion-reactor-equipment"})
    armor.put({name = "fusion-reactor-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "personal-roboport-mk2-equipment"})
    armor.put({name = "personal-roboport-mk2-equipment"})
    armor.put({name = "personal-roboport-mk2-equipment"})
    armor.put({name = "personal-roboport-mk2-equipment"})
    armor.put({name = "battery-mk2-equipment"})
    armor.put({name = "battery-mk2-equipment"})
  player.insert{name="construction-robot", count = 100}
  player.insert{name="landfill", count = 500}

end -- setupForDevMode

-- =============================================================================

function coeInit.InitSettings()
-- Load mod startup settings
  initDataStructure()

  -- World Map & Cities factor
  local world_map = settings.startup["coe_world_map"].value
  local city_varname = coeWorlds[world_map].cities_varname
  global.coe.cities = getCityData( city_varname )
  global.coe.map_scale = settings.startup["coe_map_scale"].value
  local city_names = coeUtils.GetCityNames( global.coe.cities )

  -- Spawn City
  setupSpawnCity( world_map, city_names )

  -- Pre-Place Silo
  global.coe.pre_place_silo = settings.startup["coe_pre_place_silo"].value
  if global.coe.pre_place_silo then
    setupSiloCity( world_map, city_names )
  end

  -- Teleporters
  global.coe.create_teleporters        = settings.global["coe_create_teleporters"].value
  global.coe.all_teleporters_available = settings.global["coe_all_teleporters_available"].value
  -- global.coe.discharge_equipment       = settings.global["coe_discharge_equipment"].value
  global.coe.dest_grid                 = buildDestinationsTable()
  global.coe.restore_silo_crafting     = settings.global["coe_launches_to_restore_silo_crafting"].value

  -- Launches per Death
  global.coe.launches_per_death = settings.global["coe_launches_per_death"].value
  -- this disables freeplay rocket launch victory so victory can be tied to extra launches
  if global.coe.launches_per_death > 0 then
    remote.call( "silo_script", "set_no_victory", true )
  end

  -- Teleport controls (stored for displaying messages later)
  global.coe.tp_to_city = settings.global["coe_teleporting_enabled"].value

  logInitData( world_map, city_varname )

  return world_map
end -- InitSettings

--------------------------------------------------------------------------------

function coeInit.SetupPlayer( player_index )
-- allows for the statistics button in the game window
  local player = game.players[player_index]
  if not global.coe then
    global.coe = {}
  end
  -- TODO having the teleporter in the player_index element may be causing desync.
  global.coe.player_ui[player_index] = { teleporter = nil, elements = {} }

  if not global.coe[player_index] then -- ui button
    global.coe[player_index] = {
      coe_ui_visible = false
    }
  end
  coeGui.SetupPlayerUI( player, player_index )

-- Disable for release versions
  global.coe.dev_mode = true
  if global.coe.dev_mode then
    setupForDevMode( player )
  end

  return player
end -- SetupPlayer

-- =============================================================================

return coeInit
