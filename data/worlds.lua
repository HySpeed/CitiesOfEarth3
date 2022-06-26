---@alias coe.Cities {[string]: coe.City}
---@alias coe.Worlds {[string]: coe.World}

---@class coe.World
---@field data string[]
---@field cities coe.Cities
---@field settings coe.World.Settings
---@field city_names string[]

---@class coe.World.Settings
---@field spawn string
---@field silo string

---@class coe.City
---@field name string
---@field fullname string
---@field position MapPosition
---@field map_grid ChunkPosition
---@field generated boolean

if __DebugAdapter and __DebugAdapter.dumpIgnore then
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_atlantic")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_pacific")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_olde_world")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_americas")
end

local Config = require("config")
local Util = require("scripts.coe_utils")

local debug_ignore = { __debugline = "Compressed Map Data", __debugchildren = false }

--- @type {[string]: coe.World}
local Worlds = {
  ["Earth - Atlantic"] = {
    data = setmetatable(require("data/world_atlantic"), debug_ignore),
    cities = require("data/cities_atlantic"),
    settings = { spawn = "coe_spawn_city_atlantic", silo = "coe_silo_city_atlantic" }
  },
  ["Earth - Pacific"] = {
    data = setmetatable(require("data/world_pacific"), debug_ignore),
    cities = require("data/cities_pacific"),
    settings = { spawn = "coe_spawn_city_pacific", silo = "coe_silo_city_pacific" }
  },
  ["Earth - Olde World"] = {
    data = setmetatable(require("data/world_olde_world"), debug_ignore),
    cities = require("data/cities_olde_world"),
    settings = { spawn = "coe_spawn_city_olde_world", silo = "coe_silo_city_olde_world" }
  },
  ["Earth - Americas"] = {
    data = setmetatable(require("data/world_americas"), debug_ignore),
    cities = require("data/cities_americas"),
    settings = { spawn = "coe_spawn_city_americas", silo = "coe_silo_city_americas" }
  }
}

--- Crete a list of city_names for settings
--- Add name and full name to the cities
for _, world in pairs(Worlds) do
  world.city_names = { Config.RANDOM_CITY }
  for fullname, city in pairs(world.cities) do
    table.insert(world.city_names, fullname)
    city.fullname = fullname
    city.name = Util.parseCityName(fullname)
  end
end

return Worlds
