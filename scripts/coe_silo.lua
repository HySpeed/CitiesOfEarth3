---@class coe.Silo
local Silo = {}

local Config = require("config")
local Utils = require("utils/utils")
local Surface = require("scripts/coe_surface")

local world ---@type global.world
local rocket_silo ---@type global.rocket_silo

-- ============================================================================

---@param force LuaForce
local function enableSiloCrafting(force)
  local recipe = force.recipes[Config.ROCKET_SILO]
  local technology = force.technologies[Config.ROCKET_SILO]

  if not technology.researched then return end
  if recipe.enabled then return end
  recipe.enabled = true
  game.print({ "", { "coe.text_mod_name" }, { "coe.text_silo_crafting_enabled" } })
end

-------------------------------------------------------------------------------

---@param surface LuaSurface
---@param city global.city
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
    Utils.print("WARNING: Failed to build rocket_silo: " ..
      city.name .. " " .. Utils.positionToStr(build_params.position))
    return --It really shouldn't fail at this point.
  end

  Utils.print("Created rocket_silo: " .. city.name .. " " .. Utils.positionToStr(build_params.position))

  return silo
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Silo.onCityGenerated(event)
  if not settings.startup.coe_pre_place_silo.value then return end
  local city = world.cities[event.city_name]
  if not city.is_silo_city then return end

  local silo = create_silo(event.surface, city)
  if not silo then return end

  silo.destructible = false
  silo.minable = false

  rocket_silo.entity = silo
  city.rocket_silo = global.rocket_silo
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_charted
function Silo.onCityCharted(event)
  local city = world.cities[event.city_name]
  local silo = city.rocket_silo and city.rocket_silo.entity
  if not (silo and silo.valid) then return end

  Surface.decorate(event.surface, silo)

  local tag = {
    icon = { type = 'virtual', name = "signal-info" },
    position = city.rocket_silo.entity.position,
    text = "   Rocket Silo"
  }
  world.force.add_chart_tag(event.surface, tag)
end

-------------------------------------------------------------------------------

---@param event EventData.on_rocket_launched
function Silo.onRocketLaunched(event)
  if rocket_silo.required_launches <= 0 then return end

  if not event.rocket.has_items_inside() then
    game.print({ "", { "coe.text_mod_name" }, { "coe.text_empty_rocket" } })
    game.print({ "", { "coe.text_mod_name" }, tostring(rocket_silo.required_launches - rocket_silo.total_launches),
      { "coe.text_more_rockets" }, "" })
    return
  end

  rocket_silo.total_launches = rocket_silo.total_launches + 1

  if rocket_silo.total_launches < rocket_silo.required_launches then
    game.print({ "", { "coe.text_mod_name" }, tostring(rocket_silo.total_launches),
      { "coe.text_rockets_launched" }, "" })
    game.print({ "", { "coe.text_mod_name" }, tostring(rocket_silo.required_launches - rocket_silo.total_launches),
      { "coe.text_more_rockets" }, "" })
    return
  end

  if rocket_silo.total_launches ~= rocket_silo.required_launches then return end

  game.set_game_state
  {
    game_finished = true,
    player_won = true,
    can_continue = true,
    victorious_force = event.rocket.force
  }

  -- Reenable silo crafting
  enableSiloCrafting(event.rocket.force--[[@as LuaForce]] )
end

-------------------------------------------------------------------------------

---@param event EventData.on_research_finished
function Silo.onResearchFinished(event)
  if not (rocket_silo.entity and rocket_silo.entity.valid) then return end
  if rocket_silo.total_launches >= rocket_silo.required_launches then return end

  local recipes = event.research.force.recipes
  if recipes[Config.ROCKET_SILO] then
    recipes[Config.ROCKET_SILO].enabled = false
  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_player_died
function Silo.onPlayerDied(event)
  if rocket_silo.total_launches >= rocket_silo.required_launches then return end
  -- only record a death if the setting is enabled and success hasn't completed
  if rocket_silo.launches_per_death <= 0 then return end

  rocket_silo.required_launches = rocket_silo.required_launches + rocket_silo.launches_per_death

  game.print({
    "", { "coe.text_mod_name" }, { "coe.text_death_of" }, game.players[event.player_index].name,
    { "coe.text_increased_launches" },
    tostring(rocket_silo.launches_per_death)
  })
  game.print({ "", { "coe.text_mod_name" }, tostring(rocket_silo.required_launches), { "coe.text_more_rockets" } })
end

-- ============================================================================

function Silo.onInit()
  global.rocket_silo = {
    launches_per_death = settings.global.coe_launches_per_death.value--[[@as integer]] ,
    required_launches = settings.global.coe_launches_to_restore_silo_crafting.value--[[@as integer]] ,
    total_launches = 0,
  }
  world = global.world
  rocket_silo = global.rocket_silo

  if rocket_silo.required_launches > 0 then
    remote.call("silo_script", "set_no_victory", true)
  end
end

-------------------------------------------------------------------------------

function Silo.onLoad()
  world = global.world
  rocket_silo = global.rocket_silo
end

-- ============================================================================

return Silo

---@class global
---@field rocket_silo global.rocket_silo

---@class global.rocket_silo
---@field total_launches uint
---@field required_launches integer
---@field launches_per_death integer
---@field entity LuaEntity?
---@field city global.city?

---@class global.city
---@field rocket_silo global.rocket_silo?
