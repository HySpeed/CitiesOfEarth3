---@class coe.Silo
local Silo = {}

local Config = require("config")
local Utils = require("utils/utils")
local Surface = require("scripts/coe_surface")

local world ---@type coe.world
local pre_place_silo ---@type string

-- ============================================================================

---@param force LuaForce
local function enableSiloCrafting(force)
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
local function create_silo(surface, city)
  local pos = Utils.positionAdd(city.position, Config.SILO_OFFSET)

  ---@type LuaSurface.create_entity_param
  local build_params = {
    name = Config.ROCKET_SILO,
    force = world.force,
    position = pos,
    move_stuck_players = true,
    raise_built = true,
    create_build_effect_smoke = false,
  }

  local silo = Surface.forceBuildParams(surface, build_params)
  if not silo then
    Utils.print("WARNING: Failed to build rocket_silo: " .. city.name .. " " .. Utils.positionToStr(build_params.position))
    return --It really shouldn't fail at this point.
  end

  Utils.print("Created rocket_silo: " .. city.name .. " " .. Utils.positionToStr(build_params.position))

  return silo
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Silo.onCityGenerated(event)

  local city = world.cities[event.city_name]
  if pre_place_silo == "All" then
    local silo = create_silo(event.surface, city)
    if silo then
      silo.destructible = false
      silo.minable = false
      city.rocket_silo.entity = silo
      -- city.rocket_silo = rocket_silo
    end
  elseif pre_place_silo == "Single" and event.city_name == global.world.silo_city.name then
    local silo = create_silo(event.surface, city)
    if silo then
      silo.destructible = false
      silo.minable = false
      city.rocket_silo.entity = silo
      -- city.rocket_silo = global.rocket_silo
    end
  end

end

-------------------------------------------------------------------------------

---@param event EventData.on_city_charted
function Silo.onCityCharted(event)
  local city = world.cities[event.city_name]
  local silo = city.rocket_silo and city.rocket_silo.entity
  if (silo and silo.valid) then
    Surface.decorate(event.surface, silo)
-- TODO this may need a check to only add tag to silo_city
    if pre_place_silo == "Single" then
      local tag = {
      icon = { type = "item", name = "rocket-silo" },
      position = city.rocket_silo.entity.position,
      text = "   Rocket Silo"
      }
      world.force.add_chart_tag(event.surface, tag)
    end
  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_rocket_launched
function Silo.onRocketLaunched(event)
  -- using silo_city.rocket_silo for counting global numbers, even with "All"
  local generic_rocket_silo = global.world.silo_city.rocket_silo
  generic_rocket_silo.total_launches = generic_rocket_silo.total_launches + 1

  if global.world.silo_city.rocket_silo.required_launches > 1 then

    if not event.rocket.has_items_inside() then
      game.print { "", { "coe.text_mod_name" }, " ", { "coe.text_empty_rocket" } }
      game.print { "", { "coe.text_mod_name" }, " ",
        tostring(rocket_silo.required_launches - rocket_silo.total_launches), { "coe.text_total_rockets" }, "" }
      return
    end

    if pre_place_silo == "All" then
      local this_rocket_silo = Utils.findSiloByUnitNumber( event.rocket_silo.unit_number )
      this_rocket_silo.launches_this_silo = this_rocket_silo.launches_this_silo + 1
      this_rocket_silo.entity.active = false
      this_rocket_silo.entity.auto_launch = false
      this_rocket_silo.entity.operable = false
    end

    if generic_rocket_silo.total_launches < generic_rocket_silo.required_launches then
      game.print { "", { "coe.text_mod_name" }, " ", 
        tostring(generic_rocket_silo.total_launches), { "coe.text_rockets_launched" }, "" }
      game.print { "", { "coe.text_mod_name" }, " ",
        tostring(generic_rocket_silo.required_launches - generic_rocket_silo.total_launches),
        { "coe.text_more_rockets" }, "" }
    end

    -- fix for 1.5.8.  'required' and 'restore' were combined
    if generic_rocket_silo.restore_recipe_launches == nil then
      generic_rocket_silo.restore_recipe_launches = settings.startup.coe_launches_to_restore_silo_crafting.value --[[@as integer]]
    end
    -- if the required launches to restore silo crafting has been met, and the recipe is disabled, enable the recipe
    if generic_rocket_silo.total_launches >= generic_rocket_silo.restore_recipe_launches then
      -- Reenable silo crafting, this will check if the recipe is already disabled
      enableSiloCrafting(event.rocket.force--[[@as LuaForce]] )
      -- For "All", re-enable all silos
      if pre_place_silo == "All" then
        for index = 1,  #global.world.city_names do
          local city = global.world.cities[global.world.city_names[index]]
          city.rocket_silo.entity.active = true
          city.rocket_silo.entity.operable = true
        end
      end
    end

    if generic_rocket_silo.total_launches == generic_rocket_silo.required_launches then
      game.set_game_state
      {
        game_finished = true,
        player_won = true,
        can_continue = true,
        victorious_force = event.rocket.force
      }
    end

  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_research_finished
function Silo.onResearchFinished(event)
  -- using silo_city.rocket_silo for counting global numbers, even with "All"
  local generic_rocket_silo = global.world.silo_city.rocket_silo

  if not (generic_rocket_silo.entity and generic_rocket_silo.entity.valid) then return end

  -- fix for 1.5.8.  'required' and 'restore' were combined
  if generic_rocket_silo.restore_recipe_launches == nil then
    generic_rocket_silo.restore_recipe_launches = settings.startup.coe_launches_to_restore_silo_crafting.value --[[@as integer]]
  end
  if generic_rocket_silo.total_launches >= generic_rocket_silo.restore_recipe_launches then return end

  local recipes = event.research.force.recipes
  if recipes[Config.ROCKET_SILO] then
    log("Disabling Silo recipe ")
    recipes[Config.ROCKET_SILO].enabled = false
  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_player_died
function Silo.onPlayerDied(event)
  -- using silo_city.rocket_silo for counting global numbers, even with "All"
  local generic_rocket_silo = global.world.silo_city.rocket_silo
  local required_launches = generic_rocket_silo.required_launches

  if generic_rocket_silo.total_launches >= required_launches then return end
  -- only record a death if the setting is enabled and success hasn't completed
  if generic_rocket_silo.launches_per_death <= 0 then return end

  required_launches = required_launches + generic_rocket_silo.launches_per_death

  game.print { "", { "coe.text_mod_name" }, " ", { "coe.text_death_of" }, " ",
    game.players[event.player_index].name, { "coe.text_increased_launches" }, " ",
    tostring(generic_rocket_silo.launches_per_death) }
  game.print { "", { "coe.text_mod_name" }, " ",
    tostring(generic_rocket_silo.required_launches - generic_rocket_silo.total_launches),
    { "coe.text_more_rockets" }, "" }
end

-------------------------------------------------------------------------------

function Silo.onInit()
  pre_place_silo = settings.startup.coe_pre_place_silo.value
  global.world.silo_city.rocket_silo = {}
  local silo_crafting = 0

  if pre_place_silo == "All" then
    silo_crafting = #global.world.city_names
    for index = 1,  #global.world.city_names do
      local city = global.world.cities[global.world.city_names[index]]
      city.rocket_silo = {
        launches_per_death = settings.startup.coe_launches_per_death.value --[[@as integer]] ,
        required_launches = silo_crafting --[[@as integer]] ,
        restore_recipe_launches = silo_crafting --[[@as integer]] ,
        total_launches = 0,
        launches_this_silo = 0
      }
    end
  elseif pre_place_silo == "Single" then
    silo_crafting = settings.startup.coe_launches_to_restore_silo_crafting.value --[[@as integer]]
    global.world.silo_city.rocket_silo = {
      launches_per_death = settings.startup.coe_launches_per_death.value --[[@as integer]] ,
      required_launches = silo_crafting --[[@as integer]] ,
      restore_recipe_launches = silo_crafting --[[@as integer]] ,
      total_launches = 0,
      launches_this_silo = 0
    }
  else
    global.world.silo_city.rocket_silo.required_launches = 0
    global.world.silo_city.rocket_silo.total_launches = 0
  end


 world = global.world
  -- rocket_silo = global.rocket_silo

  if silo_crafting > 0 then
    remote.call("silo_script", "set_no_victory", true)
  end
end

-------------------------------------------------------------------------------

function Silo.onLoad()
  world = global.world
  -- rocket_silo = global.rocket_silo
end

-- ============================================================================

return Silo

---@class coe.global
---@field rocket_silo coe.rocket_silo

---@class coe.rocket_silo
---@field total_launches uint
---@field required_launches integer
---@field launches_per_death integer
---@field entity LuaEntity?
---@field city coe.city?

---@class coe.city
---@field rocket_silo coe.rocket_silo?
