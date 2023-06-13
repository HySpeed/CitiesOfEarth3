---@alias coe.Worlds {[string]: coe.World}
---@alias coe.Cities {[string]: coe.City}
---@alias coe.City coe.city

---@class coe.World
---@field data string[]
---@field cities coe.Cities
---@field settings coe.World.Settings
---@field city_names string[]

---@class coe.World.Settings
---@field spawn string
---@field silo string

if __DebugAdapter and __DebugAdapter.dumpIgnore then
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_atlantic.lua")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_pacific.lua")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_olde_world.lua")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_americas.lua")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_africa.lua")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_europe.lua")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_oceania.lua")
  __DebugAdapter.dumpIgnore("@__CitiesOfEarth3__/data/world_united_states.lua")
end

local Config = require("config")
local Utils = require("utils/utils")

local debug_ignore = { __debugline = "Compressed Map Data", __debugchildren = false }

--- @type {[string]: coe.World}
local Worlds = {
  ["Earth - Africa"] = {
    data = setmetatable(require("data/world_africa"), debug_ignore),
    cities = require("data/cities_africa"),
    settings = { spawn = "coe_spawn_city_africa", silo = "coe_silo_city_africa" }
  },
  ["Earth - Americas"] = {
    data = setmetatable(require("data/world_americas"), debug_ignore),
    cities = require("data/cities_americas"),
    settings = { spawn = "coe_spawn_city_americas", silo = "coe_silo_city_americas" }
  },
  ["Earth - Atlantic"] = {
    data = setmetatable(require("data/world_atlantic"), debug_ignore),
    cities = require("data/cities_atlantic"),
    settings = { spawn = "coe_spawn_city_atlantic", silo = "coe_silo_city_atlantic" }
  },
  ["Earth - Europe"] = {
    data = setmetatable(require("data/world_europe"), debug_ignore),
    cities = require("data/cities_europe"),
    settings = { spawn = "coe_spawn_city_europe", silo = "coe_silo_city_europe" }
  },
  ["Earth - Oceania"] = {
    data = setmetatable(require("data/world_oceania"), debug_ignore),
    cities = require("data/cities_oceania"),
    settings = { spawn = "coe_spawn_city_oceania", silo = "coe_silo_city_oceania" }
  },
  ["Earth - Olde World"] = {
    data = setmetatable(require("data/world_olde_world"), debug_ignore),
    cities = require("data/cities_olde_world"),
    settings = { spawn = "coe_spawn_city_olde_world", silo = "coe_silo_city_olde_world" }
  },
  ["Earth - Pacific"] = {
    data = setmetatable(require("data/world_pacific"), debug_ignore),
    cities = require("data/cities_pacific"),
    settings = { spawn = "coe_spawn_city_pacific", silo = "coe_silo_city_pacific" }
  },
  ["Earth - United States"] = {
    data = setmetatable(require("data/world_united_states"), debug_ignore),
    cities = require("data/cities_united_states"),
    settings = { spawn = "coe_spawn_city_united_states", silo = "coe_silo_city_united_states" }
  }
}

--- Crete a list of city_names for settings
--- Add name and full name to the cities
for _, world in pairs( Worlds ) do
  world.city_names = { Config.RANDOM_CITY }
  for full_name, city in pairs( world.cities ) do
    table.insert( world.city_names, full_name )
    city.full_name = full_name
    city.name = Utils.parseCityName( full_name )
  end
end

return Worlds
