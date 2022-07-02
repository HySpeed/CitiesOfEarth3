-- styles.lua
-- =====
local styles = data.raw["gui-style"].default

styles["coe_tp_destinations_frame"] = {
  type = "frame_style",
  parent = "inside_shallow_frame_with_padding"
  -- TODO: increase vertical padding / spacing
}

styles["coe_tp_controls_flow"] = { type = "horizontal_flow_style", vertical_align = "center", horizontal_spacing = 16 }

styles["coe_titlebar_drag_handle"] = {
  type = "empty_widget_style",
  parent = "draggable_space",
  left_margin = 4,
  right_margin = 4,
  height = 24,
  horizontally_stretchable = "on"
}
