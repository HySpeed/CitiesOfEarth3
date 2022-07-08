---@class coe.StatsGUI
local StatsGUI = {}

local mod_gui = require("mod-gui")

-- =============================================================================

local function build_stats_info_frame(statistics_frame)
  statistics_frame.add {
    type = "label",
    caption = { "coe-stats-gui.label_launches_title" }
  }.parent.add {
    type = "flow",
    direction = "horizontal"
  }.add {
    type = "label",
    caption = { "coe-stats-gui.label_launches_required", global.rocket_silo.required_launches }
  }.parent.parent.add {
    type = "flow",
    direction = "horizontal"
  }.add {
    type = "label",
    caption = { "coe-stats-gui.label_launches_complete", global.rocket_silo.total_launches }
  }

  return statistics_frame
end -- build_stats_info_frame

-------------------------------------------------------------------------------

local function open_stats_ui(player)
  local gui = mod_gui.get_frame_flow(player)
  local statistics_frame =
  gui.add {
    type = "frame",
    name = "coe_statistics_frame",
    direction = "vertical",
    caption = { "coe-stats-gui.label_stats_title" },
    style = mod_gui.frame_style
  }

  return build_stats_info_frame(statistics_frame)
end -- open_stats_ui

-------------------------------------------------------------------------------

function StatsGUI.onPlayerCreated(event)
  local player = game.get_player(event.player_index)
  local dialog = mod_gui.get_button_flow(player)
  if dialog.coe_button_statistics then dialog.coe_button_statistics.destroy() end

  mod_gui.get_button_flow(player).add {
    name    = "coe_button_statistics",
    sprite  = "coe_show_ui",
    style   = mod_gui.button_style,
    tooltip = { "coe-stats-gui.button_statistics_tooltip" },
    type    = "sprite-button"
  }
end -- onPlayerCreated

-------------------------------------------------------------------------------

---@param event EventData.on_gui_click
function StatsGUI.onGuiClick(event)
  if event.element.valid and event.element.name == "coe_button_statistics" then
    local player = game.get_player(event.player_index)
    local frame_flow = mod_gui.get_frame_flow(player)
    if frame_flow.coe_statistics_frame then return frame_flow.coe_statistics_frame.destroy() end
    return open_stats_ui(player)
  end
end -- onGuiClick

-- =============================================================================

return StatsGUI
