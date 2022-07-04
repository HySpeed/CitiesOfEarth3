---@class coe.TeleporterGUI
local TeleporterGUI = {}

local Config = require("config")
local Utils = require("utils/utils.lua")
local Player = require("scripts/coe_player")

local MAIN_FRAME_NAME = "coe_teleporter_gui"

-- =============================================================================

---@param player LuaPlayer
---@return LuaGuiElement
local function destroy_teleporter_gui(player)
  local screen = player.gui.screen
  if screen[MAIN_FRAME_NAME] then
    screen[MAIN_FRAME_NAME].destroy()
    local pdata = global.players[player.index]
    pdata.grid = nil
    pdata.current_teleporter = nil
  end
  return screen
end

-------------------------------------------------------------------------------

---@param destinations_frame LuaGuiElement
---@param opened_teleporter LuaEntity
---@return LuaGuiElement
local function buildGrid(destinations_frame, opened_teleporter)
  local pane = destinations_frame.add{
    type = "scroll-pane",
    horizontal_scroll_policy = "dont-show-but-allow-scrolling",
    vertical_scroll_policy = "dont-show-but-allow-scrolling"
  }

  local button_table = pane.add{
    type = "table",
    name = "button_table",
    column_count = 20,
    style = "filter_slot_table",
    tooltip = { "coe-teleporter-gui.title" }
  }

  local grid = global.world.gui_grid
  local teleporter  = global.teleporters[opened_teleporter.unit_number]

  for row = 1, 10 do
    for column = 1, 20 do
      local city = grid[column] and grid[column][row]
      if city and city.charted and city.teleporter and city.teleporter.valid then
        local is_current_city = city.teleporter == teleporter
        local sprite= "virtual-signal/signal-" .. (is_current_city and "anything" or city.name:sub(1, 1))
        local distance = math.floor(Utils.positionDistance(teleporter.position, city.teleporter.position) / 32)
        local required_energy = math.min(Config.TP_ENERGY_PER_CHUNK * distance, Config.TP_MAX_ENERGY)
        local tooltip = {"coe-teleporter-gui.target-tooltip", city.full_name, Utils.factorio.format_number(required_energy * 60, true)}

        local button = button_table.add{
          type = "sprite-button",
          tooltip = tooltip,
          sprite = sprite,
          style = "slot_button",
          ---@type coe.TeleporterGUI.cityTags
          tags = {
            city_name = city.name,
            current_city_name = teleporter.city.name,
            required_energy = required_energy,
          },
        }
        button.enabled = not is_current_city and teleporter.energy >= required_energy
      else
        local empty = button_table.add { type = "sprite", sprite = "coe_empty_sprite" }
        empty.enabled = false
        empty.style.size = 32
      end
    end
  end
  return button_table
end

---@param main_frame LuaGuiElement
---@param teleporter? LuaEntity
local function buildFooter(main_frame, teleporter)
  local city = teleporter and global.teleporters[teleporter.unit_number] and global.teleporters[teleporter.unit_number].city
  if not city then return end
  main_frame.add{
    type = "label",
    caption = "Current City: " .. city.full_name,
  }
end

-------------------------------------------------------------------------------

---@param event EventData.on_gui_opened
local function create_main_frame(event)
  local player = game.get_player(event.player_index)
  local screen = destroy_teleporter_gui(player)

  if event.entity and event.entity.energy <= 0 then
    player.opened = defines.gui_type.none
    player.create_local_flying_text{
      color = {r = 1, g = 0, b = 0},
      text = {"coe-teleporter-gui.no-energy"},
      position = event.entity.position,
    }
    return
  end

  local pdata = global.players[event.player_index]

  local main_frame = screen.add{
    type = "frame",
    name = MAIN_FRAME_NAME,
    direction = "vertical",
  }
  main_frame.auto_center = true

  -- Header flow
  local header_flow = main_frame.add{
    type = "flow",
    direction = "horizontal",
  }.add{
    type = "label",
    style = "frame_title",
    ignored_by_interaction = true,
    caption = {"coe-teleporter-gui.title"}
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

  -- Inner Frame
  local inner_frame = main_frame.add {
    type = "frame",
    name = "coe_destinations_frame",
    direction = "vertical",
    style = "inside_shallow_frame_with_padding"
  }

  pdata.grid = buildGrid(inner_frame, event.entity)
  buildFooter(main_frame, event.entity)
  pdata.current_teleporter = event.entity
  player.opened = main_frame
end

-- =============================================================================

---@param event EventData.on_gui_opened
function TeleporterGUI.onGuiOpened(event)
  if event.gui_type == defines.gui_type.entity and event.entity and event.entity.name == Config.TELEPORTER then
    return create_main_frame(event)
  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_gui_closed
function TeleporterGUI.onGuiClosed(event)
  if event.gui_type ~= defines.gui_type.custom then return end
  local player = game.get_player(event.player_index)
  destroy_teleporter_gui(player)
end

-------------------------------------------------------------------------------

---@param event EventData.on_gui_click
function TeleporterGUI.onGuiClick(event)
  local player = game.get_player(event.player_index)
  if event.element.name == "coe_teleporter_gui_close" then
    destroy_teleporter_gui(player)
  elseif event.element.tags then
    local tags = event.element.tags --[[@as coe.TeleporterGUI.cityTags]]
    local target_city = global.world.cities[tags.city_name]
    if not target_city then return end
    local current_city = global.world.cities[tags.current_city_name] or {}
    Player.teleport(player, target_city, current_city.teleporter, tags.required_energy)
    destroy_teleporter_gui(player)
  end
end

-------------------------------------------------------------------------------

function TeleporterGUI.onNthTick()
  for _, pdata in pairs(global.players) do
    if pdata.grid and pdata.grid.valid then
      for _, button in pairs(pdata.grid.children) do
        if button.tags and button.tags.required_energy then
          local tags = button.tags --[[@as coe.TeleporterGUI.cityTags]]
          button.enabled = tags.required_energy > 0 and pdata.current_teleporter.energy >= tags.required_energy
        end
      end
    else
      pdata.grid = nil
      pdata.current_teleporter = nil
    end
  end
end

-- =============================================================================

return TeleporterGUI

---@class global.player
---@field grid LuaGuiElement?
---@field current_teleporter LuaEntity?

---@class coe.TeleporterGUI.cityTags
---@field city_name string
---@field current_city_name string?
---@field required_energy double?
