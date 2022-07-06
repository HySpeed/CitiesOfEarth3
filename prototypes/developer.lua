if not settings.startup.coe_dev_mode and settings.startup.coe_dev_mode.value then return end

data:extend{
  { type = "custom-input", name = "coe-reload-mods", key_sequence = "SHIFT + PAGEDOWN", localised_name = "Reload Mods" },
  { type = "custom-input", name = "coe-run-function", key_sequence = "SHIFT + PAGEUP", localised_name = "Run Function" }
}
