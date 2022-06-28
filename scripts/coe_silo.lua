---@class coe.Silo
local Silo = {}

local Config = require("config")
local Utils = require("scripts/coe_utils")
local Surface = require("scripts/coe_surface")

local silo ---@type global.silo
local world ---@type global.world

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
  local city = world.cities[event.city_name]
  if not city.is_silo_city then return end

  local silo_position = Utils.positionAdd(city.position, Config.SILO_OFFSET)
  local surface = event.surface

  ---@type LuaSurface.create_entity_param
  local build_params = {
    name = Config.ROCKET_SILO,
    force = Config.PLAYER_FORCE,
    position = silo_position,
    move_stuck_players = true,
    raise_built = true,
  }

  local silo_entity = Surface.forceBuildParams(surface, build_params)

  local area = silo_entity.bounding_box
  area = Utils.areaAdjust(area, {{-1,-1}, {1, 1}})
  area = Utils.areaToTileArea(area)

  Surface.landfillArea(surface, area, "hazard-concrete-right")

  if not silo then
    Utils.devPrint("WARNING: Failed to build silo: ".. city.name .. " " .. Utils.positionToStr(silo_position))
    return -- It really shouldn't fail at this point.
  end

  silo_entity.destructible = false
  silo_entity.minable = false

  city.silo = silo_entity
  silo.silo = silo_entity
  silo.city = city

  Utils.devPrint({"",  {"coe.text_silo_placed"}," ", city.name})
end

-------------------------------------------------------------------------------

---@param event EventData.on_city_charted
function Silo.onCityCharted(event)

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
  world = global.world

  if silo.required_launches > 0 then
    remote.call( "silo_script", "set_no_victory", true )
  end
end

-------------------------------------------------------------------------------

function Silo.onLoad()
  silo = global.silo
  world = global.world
end

-- ============================================================================

return Silo

---@class global
---@field silo global.silo
---@class global.silo
---@field silo LuaEntity
---@field city global.city
---@field pre_place_silo boolean
---@field total_launches uint
---@field required_launches integer
---@field launches_per_death integer
---@class global.city
---@field silo LuaEntity
