---@class coe.StatsGUI
local StatsGUI = {}

local mod_gui = require("mod-gui")
local Config = require("config")

-- =============================================================================

---@param statistics_frame LuaGuiElement
local function build_stats_info_frame(statistics_frame)
  local rocket_silo = global.world.rocket_silo

  statistics_frame.add {
    type = "label",
    caption = { "coe-stats-gui.label_launches_title" }
  }.parent.add {
    type = "flow",
    direction = "horizontal"
  }.add {
    type = "label",
    caption = { "coe-stats-gui.label_launches_required", rocket_silo.required_launches }
  }.parent.parent.add {
    type = "flow",
    direction = "horizontal"
  }.add {
    type = "label",
    caption = { "coe-stats-gui.label_launches_complete", rocket_silo.total_launches }
  }

  if settings.startup.coe_pre_place_silo.value == Config.ALL then
    statistics_frame.add {
      type = "label",
      caption = "------"
    }
    for index = 1,  #global.world.city_names do
      local city = global.world.cities[global.world.city_names[index]]
      local launches = 0
      if city.rocket_silo and city.rocket_silo.launches_this_silo then
        launches = city.rocket_silo.launches_this_silo
        local caption = city.name .. ": " .. tostring( launches )
        statistics_frame.add {
          type = "label",
          caption = caption
        }
        end
    end

  end

  return statistics_frame
end -- build_stats_info_frame

-------------------------------------------------------------------------------

---@param player LuaPlayer
local function open_stats_ui(player)
  local gui = mod_gui.get_frame_flow(player) --[[@as LuaGuiElement]]
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

---@param event EventData.on_player_created
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
  if event.element.name ~= "coe_button_statistics" then return end

  local player = game.get_player(event.player_index)
  local frame_flow = mod_gui.get_frame_flow(player) --[[@as LuaGuiElement]]
  if frame_flow.coe_statistics_frame then return frame_flow.coe_statistics_frame.destroy() and true end
  return open_stats_ui(player)
end -- onGuiClick

-- =============================================================================

return StatsGUI
