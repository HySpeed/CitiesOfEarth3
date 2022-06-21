-- coe_gui.lua

local coeGui = {}
local mod_gui    = require( "mod-gui" )
local coeConfig  = require( "config" )
local coeActions = require( "scripts/coe_actions" )
require( "scripts/coe_utils" )

-- =============================================================================

local function uiBuildStatsInfoFrame( statistics_frame )
  local info_frame = statistics_frame.add({
    type = "frame",
    name = "coe_info_frame",
    direction = "vertical"
  })
  info_frame.add({
    type = "label",
    name = "coe_launches_text_label",
    caption = {"coe.label_launches_title"}
  })
  local launches_required_flow = info_frame.add({
    type = "flow",
    name = "coe_launches_required_flow",
    direction = "horizontal"
  })
  launches_required_flow.add({
    type = "label",
    name = "coe_launches_required_label",
    caption = {"coe.label_launches_required"}
  })
  launches_required_flow.add({
    type = "label",
    name = "coe_launches_required_value",
    caption = tostring( global.coe.launches_to_win )
  })
  local launches_complete_flow = info_frame.add({
    type = "flow",
    name = "coe_launches_complete_flow",
    direction = "horizontal"
  })
  launches_complete_flow.add({
    type = "label",
    name = "coe_launches_complete_label",
    caption = {"coe.label_launches_complete"}
  })
  launches_complete_flow.add({
    type = "label",
    name = "coe_launches_complete_value",
    caption = tostring( global.coe.rockets_launched )
  })
end -- uiBuildStatsInfoFrame

--------------------------------------------------------------------------------

local function openStatsUI( player )
  local gui = player.gui.left
  local statistics_frame =
      gui.add {
      type = "frame",
      name = "coe_ui_statistics_frame",
      direction = "vertical",
      caption = {"coe.title_coe_ui"}
  }

  uiBuildStatsInfoFrame( statistics_frame )

  -- add close button
  statistics_frame.add({
    type = "button",
    name = "coe_button_statistics_close",
    caption = {"coe.button_close"}
  })

  global.coe[player.index].button_show_statistics_visible = true
end -- openStatsUI

--------------------------------------------------------------------------------

local function closeStatsUI( player )
  if player then
    if player.gui.left.coe_ui_statistics_frame then
      player.gui.left.coe_ui_statistics_frame.destroy()
    end
  end
  global.coe[player.index].button_show_statistics_visible = false
end -- closeStatsUI

-------------------------------------------------------------------------------

local function closeTeleportUI( screen_element )
  local coe_tp_main_frame = screen_element["coe_teleporter_main_frame"]
  if coe_tp_main_frame then
    coe_tp_main_frame.destroy()
  end
end -- closeTeleportUI

--------------------------------------------------------------------------------

local function processTeleporterUIClick( player, city_name )
  local teleporter = global.coe.cities[city_name].teleporter.entity
  if teleporter then -- debug testing
    if settings.global["coe_teleporting_enabled"].value == true then
      if teleporter.energy >= coeConfig.TP_ENERGY_REQ or settings.global["coe_teleporters_require_power"].value == false then
        coeActions.PerformTeleport( player, global.coe.cities[city_name], teleporter )
      else
        player.create_local_flying_text({
          text = {"coe.text_not_enough_energy"},
          create_at_cursor = true
        })
      end
    else
      player.create_local_flying_text({
        text = {"coe.text_teleport_action_disabled"},
        create_at_cursor = true
      })
    end
  else
    player.create_local_flying_text({text="error: teleporter object empty", create_at_cursor=true}) -- debug testing
  end
end -- processTeleporterUiClick

--------------------------------------------------------------------------------

local function uiBuildTPInfoTopFrame( destinations_frame, teleporter )
  -- info top frame
  local info_top_flow = destinations_frame.add({
    type = "flow",
    name = "coe_info_top_frame"
  })
  local current_city_frame = info_top_flow.add({
    type = "frame",
    name = "coe_current_city_frame"
  })
  current_city_frame.add({
    type = "label",
    name = "coe_current_city_label",
    caption = {"coe.label_current_city"}
  })
  current_city_frame.add({
    type = "label",
    name = "coe_current_city",
    caption = teleporter.backer_name
  })
  local power_requirements_frame = info_top_flow.add({
    type = "frame",
    name = "coe_power_requirements_frame"
  })
  power_requirements_frame.add({
    type = "label",
    name = "coe_tp_power_req",
    caption = {"coe.label_tp_power_req"}

  })
end -- UiBuildTPInfoTopFrame

--------------------------------------------------------------------------------

local function uiBuildTPTeleporterGrid( destinations_frame, teleporter )
  local map_frame = destinations_frame.add({
    type = "frame",
    name = "coe_map_frame",
    direction = "vertical",
    style = "coe_tp_destinations_frame"
  })

  local map_scroll = map_frame.add({
    type = "scroll-pane",
    horizontal_scroll_policy = "dont-show-but-allow-scrolling",
    vertical_scroll_policy = "dont-show-but-allow-scrolling"
  })

  local button_table = map_scroll.add({
    type = "table",
    name = "button_table",
    column_count = 20,
    style = "filter_slot_table",
    tooltip = {"coe.text_destinations"}
  })

  for index = 1, #global.coe.dest_grid do
    local grid_data = global.coe.dest_grid[index]
    if grid_data.create then
      global.coe.cities[grid_data.city_name].teleporter.entity = teleporter
      button_table.add({
        type = "sprite-button",
        tooltip = grid_data.city_name,
        sprite = ("virtual-signal/signal-" .. grid_data.letter ),
        style = "slot_button",
        tags = grid_data.tags
      })
    else -- empty slot
      -- TODO can this be something non-visible and maintain spacing?
      button_table.add({ type="sprite-button" })
    end
  end

end -- uiBuildTPTeleporterGrid

-- =============================================================================

function coeGui.ProcessGuiEvent( event )
  local source = event.element
  local player = game.get_player( event.player_index )

  if source.name == "coe_button_statistics_close" then
    closeStatsUI( player )
    return
  end

  if source.name == "coe_button_show_statistics" then
    if global.coe[event.player_index].button_show_statistics_visible then
      closeStatsUI( player )
    else
      openStatsUI( player )
    end
    return
  end

  if source.name == "coe_close_tp_button" then
    closeTeleportUI( player.gui.screen )
    return
  end

  if source.tags.action == "coe_city_tp_button" then
    processTeleporterUIClick( player, source.tags.city_name)
    closeTeleportUI( player.gui.screen )
    return
  end
end -- ProcessGuiEvent

--------------------------------------------------------------------------------

function coeGui.SetupPlayerUI( player, player_index )
-- Used for launch & death stats dialog
  -- setup new button, start by removing old button if it exists
  if mod_gui.get_button_flow( player ).coe_button_show_statistics then
    mod_gui.get_button_flow( player ).coe_button_show_statistics.destroy()
  end

  mod_gui.get_button_flow( player ).add {
    name    = "coe_button_show_statistics",
    sprite  = "coe_show_ui",
    style   = "mod_gui_button",
    tooltip = {"coe-tooltip.button_show_statistics"},
    type    = "sprite-button"
  }
end -- SetupPlayerUI

--------------------------------------------------------------------------------

function coeGui.BuildTeleporterUI( event )
  local player = game.get_player( event.player_index )
  local screen_element = player.gui.screen

  closeTeleportUI( screen_element )

  -- teleporter ui main_frame
  local coe_tp_main_frame = screen_element.add({
    type = "frame",
    name = "coe_teleporter_main_frame",
    direction = "vertical",
    caption = {"coe.title_choose_city"}
  })
  coe_tp_main_frame.style.size = {880, 600}
  coe_tp_main_frame.auto_center = true
  player.opened = coe_tp_main_frame

  -- destinations frame
  local destinations_frame = coe_tp_main_frame.add({
    type = "frame",
    name = "coe_destinations_frame",
    direction = "vertical",
    style = "coe_tp_destinations_frame"
  })

  uiBuildTPInfoTopFrame( destinations_frame, event.entity )
  uiBuildTPTeleporterGrid( destinations_frame, event.entity ) -- poss in the teleporter object

  -- Close button
  coe_tp_main_frame.add({
    type = "button",
    name = "coe_close_tp_button",
    caption = {"coe.button_close"}
  })

end -- BuildTeleporterUI

-- =============================================================================

return coeGui
