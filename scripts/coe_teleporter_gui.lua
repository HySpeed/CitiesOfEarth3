---@class coe.TeleporterGUI
local TeleporterGUI = {}

local Config = require("config")
local Utils = require("utils/utils")
local Teleporter = require("scripts/coe_teleporter")

local format_number = Utils.factorio.format_number

local MAIN_FRAME_NAME = "coe_teleporter_gui"
local EMPTY_SPRITE = "coe_empty_sprite"
local CURRENT_CITY_SPRITE = "virtual-signal/signal-anything"
local EMPTY_SPRITE_BUTTON = { type = "sprite", sprite = "coe_empty_sprite", enabled = false }
local HIDDEN_CITY_BUTTON = {
  type    = "sprite-button",
  sprite  = "coe_empty_sprite",
  enabled = false,
  style   = "slot_button",
  tooltip = { "coe-teleporter-gui.not-charted-tooltip" }
}
-- =============================================================================

---@param player LuaPlayer
---@return LuaGuiElement
local function destroy_teleporter_gui(player)
  local screen = player.gui.screen
  if screen[MAIN_FRAME_NAME] then
    screen[MAIN_FRAME_NAME].destroy()
  end
  local pdata = global.players[player.index]
  pdata.grid = nil
  pdata.current_teleporter = nil
  return screen
end

-------------------------------------------------------------------------------

---@param destinations_frame LuaGuiElement
---@param opened_teleporter LuaEntity
---@return LuaGuiElement
local function buildGrid(destinations_frame, opened_teleporter)
  local pane = destinations_frame.add {
    type = "scroll-pane",
    horizontal_scroll_policy = "dont-show-but-allow-scrolling",
    vertical_scroll_policy = "dont-show-but-allow-scrolling"
  }

  local button_table = pane.add {
    type = "table",
    name = "button_table",
    column_count = 20,
    style = "filter_slot_table",
    tooltip = { "coe-teleporter-gui.title" }
  }

  local grid            = global.world.gui_grid
  local teleporter      = global.teleporters[opened_teleporter.unit_number]
  local requires_energy = settings.global.coe_teleporters_require_power.value

  for row = 1, 10 do
    for column = 1, 20 do
      local city = grid[column] and grid[column][row]
      if city and city.charted and city.teleporter and city.teleporter.valid then
        local is_current_city = city.teleporter == teleporter
        local sprite = "virtual-signal/signal-" .. city.name:sub(1, 1)
        local distance = math.floor(Utils.positionDistance(teleporter.position, city.teleporter.position) / 32)
        local required_energy = requires_energy and math.min(Config.TP_ENERGY_PER_CHUNK * distance, Config.TP_MAX_ENERGY) or 0
        local required_energy_watts = format_number(required_energy * 60, true)
        local available_energy = format_number(teleporter.energy * 60, true)
        local enabled = not is_current_city -- and teleporter.energy >= required_energy
        local tooltip = { "coe-teleporter-gui.target-tooltip", city.full_name, required_energy_watts, available_energy }

        ---@type coe.TeleporterGUI.cityTags
        local tags = {
          city_name         = city.name,
          current_city_name = teleporter.city.name,
          required_energy   = required_energy,
          required_energy_watts = required_energy_watts,
          full_name         = city.full_name,
          enabled_sprite = sprite
        }

        button_table.add {
          type    = "sprite-button",
          tooltip = tooltip,
          sprite  = (is_current_city and CURRENT_CITY_SPRITE) or (enabled and sprite) or 'coe_empty_sprite',
          style   = "slot_button",
          tags    = tags,
          enabled = enabled
        }
      else
        if city and city.teleporter then
          button_table.add(HIDDEN_CITY_BUTTON)
        else
          button_table.add(EMPTY_SPRITE_BUTTON).style.size = 32
        end
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
  return main_frame.add {
    type = "label",
    caption = "Current City: " .. city.full_name,
  }
end

-------------------------------------------------------------------------------

---@param event EventData.on_gui_opened
local function create_main_frame(event)
  local power_required = settings.global.coe_teleporters_require_power.value
  local player = game.get_player(event.player_index)
  local screen = destroy_teleporter_gui(player)

  if power_required and event.entity and event.entity.energy <= 0 then
    player.opened = defines.gui_type.none
    player.create_local_flying_text {
      color = { r = 1, g = 0, b = 0 },
      text = { "coe-teleporter-gui.no-power" },
      position = event.entity.position,
    }
    return
  end

  local pdata = global.players[event.player_index]

  local main_frame = screen.add {
    type = "frame",
    name = MAIN_FRAME_NAME,
    direction = "vertical",
  }
  main_frame.auto_center = true

  -- Header flow
  local header_flow = main_frame.add {
    type = "flow",
    direction = "horizontal",
  }.add {
    type = "label",
    style = "frame_title",
    ignored_by_interaction = true,
    caption = { "coe-teleporter-gui.title" }
  }.parent.add {
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
  return main_frame
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
  return true
end

-------------------------------------------------------------------------------

---@param event EventData.on_gui_click
function TeleporterGUI.onGuiClick(event)
  local player = game.get_player(event.player_index)
  if event.element.name == "coe_teleporter_gui_close" then
    return destroy_teleporter_gui(player)
  elseif event.element.tags then
    local tags = event.element.tags --[[@as coe.TeleporterGUI.cityTags]]
    local target_city = global.world.cities[tags.city_name]
    if not target_city then return end

    local current_city = global.world.cities[tags.current_city_name] or {}
    if not settings.global.coe_teleporting_enabled.value then
      player.play_sound { path = "utility/cannot_build", volume_modifier = 0.5 }
      player.create_local_flying_text {
        color = { r = 1, g = 0, b = 0 },
        text = { "coe-teleporter-gui.teleporting-disabled" },
        position = player.position,
      }
      return destroy_teleporter_gui(player)
    end
    if current_city.teleporter.energy >= tags.required_energy then
      Teleporter.teleport(player, target_city, current_city.teleporter, tags.required_energy)
    else
      player.play_sound { path = "utility/cannot_build", volume_modifier = 0.5 }
      player.create_local_flying_text {
        color = { r = 1, g = 0, b = 0 },
        text = { "coe-teleporter-gui.not-enough-power" },
        position = player.position,
      }
    end
    return destroy_teleporter_gui(player)
  end
end

-------------------------------------------------------------------------------

function TeleporterGUI.onNthTick()
  for _, pdata in pairs(global.players) do
    local grid = pdata.grid
    if not grid then return end
    local player = game.get_player(pdata.index)
    local teleporter = pdata.current_teleporter
    if not (grid.valid and teleporter and teleporter.valid and player.can_reach_entity(teleporter)) then
      return destroy_teleporter_gui(player) and nil
    end

    local teleporter_city = global.teleporters[teleporter.unit_number].city
    local available_energy = format_number(teleporter.energy * 60, true)
    for _, button in pairs(pdata.grid.children) do
      local tags = button.tags --[[@as coe.TeleporterGUI.cityTags]]
      if tags and tags.required_energy then
        local is_current_city = teleporter_city.name == tags.city_name
        local enabled = not is_current_city -- and teleporter.energy >= tags.required_energy

        button.tooltip = { "coe-teleporter-gui.target-tooltip", tags.full_name, tags.required_energy_watts, available_energy }
        button.enabled = enabled
        button.sprite = (is_current_city and CURRENT_CITY_SPRITE) or (enabled and tags.enabled_sprite) or EMPTY_SPRITE

      end
    end
  end
end

-- =============================================================================

return TeleporterGUI

---@class coe.player
---@field grid LuaGuiElement?
---@field current_teleporter LuaEntity?

---@class coe.TeleporterGUI.cityTags
---@field city_name string
---@field current_city_name string?
---@field required_energy double?
---@field full_name string
---@field required_energy_watts string
---@field enabled_sprite string
