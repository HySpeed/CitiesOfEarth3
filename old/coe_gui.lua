-- coe_gui.lua

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
