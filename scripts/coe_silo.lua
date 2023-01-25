---@class coe.Silo
local Silo = {}

local Config = require("config")
local Utils = require("utils/utils")
local Surface = require("scripts/coe_surface")

local world ---@type coe.world
local pre_place_silo ---@type string

-- ============================================================================

---@param Event_rocket_launched
local function disableSiloUsingEvent( event )
  local rocket_silo = Utils.findSiloByUnitNumber( event.rocket_silo.unit_number )
  rocket_silo.entity.active = false
  rocket_silo.entity.auto_launch = false
  rocket_silo.entity.operable = false
end

-------------------------------------------------------------------------------

local function enableSilo( rocket_silo )
  if rocket_silo then
    rocket_silo.entity.active = true
    rocket_silo.entity.operable = true
  end
end

-------------------------------------------------------------------------------

local function enableSilos()
  for index = 1,  #global.world.city_names do
    local city = global.world.cities[global.world.city_names[index]]
    if city.rocket_silo and city.rocket_silo.entity then
      city.rocket_silo.entity.active = true
      city.rocket_silo.entity.operable = true
    end
  end
end

-------------------------------------------------------------------------------

---@param force LuaForce
local function enableSiloCrafting( force )
  local recipe = force.recipes[Config.ROCKET_SILO]
  local technology = force.technologies[Config.ROCKET_SILO]

  if not technology.researched then return end
  if recipe.enabled then return end
  recipe.enabled = true
  game.print { "", { "coe.text_mod_name" }, " ", { "coe.text_silo_crafting_enabled" } }
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param city coe.city
---@return LuaEntity?
local function create_silo( surface, city )
  local pos = Utils.positionAdd( city.position, Config.SILO_OFFSET )

  ---@type LuaSurface.create_entity_param
  local build_params = {
    name = Config.ROCKET_SILO,
    force = world.force,
    position = pos,
    move_stuck_players = true,
    raise_built = true,
    create_build_effect_smoke = false
  }

  local rocket_silo = Surface.forceBuildParams( surface, build_params )
  if not rocket_silo then
    Utils.print("WARNING: Failed to build rocket_silo: " .. city.name .. " " .. Utils.positionToStr(build_params.position))
    return --It really shouldn't fail at this point.
  end
  rocket_silo.destructible = false
  rocket_silo.minable = false

  Utils.print("Created rocket silo: " .. city.name .. " " .. Utils.positionToStr(build_params.position))

  return rocket_silo
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Silo.onCityGenerated( event )
  if pre_place_silo == Config.NONE then return end

  local city = world.cities[event.city_name]
  if pre_place_silo == Config.ALL then
    local rocket_silo = create_silo( event.surface, city )
    if rocket_silo then
      city.rocket_silo.entity = rocket_silo
    end
  elseif pre_place_silo == Config.SINGLE and event.city_name == global.world.silo_city.name then
    local rocket_silo = create_silo( event.surface, city )
    if rocket_silo then
      city.rocket_silo = {}
      city.rocket_silo.entity = rocket_silo
    end
  end

end

-------------------------------------------------------------------------------

---@param event EventData.on_city_charted
function Silo.onCityCharted(event)
  local city = world.cities[event.city_name]
  local rocket_silo = city.rocket_silo and city.rocket_silo.entity

  if (rocket_silo and rocket_silo.valid) then
    Surface.decorate(event.surface, rocket_silo)
    if pre_place_silo == Config.SINGLE then
      local tag = {
        icon = { type = "item", name = Config.ROCKET_SILO },
        position = city.rocket_silo.entity.position,
        text = "   Rocket Silo"
      }
      world.force.add_chart_tag(event.surface, tag)
    end
  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_rocket_launched
function Silo.onRocketLaunched( event )
  local rocket_silo = global.world.rocket_silo
  if not rocket_silo or pre_place_silo == Config.NONE then return end
  local this_rocket_silo = {}

  -- no rocket contents
  if not event.rocket.has_items_inside() then
    game.print { "", { "coe.text_mod_name" }, " ", { "coe.text_empty_rocket" } }
    game.print { "", { "coe.text_mod_name" }, " ", tostring(Utils.calculateRemainingLaunches()), { "coe.text_more_rockets" }, "" }
    return
  end

  if pre_place_silo == Config.NONE or pre_place_silo == Config.SINGLE then
    this_rocket_silo = global.world.rocket_silo
    if this_rocket_silo.launches_this_silo == nil then this_rocket_silo.launches_this_silo = 0 end -- fix for 1.6.2 "Single"
  elseif pre_place_silo == Config.ALL and global.world.cities[global.world.city_names[1]].rocket_silo then -- ensures a rocket silo exists for any city
    this_rocket_silo = Utils.findSiloByUnitNumber( event.rocket_silo.unit_number )
  else
      error("ERROR: 'pre_place_silo' has an invalid value")
      return -- catches initialization / migration errors
    end

  if event.rocket.has_items_inside() then
    rocket_silo.total_launches = rocket_silo.total_launches + 1
    game.print { "", { "coe.text_mod_name" }, " ", tostring(rocket_silo.total_launches), { "coe.text_rockets_launched" }, "" }
  end

  this_rocket_silo.launches_this_silo = this_rocket_silo.launches_this_silo + 1
  local remaining_launches = Utils.calculateRemainingLaunches()

  if remaining_launches > 0 then
    game.print { "", { "coe.text_mod_name" }, " ", tostring(remaining_launches), { "coe.text_more_rockets" }, "" }
    if pre_place_silo == Config.ALL then
      local max_launches = Utils.calculateMaxLaunches()
      if this_rocket_silo.launches_this_silo >= max_launches then
        disableSiloUsingEvent( event )
      end
      -- if the value of 'launches_this_silo' is 1, it is a new silo 'unlocked'.  Enable other silos that have been unlocked.
      if this_rocket_silo.launches_this_silo == 1 then
        Silo.checkEnablingSilos( max_launches )
      end
    end
  else -- remaining launches <= 0
    local force = event.rocket.force
    enableSiloCrafting(force) -- Reenable silo crafting (this will check if the recipe is already disabled)
    if pre_place_silo == Config.ALL then -- re-enable all silos
      enableSilos()
    end
    game.set_game_state
    {
      game_finished = true,
      player_won = true,
      can_continue = true,
      victorious_force = force
    }
  end

end

-------------------------------------------------------------------------------

---@param event EventData.on_research_finished
function Silo.onResearchFinished(event)
  -- local rocket_silo = getRocketSiloData()
  local rocket_silo = global.world.rocket_silo
  if not rocket_silo or pre_place_silo == Config.NONE then return end
  -- do not disable if required launches has been reached.
  if Utils.calculateRemainingLaunches() <= 0 then return end

  local recipes = event.research.force.recipes
  if recipes[Config.ROCKET_SILO] then
    log("Disabling Silo recipe ")
    recipes[Config.ROCKET_SILO].enabled = false
  end
end

-------------------------------------------------------------------------------

function Silo.setPrePlacedSilo( pre_place_silo_value )
  pre_place_silo = pre_place_silo_value
end

-------------------------------------------------------------------------------

-- loop through silos, find 'launches_this_silo' > 0 and if less than max_launches enable each
function Silo.checkEnablingSilos( max_launches )

  for index = 1,  #global.world.city_names do
    local city = global.world.cities[global.world.city_names[index]]
    if city.rocket_silo and city.rocket_silo.launches_this_silo
      and city.rocket_silo.launches_this_silo > 0 and city.rocket_silo.launches_this_silo < max_launches then
      enableSilo( city.rocket_silo )
    end
  end
end

-------------------------------------------------------------------------------

function Silo.onInit()
  pre_place_silo = global.settings.startup.coe_pre_place_silo.value
  global.world.rocket_silo = {
    total_launches = 0,
    launches_this_silo = 0
  }

  if pre_place_silo == Config.ALL then
    remote.call("silo_script", "set_no_victory", true)
    local required_launches = #global.world.city_names
    global.world.rocket_silo.required_launches = required_launches
    for index = 1,  required_launches do
      local city = global.world.cities[global.world.city_names[index]]
      city.rocket_silo = {}
      city.rocket_silo.launches_this_silo = 0
    end
  elseif pre_place_silo == Config.SINGLE then
    remote.call("silo_script", "set_no_victory", true)
    global.world.rocket_silo.required_launches = 1
  else -- NONE or nil
    global.world.rocket_silo.required_launches = 0
  end

  world = global.world
end

-------------------------------------------------------------------------------

function Silo.onLoad()
  if global.settings and global.settings.startup.coe_pre_place_silo then
    pre_place_silo = global.settings.startup.coe_pre_place_silo.value
  end
  world = global.world
end

-- ============================================================================

return Silo

---@class coe.global
---@field rocket_silo coe.rocket_silo

---@class coe.rocket_silo
---@field total_launches uint
---@field required_launches integer
---@field entity LuaEntity?
---@field city coe.city?

---@class coe.city
---@field rocket_silo coe.rocket_silo?
