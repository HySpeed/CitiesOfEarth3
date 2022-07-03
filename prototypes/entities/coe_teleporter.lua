-- coe_teleporter prototype entity
-- =============================================================================
local Config = require("config")
local ENTITY_PATH = "__CitiesOfEarth3__/graphics/entities/"

local coe_teleporter = util.table.deepcopy(data.raw["lab"]["lab"])
coe_teleporter.name = "coe_teleporter"
coe_teleporter.corpse = "big-remnants"
coe_teleporter.researching_speed = 0
coe_teleporter.inputs = {}
coe_teleporter.module_specification = nil
coe_teleporter.dying_explosion = "explosion"
coe_teleporter.energy_usage = Config.TP_MAX_ENERGY_STR
coe_teleporter.energy_source = {
  type = "electric",
  usage_priority = "secondary-input",
  input_flow_limit = "100kW" -- slow charge rate
}
coe_teleporter.off_animation = {
  layers = {
    {
      filename = ENTITY_PATH .. "market/market.png",
      width = 100,
      height = 110,
      scale = 1,
      hr_version = { filename = ENTITY_PATH .. "market/hr-market.png", width = 200, height = 220, scale = 0.5 }
    }
  }
}
coe_teleporter.on_animation = {
  layers = {
    {
      filename = ENTITY_PATH .. "market/market.png",
      width = 100,
      height = 110,
      scale = 1,
      hr_version = { filename = ENTITY_PATH .. "market/hr-market.png", width = 200, height = 220, scale = 0.5 }
    }
  }
}

data:extend({ coe_teleporter })
