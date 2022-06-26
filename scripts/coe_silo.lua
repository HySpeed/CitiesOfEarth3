---@class coe.Silo
local Silo = {}
local silo ---@type global.silo

---@class global
---@field silo global.silo
---@class global.silo
---@field silo LuaEntity
---@field city_name string
---@field pre_place_silo boolean
---@field total_launches uint
---@field required_launches number
---@field launches_per_death integer

local Config = require("config")
local Utils = require("scripts/coe_utils")
local Surface = require("scripts/coe_surface")

-- ============================================================================

---@param force LuaForce
local function enableSiloCrafting(force)
  if not silo.pre_place_silo then return end

  local recipe = force.recipes[Config.ROCKET_SILO]
  local technology = force.technologies[Config.ROCKET_SILO]

  if not technology.researched then return end
  if recipe.enabled then return end
  recipe.enabled = true
  game.print( {"",  {"coe.text_mod_name"}, {"coe.text_silo_crafting_enabled"}} )
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_generated
function Silo.onCityGenerated(event)
  if not silo.pre_place_silo then return end
  local silo_city = Surface.getSiloCity()
  if event.city_name ~= silo_city.name then return end
  silo.city_name = silo_city.name

  local silo_position = Utils.positionAdd(silo_city.position, {-10, 10})
  local surface = event.surface

  ---@type LuaSurface.create_entity_param
  local build_params = {
    name = Config.ROCKET_SILO,
    force = Config.PLAYER_FORCE,
    position = silo_position,
    move_stuck_players = true,
    raise_built = true,
  }

  build_params = Surface.forceBuildParams(surface, build_params)

  local silo_entity = surface.create_entity(build_params)

  if not silo then
    log("WARNING: Failed to build silo: ".. silo_city.name .. " " .. Utils.positionToStr(silo_position))
    return -- It really shouldn't fail at this point.
  end

  silo_city.silo = silo_entity
  silo.silo = silo_entity
  silo_entity.destructible = false
  silo_entity.minable = false
  Utils.devPrint({"",  {"coe.text_silo_placed"}, silo_city.name})
end

-------------------------------------------------------------------------------

---@param event EventData.on_chunk_charted
function Silo.onChunkCharted(event)
end

-------------------------------------------------------------------------------

---@param event EventData.on_rocket_launched
function Silo.onRocketLaunched(event)
  if silo.required_launches <= 0 then return end

  if not event.rocket.has_items_inside() then
    game.print({"",  {"coe.text_mod_name"}, {"coe.text_empty_rocket"}})
    game.print({"",  {"coe.text_mod_name"}, tostring( silo.required_launches - silo.total_launches ), {"coe.text_more_rockets"}, ""})
    return
  end

  silo.total_launches = silo.total_launches + 1

  if silo.total_launches < silo.required_launches then
    game.print( {"",  {"coe.text_mod_name"}, tostring( silo.total_launches ),
                        {"coe.text_rockets_launched"}, ""} )
      game.print( {"",  {"coe.text_mod_name"}, tostring( silo.required_launches - silo.total_launches ),
                        {"coe.text_more_rockets"}, ""} )
    return
  end

  if silo.total_launches ~= silo.required_launches then return end

  game.set_game_state
  {
    game_finished = true,
    player_won = true,
    can_continue = true,
    victorious_force = event.rocket.force
  }

  -- Reenable silo crafting
  enableSiloCrafting(event.rocket.force--[[@as LuaForce]])
end

---@param event EventData.on_research_finished
function Silo.onResearchFinished(event)
  if not silo.pre_place_silo then return end
  if silo.total_launches >= silo.required_launches then return end

  local recipes = event.research.force.recipes
    if recipes[Config.ROCKET_SILO] then
      recipes[Config.ROCKET_SILO].enabled = false
    end
end

-------------------------------------------------------------------------------

---@param event EventData.on_player_died
function Silo.onPlayerDied(event)
  if silo.total_launches >= silo.required_launches then return end
  -- only record a death if the setting is enabled and success hasn't completed
  if silo.launches_per_death <= 0 then return end

  silo.required_launches = silo.required_launches + silo.launches_per_death

  game.print({
    "", { "coe.text_mod_name" }, { "coe.text_death_of" }, game.players[event.player_index].name, { "coe.text_increased_launches" },
    tostring(silo.launches_per_death)
  })
  game.print({ "", { "coe.text_mod_name" }, tostring(silo.required_launches), { "coe.text_more_rockets" } })
end

-- ============================================================================

function Silo.onInit()
  global.silo = {
    pre_place_silo = settings.startup.coe_pre_place_silo.value--[[@as boolean]],
    launches_per_death = settings.global.coe_launches_per_death.value--[[@as integer]],
    required_launches = settings.global.coe_launches_to_restore_silo_crafting.value--[[@as integer]],
    total_launches = 0,
  }
  silo = global.silo
  if silo.required_launches > 0 then
    remote.call( "silo_script", "set_no_victory", true )
  end
end

-------------------------------------------------------------------------------

function Silo.onLoad()
  silo = global.silo
end

-- ============================================================================

return Silo
