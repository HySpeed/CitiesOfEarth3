-- Cities United States
-- These are the choices in the mod settings panel before starting the game.
-- https://www.worldatlas.com/maps/united-states / https://mapcarta.com/United_States_of_America


--- @type coe.City
-- [[
local cities_united_states = {
  ["United States, Alabama, Montgomery"]       = { gui_grid ={ x = 11, y =  9 }, position = { x =   250, y =   100 } },
  ["United States, Arizona, Phoenix"]          = { gui_grid ={ x =  5, y =  8 }, position = { x =  -333, y =    80 } },
  ["United States, Arkansas, Little Rock"]     = { gui_grid ={ x =  9, y =  8 }, position = { x =   133, y =    68 } },
  ["United States, California, Sacramento"]    = { gui_grid ={ x =  2, y =  5 }, position = { x =  -540, y =   -36 } },
  ["United States, Colorado, Denver"]          = { gui_grid ={ x =  6, y =  5 }, position = { x =  -188, y =   -57 } },
  ["United States, Connecticut, Hartford"]     = { gui_grid ={ x = 18, y =  4 }, position = { x =   550, y =  -108 } },
  ["United States, Delaware, Dover"]           = { gui_grid ={ x = 17, y =  6 }, position = { x =   492, y =   -44 } },
  ["United States, Florida, Tallahassee"]      = { gui_grid ={ x = 12, y = 10 }, position = { x =   292, y =   147 } },
  ["United States, Georgia, Atlanta"]          = { gui_grid ={ x = 12, y =  8 }, position = { x =   285, y =    65 } },
  ["United States, Idaho, Boise"]              = { gui_grid ={ x =  4, y =  3 }, position = { x =  -417, y =  -136 } },
  ["United States, Illinois, Springfield"]     = { gui_grid ={ x = 10, y =  5 }, position = { x =   187, y =   -63 } },
  ["United States, Indiana, Indianapolis"]     = { gui_grid ={ x = 11, y =  5 }, position = { x =   256, y =   -61 } },
  ["United States, Iowa, Des Moines"]          = { gui_grid ={ x =  9, y =  4 }, position = { x =   108, y =  -100 } },
  ["United States, Kansas, Topeka"]            = { gui_grid ={ x =  8, y =  6 }, position = { x =    44, y =   -36 } },
  ["United States, Kentucky, Frankfort"]       = { gui_grid ={ x = 12, y =  5 }, position = { x =   270, y =   -30 } },
  ["United States, Louisiana, Baton Rouge"]    = { gui_grid ={ x =  9, y = 10 }, position = { x =   146, y =   147 } },
  ["United States, Maine, Augusta"]            = { gui_grid ={ x = 20, y =  2 }, position = { x =   612, y =  -164 } },
  ["United States, Maryland, Annapolis"]       = { gui_grid ={ x = 16, y =  6 }, position = { x =   460, y =   -45 } },
  ["United States, Massachusetts, Boston"]     = { gui_grid ={ x = 20, y =  4 }, position = { x =   589, y =  -123 } },
  ["United States, Michigan, Lansing"]         = { gui_grid ={ x = 12, y =  3 }, position = { x =   288, y =  -133 } },
  ["United States, Minnesota, Saint Paul"]     = { gui_grid ={ x =  9, y =  2 }, position = { x =   109, y =  -177 } },
  ["United States, Mississippi, Jackson"]      = { gui_grid ={ x =  9, y =  9 }, position = { x =   155, y =   100 } },
  ["United States, Missouri, Jefferson City"]  = { gui_grid ={ x =  9, y =  6 }, position = { x =   117, y =    -9 } },
  ["United States, Montana, Helena"]           = { gui_grid ={ x =  5, y =  1 }, position = { x =  -339, y =  -209 } },
  ["United States, Nebraska, Lincoln"]         = { gui_grid ={ x =  8, y =  5 }, position = { x =    16, y =   -57 } },
  ["United States, Nevada, Carson City"]       = { gui_grid ={ x =  3, y =  4 }, position = { x =  -496, y =   -72 } },
  ["United States, New Hampshire, Concord"]    = { gui_grid ={ x = 18, y =  3 }, position = { x =   570, y =  -143 } },
  ["United States, New Jersey, Trenton"]       = { gui_grid ={ x = 17, y =  5 }, position = { x =   503, y =   -74 } },
  ["United States, New Mexico, Santa Fe"]      = { gui_grid ={ x =  6, y =  7 }, position = { x =  -228, y =    35 } },
  ["United States, New York, Albany"]          = { gui_grid ={ x = 17, y =  3 }, position = { x =   529, y =  -134 } },
  ["United States, North Carolina, Raleigh"]   = { gui_grid ={ x = 14, y =  7 }, position = { x =   420, y =    21 } },
  ["United States, North Dakota, Bismarck"]    = { gui_grid ={ x =  7, y =  1 }, position = { x =   -77, y =  -214 } },
  ["United States, Ohio, Columbus"]            = { gui_grid ={ x = 13, y =  5 }, position = { x =   324, y =   -59 } },
  ["United States, Oklahoma, Oklahoma City"]   = { gui_grid ={ x =  8, y =  8 }, position = { x =   -12, y =    57 } },
  ["United States, Oregon, Salem"]             = { gui_grid ={ x =  1, y =  2 }, position = { x =  -585, y =  -175 } },
  ["United States, Pennsylvania, Harrisburg"]  = { gui_grid ={ x = 16, y =  5 }, position = { x =   466, y =   -74 } },
  ["United States, Rhode Island, Providence"]  = { gui_grid ={ x = 19, y =  4 }, position = { x =   583, y =  -111 } },
  ["United States, South Carolina, Columbia"]  = { gui_grid ={ x = 13, y =  8 }, position = { x =   362, y =    56 } },
  ["United States, South Dakota, Pierre"]      = { gui_grid ={ x =  7, y =  2 }, position = { x =   -70, y =  -165 } },
  ["United States, Tennessee, Nashville"]      = { gui_grid ={ x = 11, y =  7 }, position = { x =   237, y =    23 } },
  ["United States, Texas, Austin"]             = { gui_grid ={ x =  8, y = 10 }, position = { x =    -8, y =   152 } },
  ["United States, Utah, Salt Lake City"]      = { gui_grid ={ x =  5, y =  4 }, position = { x =  -328, y =   -84 } },
  ["United States, Vermont, Montpelier"]       = { gui_grid ={ x = 18, y =  2 }, position = { x =   558, y =  -166 } },
  ["United States, Virginia, Richmond"]        = { gui_grid ={ x = 15, y =  6 }, position = { x =   450, y =    -4 } },
  ["United States, Washington, Olympia"]       = { gui_grid ={ x =  1, y =  1 }, position = { x =  -575, y =  -225 } },
  ["United States, West Virginia, Charleston"] = { gui_grid ={ x = 13, y =  6 }, position = { x =   355, y =   -23 } },
  ["United States, Wisconsin, Madison"]        = { gui_grid ={ x = 10, y =  3 }, position = { x =   180, y =  -134 } },
  ["United States, Wyoming, Cheyenne"]         = { gui_grid ={ x =  6, y =  4 }, position = { x =  -172, y =   -93 } }
}
--]]

--[[
-- Dev mode: limited cities
local cities_united_states = {
["United States, Pennsylvania, Harrisburg"]  = { gui_grid ={ x = 16, y =  5 }, position = { x =   466, y =   -74 } },
  ["United States, Rhode Island, Providence"]  = { gui_grid ={ x = 19, y =  4 }, position = { x =   583, y =  -111 } },
  ["United States, South Carolina, Columbia"]  = { gui_grid ={ x = 13, y =  8 }, position = { x =   362, y =    56 } },
}
--]]

return cities_united_states
