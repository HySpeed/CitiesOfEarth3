---@class coe.TeleporterGUI
local TeleporterGUI = {}

local Config = require("config")

---Header Flow
---@param destinations_frame LuaGuiElement
---@param backer_name string
---@return LuaGuiElement
local function buildHeader( destinations_frame, backer_name )
  return destinations_frame.add{
    type = "flow",
    name = "coe_info_top_frame"
  }.add{
    type = "frame",
    name = "coe_current_city_frame"
  }.add{
    type = "label",
    name = "coe_current_city_label",
    caption = {"coe.label_current_city"}
  }.parent.add{
    type = "label",
    name = "coe_current_city",
    caption = backer_name
  }.parent.parent.add{
    type = "frame",
    name = "coe_power_requirements_frame"
  }.add{
    type = "label",
    name = "coe_tp_power_req",
    caption = {"coe.label_tp_power_req"}
  }.parent.parent.parent
end

---@param destinations_frame LuaGuiElement
---@param current_teleporter any
local function buildGrid( destinations_frame, current_teleporter )
  local button_table = destinations_frame.add{
    type = "frame",
    name = "coe_map_frame",
    direction = "vertical",
    style = "coe_tp_destinations_frame"
  }.add{
    type = "scroll-pane",
    horizontal_scroll_policy = "dont-show-but-allow-scrolling",
    vertical_scroll_policy = "dont-show-but-allow-scrolling"
  }.add{
    type = "table",
    name = "button_table",
    column_count = 20,
    style = "filter_slot_table",
    tooltip = {"coe.text_destinations"}
  }

  local cities = global.world.cities

  ---@alias coe.TeleporterGUI.map_grid {[integer]: nil|{[integer]: nil|global.city}}

  --TODO Save in Init
  ---@type coe.TeleporterGUI.map_grid
  local grid = {}

  for _, city in pairs(cities) do
    local position = city.gui_grid
    grid[position.x] = grid[position.x] or {}
    grid[position.x][position.y] = city
  end

  for row = 1, 10 do
    for column = 1, 20 do
      local city = grid[column] and grid[column][row]--[[@as global.city|nil]]
      if city and city.charted and city.teleporter and city.teleporter.entity and city.teleporter.entity.valid then
        local teleporter = city.teleporter.entity
        -- TODO Highlight current city
        -- TODO ++Energy requirement based on distance
        button_table.add{
          type = "sprite-button",
          tooltip = city.full_name,
          sprite = ("virtual-signal/signal-" .. "A" ),
          style = "slot_button",
          tags = {city_name = city.name},
        }.enabled = current_teleporter ~= teleporter and teleporter.energy > 0
      else
        -- TODO can this be something non-visible and maintain spacing? Empty sprite not sprite button
        button_table.add{ type="sprite-button" }.enabled = false
      end
    end
  end
end

---@param event EventData.on_gui_opened
function TeleporterGUI.onGuiOpened(event)
  if not (event.gui_type == defines.gui_type.entity) then return end
  local teleporter = event.entity
  if not (teleporter and teleporter.name == Config.TELEPORTER) then return end

  local player = game.get_player(event.player_index)
  local screen = player.gui.screen
  if screen["coe_teleporter_main_frame"] then
    screen["coe_teleporter_main_frame"].destroy()
  end
  if not (teleporter.energy > 0) then
    player.opened = defines.gui_type.none
    return
  end

  local teleporter_frame = screen.add{
    type = "frame",
    name = "coe_teleporter_main_frame",
    direction = "vertical",
    caption = { "coe.title_choose_city" }
  }
  teleporter_frame.style.size = { 880, 600 }
  teleporter_frame.auto_center = true


  -- destinations frame
  local destinations_frame = teleporter_frame.add{
    type = "frame",
    name = "coe_destinations_frame",
    direction = "vertical",
    style = "coe_tp_destinations_frame"
  }

  buildHeader(destinations_frame, event.entity.backer_name)
  buildGrid(destinations_frame, event.entity)
  player.opened = teleporter_frame --[[@as LuaEntity]]
end

function TeleporterGUI.onGuiClosed(event)
  if event.gui_type ~= defines.gui_type.custom then return end
  local player = game.get_player(event.player_index)
  local screen = player.gui.screen
  if screen["coe_teleporter_main_frame"] then
    screen["coe_teleporter_main_frame"].destroy()
  end
end

return TeleporterGUI
