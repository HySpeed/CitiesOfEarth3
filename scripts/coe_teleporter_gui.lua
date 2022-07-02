---@class coe.TeleporterGUI
local TeleporterGUI = {}

local Config = require("config")
local Player = require("scripts/coe_player")

local MAIN_FRAME_NAME = "coe_teleporter_gui"

local function destroy_teleporter_gui(player)
  local screen = player.gui.screen
  if screen[MAIN_FRAME_NAME] then
    screen[MAIN_FRAME_NAME].destroy()
  end
end

---@param destinations_frame LuaGuiElement
---@param opened_teleporter? LuaEntity
local function buildGrid(destinations_frame, opened_teleporter)
  local button_table = destinations_frame.add {
    type = "frame",
    name = "coe_map_frame",
    direction = "vertical",
    style = "coe_tp_destinations_frame"
  }.add {
    type = "scroll-pane",
    horizontal_scroll_policy = "dont-show-but-allow-scrolling",
    vertical_scroll_policy = "dont-show-but-allow-scrolling"
  }.add {
    type = "table",
    name = "button_table",
    column_count = 20,
    style = "filter_slot_table",
    tooltip = { "coe.text_destinations" }
  }

  local grid = global.world.gui_grid
  local teleporter ---@type global.teleporter?
  if opened_teleporter then
    teleporter = global.teleporters[opened_teleporter.unit_number]
  end

  for row = 1, 10 do
    for column = 1, 20 do
      local city = grid[column] and grid[column][row] --[[@as global.city|nil]]
      if city and city.charted and city.teleporter and city.teleporter.valid then
        local is_teleporter_city = city.teleporter == teleporter
        local sprite_name = (is_teleporter_city and "anything" or city.name:sub(1, 1))
        -- TODO ++Energy requirement based on distance
        local button = button_table.add {
          type = "sprite-button",
          tooltip = city.full_name,
          sprite = ("virtual-signal/signal-" .. sprite_name),
          style = "slot_button",
          tags = { city_name = city.name },
        }
        button.enabled = not is_teleporter_city and city.teleporter.energy > 0
      else
        local empty = button_table.add { type = "sprite", sprite = "coe_empty_sprite" }
        empty.enabled = false
        empty.style.size = 32
      end
    end
  end
end

---@param event EventData.on_gui_opened
local function create_main_frame(event)
  local player = game.get_player(event.player_index)
  local screen = player.gui.screen
  if screen[MAIN_FRAME_NAME] then
    screen[MAIN_FRAME_NAME].destroy()
  end

  if event.entity and event.entity.energy <= 0 then
    player.opened = defines.gui_type.none
    return
  end

  local main_frame = screen.add{
    type = "frame",
    name = MAIN_FRAME_NAME,
    direction = "vertical",
  }
  main_frame.auto_center = true
  -- main_frame.style.width = 800

  -- Header flow
  local header_flow = main_frame.add{
    type = "flow",
    direction = "horizontal",
  }.add{
    type = "label",
    style = "frame_title",
    ignored_by_interaction = true,
    caption = "Teleporters"
  }.parent.add{
    type = "empty-widget",
    ignored_by_interaction = true,
    style = "coe_titlebar_drag_handle"
  }.parent.add {
    name = MAIN_FRAME_NAME .. "_close",
    type = "sprite-button",
    style = "frame_action_button",
    hovered_sprite = "utility/close_black",
    clicked_sprite = "utility/close_black",
    sprite = "utility/close_white",
  }.parent
  header_flow.drag_target = main_frame

  -- destinations frame
  local destinations_frame = main_frame.add {
    type = "frame",
    name = "coe_destinations_frame",
    direction = "vertical",
    style = "inside_shallow_frame_with_padding"
  }

  buildGrid(destinations_frame, event.entity)
  player.opened = main_frame
end

---@param event EventData.on_gui_opened
function TeleporterGUI.onGuiOpened(event)
  if event.gui_type == defines.gui_type.entity and event.entity and event.entity.name == Config.TELEPORTER then
    return create_main_frame(event)
  end
end

---@param event EventData.on_gui_closed
function TeleporterGUI.onGuiClosed(event)
  if event.gui_type ~= defines.gui_type.custom then return end
  local player = game.get_player(event.player_index)
  destroy_teleporter_gui(player)
end

---@param event EventData.on_gui_click
function TeleporterGUI.onGuiClick(event)
  local player = game.get_player(event.player_index)
  if event.element.name == "coe_teleporter_gui_close" then
    destroy_teleporter_gui(player)
  elseif event.element.tags then
    local city_name = event.element.tags.city_name
    local city = global.world.cities[city_name]
    if not city then return end
    Player.teleport(player, city)
    destroy_teleporter_gui(player)
  end
end

return TeleporterGUI

---@class global.player
---@field teleporter_gui LuaGuiElement
