-- coe_actions.lua

local coeActions = {}
local coeConfig = require( "config" )
local coeUtils  = require( "scripts/coe_utils" )

-- =============================================================================

local function getRandomAmount( limit )
-- return a random non-zero value from negative to positive given value
  local result = 0
  while result == 0 do
    result = math.random( -limit, limit )
  end
  return result
end -- getRandomAmount

--------------------------------------------------------------------------------

local function dischargePlayerEquipment( player )
  -- TODO: support option to drain player's equipment of energy upon teleport
  -- loop through player equipment in armor, set energy to 0
  -- ~~ WIP : HERE
   -- get player armor
   -- local armor = game.player.get_inventory(5)[1]
   --
   -- for k, v in ipairs( armor.grid )
  --  https://lua-api.factorio.com/latest/LuaEquipment.html#LuaEquipment.energy
   -- end
--    from nexela:
-- player.get_inventory(defines.inventory.armor).insert("armor_name")
-- local armor = player.character.grid
--- the rest
  end -- DischargePlayerEquipment

--------------------------------------------------------------------------------

local function restoreSiloCrafting( event )
  -- this is called from a rocket launch
  -- if the silo crafting has been disabled and is researched, re-enable it.
  -- this function assumes a check has already been done for number of launches required to restore silo crafting.
    if global.coe.pre_place_silo then -- silo crafting is only disabled for pre-placed silos
      local force = event.rocket.force
      local recipes = force.recipes
      if force.technologies[coeConfig.ROCKET_SILO].researched then
        recipes[coeConfig.ROCKET_SILO].enabled = true
        game.print( {"",  {"coe.text_mod_name"}, {"coe.text_silo_crafting_enabled"}} )
      end
    end
  end -- restoreSiloCrafting

-- =============================================================================



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

function coeActions.RecordRocketLaunch( event )
  if global.coe.launches_per_death <= 0 then return end
  global.coe.launch_success = global.coe.launch_success or false
  if global.coe.launch_success then return end
  local rocket = event.rocket
  if not rocket and rocket.valid then return end

  --  check contents of rocket - do not count empty rockets
  if event.rocket.has_items_inside() then
    global.coe.rockets_launched = global.coe.rockets_launched + 1
    global.launches_to_win = global.launches_to_win - 1
    if global.coe.rockets_launched >= global.coe.launches_to_win then
      global.coe.launch_success = true
      game.set_game_state
      {
        game_finished = true,
        player_won = true,
        can_continue = true,
        victorious_force = rocket.force
      }
      return
    else
      if    global.coe.restore_silo_crafting > 0
        and global.coe.restore_silo_crafting <= global.coe.rockets_launched then
        restoreSiloCrafting( event )
      end
      game.print( {"",  {"coe.text_mod_name"}, tostring( global.coe.rockets_launched ),
                        {"coe.text_rockets_launched"}, ""} )
      game.print( {"",  {"coe.text_mod_name"}, tostring( global.coe.launches_to_win - global.coe.rockets_launched ),
                        {"coe.text_more_rockets"}, ""} )
    end
  else
    game.print( {"",  {"coe.text_mod_name"}, {"coe.text_empty_rocket"}} )
    game.print( {"",  {"coe.text_mod_name"}, tostring( global.coe.launches_to_win - global.coe.rockets_launched ),
                      {"coe.text_more_rockets"}, ""} )
  end

end --RecordRocketLaunch

--------------------------------------------------------------------------------

function coeActions.RemoveSiloCrafting( event )
  if    global.coe.restore_silo_crafting > 0
    and global.coe.restore_silo_crafting <= global.coe.rockets_launched then
      return -- do not disable research if enough rockets have been launched
  end

  if global.coe.pre_place_silo then
    local recipes = event.research.force.recipes
    if recipes[coeConfig.ROCKET_SILO] then
      recipes[coeConfig.ROCKET_SILO].enabled = false
    end
  end
end -- RemoveSiloCrafting

-- =============================================================================

return coeActions
