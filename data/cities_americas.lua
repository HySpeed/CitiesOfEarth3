-- Cities Americas
-- These are the choices in the mod settings panel before starting the game.


--- @type coe.City
-- [[
local cities_americas = {
  ["Central America, Mexico, Mexico City"]      = { gui_grid ={ x =  8, y =  7 }, position = { x =  -213, y =  -107 } },
  ["North America, Canada, Ellesmere Island"]   = { gui_grid ={ x = 11, y =  1 }, position = { x =   212, y = -1407 } },
  ["North America, Canada, Fort Liard"]         = { gui_grid ={ x =  7, y =  2 }, position = { x =  -863, y = -1107 } },
  ["North America, Canada, Hearst"]             = { gui_grid ={ x = 10, y =  4 }, position = { x =   187, y =  -782 } },
  ["North America, Canada, Mid Baffin"]         = { gui_grid ={ x = 11, y =  2 }, position = { x =   387, y = -1207 } },
  ["North America, Canada, Okak"]               = { gui_grid ={ x = 12, y =  3 }, position = { x =   587, y =  -932 } },
  ["North America, Canada, Saskatoon"]          = { gui_grid ={ x =  8, y =  4 }, position = { x =  -313, y =  -782 } },
  ["North America, Canada, Yellowknife"]        = { gui_grid ={ x =  8, y =  2 }, position = { x =  -313, y = -1107 } },
  ["North America, Greenland, Qaanaaq"]         = { gui_grid ={ x = 12, y =  1 }, position = { x =   787, y = -1407 } },
  ["North America, Greenland, Summit Camp"]     = { gui_grid ={ x = 13, y =  2 }, position = { x =  1037, y = -1157 } },
  ["North America, Greenland, Uranienborg"]     = { gui_grid ={ x = 14, y =  1 }, position = { x =  1387, y = -1407 } },
  ["North America, United States, Albany"]      = { gui_grid ={ x = 11, y =  5 }, position = { x =   362, y =  -607 } },
  ["North America, United States, Boise"]       = { gui_grid ={ x =  7, y =  5 }, position = { x =  -563, y =  -607 } },
  ["North America, United States, Minneapolis"] = { gui_grid ={ x =  9, y =  5 }, position = { x =   -88, y =  -607 } },
  ["North America, United States, El Paso"]     = { gui_grid ={ x =  8, y =  6 }, position = { x =  -413, y =  -407 } },
  ["North America, United States, Hughes"]      = { gui_grid ={ x =  6, y =  2 }, position = { x = -1463, y = -1107 } },
  ["North America, United States, Montgomery"]  = { gui_grid ={ x = 10, y =  6 }, position = { x =    87, y =  -407 } },
  ["South America, Argentina, Cordoba"]         = { gui_grid ={ x = 11, y = 10 }, position = { x =   587, y =  1018 } },
  ["South America, Brazil, Palmas"]             = { gui_grid ={ x = 12, y =  9 }, position = { x =   987, y =   543 } },
  ["South America, Peru, Iquitos"]              = { gui_grid ={ x = 10, y =  8 }, position = { x =   437, y =   393 } }
}
--]]

--[[
-- Dev mode: limited cities
local cities_americas = {
  -- ["North America, United States, Albany"]      = { gui_grid ={ x = 11, y =  5 }, position = { x =   362, y =  -607 } },
  ["North America, United States, Boise"]       = { gui_grid ={ x =  7, y =  5 }, position = { x =  -563, y =  -607 } },
  ["North America, United States, Minneapolis"] = { gui_grid ={ x =  9, y =  5 }, position = { x =   -88, y =  -607 } },
  ["North America, United States, El Paso"]     = { gui_grid ={ x =  8, y =  6 }, position = { x =  -413, y =  -407 } },
  -- ["North America, United States, Montgomery"]  = { gui_grid ={ x = 10, y =  6 }, position = { x =    87, y =  -407 } }
}
--]]

--[[
-- Dev mode: limited cities
local cities_americas = {
  ["North America, United States, Boise"]       = { gui_grid ={ x =  7, y =  5 }, position = { x =  -563, y =  -607 } },
  ["North America, United States, Minneapolis"] = { gui_grid ={ x =  9, y =  5 }, position = { x =   -88, y =  -607 } },
  ["North America, United States, El Paso"]     = { gui_grid ={ x =  8, y =  6 }, position = { x =  -413, y =  -407 } }
}
--]]

return cities_americas
