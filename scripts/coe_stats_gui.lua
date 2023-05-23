---@class coe.StatsGUI
local StatsGUI = {}

local mod_gui = require("mod-gui")
local Config = require("config")
local Utils = require("utils/utils")

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
    caption = { "coe-stats-gui.label_launches_remaining", Utils.calculateRemainingLaunches() }
  }.parent.parent.add {
    type = "flow",
    direction = "horizontal"
  }.add {
    type = "label",
    caption = { "coe-stats-gui.label_launches_total", Utils.calculateTotalLaunches() }
  }

  if global.settings.startup.coe_pre_place_silo.value == Config.ALL then
    local sprite_check = "virtual-signal/signal-check"
    local sprite_dot = "virtual-signal/signal-dot"

    statistics_frame.add {
      type = "label",
      caption = "------"
    }

    local cities_table = statistics_frame.add( { type = "table", name = "coe-stats-gui.cities_table", column_count = 3 })
    local non_team_sprite = sprite_dot
    local non_team_tooltip = "join this team"
    local current_team_sprite = sprite_check
    local current_team_tooltip = "your current team"
    local player = game.players[statistics_frame.player_index]

    for index = 1,  #global.world.city_names do
      local city = global.world.cities[global.world.city_names[index]]
      local launch_count = city.rocket_silo.launches_this_silo
      if city.rocket_silo and launch_count then
        local sprite = non_team_sprite
        local tooltip = non_team_tooltip

        if player.force.name == city.name then
          sprite = current_team_sprite
          tooltip = current_team_tooltip
        end
        if Utils.getStartupSetting( "coe_team_coop" ) then
          cities_table.add({
            name    = "coe_team_" .. city.name,
            type    = "sprite-button",
            sprite  = sprite,
            tooltip = tooltip,
            tags = {city_name = city.name}
          })
        else
          cities_table.add({
            type    = "label",
            caption = " "
          })
        end
        cities_table.add({
          type = "label",
          caption = city.name
        })
        cities_table.add({
          type = "label",
          caption = tostring( launch_count )
        })
      end
    end

  end

  return statistics_frame
end

-------------------------------------------------------------------------------

---@param player LuaPlayer
local function open_stats_ui( player )
  local gui = mod_gui.get_frame_flow( player ) --[[@as LuaGuiElement]]
  local statistics_frame = gui.add {
    type = "frame",
    name = "coe_statistics_frame",
    direction = "vertical",
    caption = { "coe-stats-gui.label_stats_title" },
    style = mod_gui.frame_style
  }

  return build_stats_info_frame(statistics_frame)
end

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
end

-------------------------------------------------------------------------------

-- Generate City Tags for the team
-- Bug: requires two events (clicks) for tags to be created
local function createTags( player )
  for _, city in pairs( global.world.cities ) do
    -- if tag doesn't exist nearby, create it.
    local tag_search = player.force.find_chart_tags( player.surface, Utils.positionToChunkArea( city.position ) )
    if not next( tag_search ) then
      local tag = { icon = { type = "virtual", name = "signal-info" }, position = city.position, text = "     " .. city.name }
      -- player.force.chart( player.surface, Utils.positionToChunkTileArea( city.position ) )
      -- player.force.rechart( player.surface )
      player.force.add_chart_tag( player.surface, tag )
    end
  end
end

-------------------------------------------------------------------------------

---@param event EventData.on_gui_click
function StatsGUI.onGuiClick(event)
  local player = game.get_player(event.player_index)
  if event.element.name == "coe_button_statistics" then
    local frame_flow = mod_gui.get_frame_flow( player ) --[[@as LuaGuiElement]]
    if frame_flow.coe_statistics_frame then
      return frame_flow.coe_statistics_frame.destroy() and true
    end
    return open_stats_ui( player )
  elseif string.sub( event.element.name, 1, 9 ) == "coe_team_" then
    local tags = event.element.tags
      player.force = game.forces[tags.city_name]
      createTags( player, tags )
    local frame_flow = mod_gui.get_frame_flow( player ) --[[@as LuaGuiElement]]
    return frame_flow.coe_statistics_frame.destroy() and true
  end
end

-- =============================================================================

return StatsGUI
