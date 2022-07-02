local Config = require("config")

if not Config.DEV_MODE then return end

data:extend{
  { type = "custom-input", name = "coe-reload-mods", key_sequence = "SHIFT + PAGEDOWN", localised_name = "Reload Mods" },
  { type = "custom-input", name = "coe-run-function", key_sequence = "SHIFT + PAGEUP", localised_name = "Run Function" }
}

if mods["debugadapter"] then
  data:extend{ { type = "custom-input", name = "coe-trigger-breakpoint", key_sequence = "CONTROL + SHIFT + END", localised_name = "Trigger Breakpoint" } }
end
