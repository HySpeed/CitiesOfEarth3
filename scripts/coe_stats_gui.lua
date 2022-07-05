---@class coe.StatsGUI
local StatsGUI = {}

local mod_gui = require( "mod-gui" )

-- =============================================================================

local function build_stats_info_frame( statistics_frame )
  local info_frame = statistics_frame.add{
    type = "frame",
    name = "coe_stats_info_frame",
    direction = "vertical"
  }

  info_frame.add{
    type = "label",
    caption = {"coe-stats-gui.label_launches_title"}
  }.parent.add{
    type = "flow",
    direction = "horizontal"
  }.add{
    type = "label",
    caption = {"coe-stats-gui.label_launches_required"}
  }.parent.add{
    type = "label",
    caption = tostring( global.rocket_silo.required_launches )
  }.parent.parent.add{
    type = "flow",
    direction = "horizontal"
  }.add{
    type = "label",
    caption = {"coe-stats-gui.label_launches_complete"}
  }.parent.add{
    type = "label",
    caption = tostring( global.rocket_silo.total_launches )
  }
end -- build_stats_info_frame

-------------------------------------------------------------------------------

local function open_stats_ui(event)
  local player = game.get_player(event.player_index)
  local gui = player.gui.left
  local statistics_frame =
      gui.add {
      type = "frame",
      name = "coe_statistics_frame",
      direction = "vertical",
      caption = {"coe-stats-gui.label_stats_title"}
  }

  build_stats_info_frame( statistics_frame )

  local pdata = global.players[event.player_index]
  pdata.button_statistics_visible = true

end -- open_stats_ui

-------------------------------------------------------------------------------

local function close_stats_gui( event )
  local player = game.get_player(event.player_index)
  if player then
    if player.gui.left.coe_statistics_frame then
      player.gui.left.coe_statistics_frame.destroy()
    end
  end
  local pdata = global.players[event.player_index]
  pdata.button_statistics_visible = false
end -- close_stats_gui

-------------------------------------------------------------------------------

function StatsGUI.setupStatsGUI( event )
  local player = game.get_player(event.player_index)
  local dialog = mod_gui.get_button_flow( player )
  if dialog.coe_button_statistics then dialog.coe_button_statistics.destroy() end

  mod_gui.get_button_flow(player).add({
    name    = "coe_button_statistics",
    sprite  = "coe_show_ui",
    style   = "mod_gui_button",
    tooltip = {"coe-stats-gui.button_statistics"},
    type    = "sprite-button"
  })
end -- setupStatsGUI

-------------------------------------------------------------------------------

---@param event EventData.on_gui_click
function StatsGUI.onGuiClick(event)
  if event.element.name == "coe_button_statistics" then
    local pdata = global.players[event.player_index]
    if pdata.button_statistics_visible then
      close_stats_gui( event)
    else
      open_stats_ui( event )
    end
    return
  end
end -- onGuiClick

-- =============================================================================

return StatsGUI
