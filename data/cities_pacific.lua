-- Cities_Pacific
-- These are the choices in the mod settings panel before starting the game.
--- @type coe.City
local cities_pacific = {
  ["Europe, Czech Republic, Prague"]            = { name = "Prague", position = { x =  700, y =   800 }, map_grid = { x =  3, y =  4 } }, -- tp:      0,     0
  ["Europe, United Kingdom, London"]            = { name = "London", position = { x =  400, y =   800 }, map_grid = { x =  2, y =  4 } }, -- tp:   -600,     0
  ["Europe, Spain, Madrid"]                     = { name = "Madrid", position = { x =  300, y =  1050 }, map_grid = { x =  1, y =  5 } }, -- tp:   -800,   500
  ["Europe, Ukraine, Kharkiv"]                  = { name = "Kharkiv", position = { x = 1200, y =   800 }, map_grid = { x =  5, y =  4 } }, -- tp:   1000,     0
  ["Europe, Russia, Kovdor"]                    = { name = "Kovdor", position = { x = 1050, y =   500 }, map_grid = { x =  4, y =  2 } }, -- tp:    700,  -600
  ["Europe, Russia, Munguy"]                    = { name = "Munguy", position = { x = 2200, y =   500 }, map_grid = { x =  7, y =  2 } }, -- tp:   3000,  -600
  ["Europe, Russia, Xeta"]                      = { name = "Xeta", position = { x = 2700, y =   300 }, map_grid = { x =  8, y =  1 } }, -- tp:   4000, -1000
  ["Europe, Russia, Yakutia"]                   = { name = "Yakutia", position = { x = 3200, y =   500 }, map_grid = { x =  9, y =  2 } }, -- tp:   5000,  -600
  ["Europe, Russia, Zyryanka"]                  = { name = "Zyryanka", position = { x = 3700, y =   500 }, map_grid = { x = 10, y =  2 } }, -- tp:   6000,  -600
  ["Asia, Kazakhstan, Aktobe"]                  = { name = "Aktobe", position = { x = 1700, y =   800 }, map_grid = { x =  6, y =  4 } }, -- tp:   2000,     0
  ["Asia, Kazakhstan, Semey"]                   = { name = "Semey", position = { x = 2200, y =   800 }, map_grid = { x =  7, y =  4 } }, -- tp:   3000,     0
  ["Asia, Mongolia, Moron"]                     = { name = "Moron", position = { x = 2700, y =   800 }, map_grid = { x =  8, y =  4 } }, -- tp:   4000,     0
  ["Asia, China, Songling"]                     = { name = "Songling", position = { x = 3200, y =   800 }, map_grid = { x =  9, y =  4 } }, -- tp:   5000,     0
  ["Asia, China, Nanchang"]                     = { name = "Nanchang", position = { x = 3000, y =  1300 }, map_grid = { x =  9, y =  6 } }, -- tp:   4600,  1000
  ["Asia, China, Chengdu"]                      = { name = "Chengdu", position = { x = 2700, y =  1300 }, map_grid = { x =  8, y =  6 } }, -- tp:   4000,  1000
  ["Asia, Iran, Bam"]                           = { name = "Bam", position = { x = 1700, y =  1300 }, map_grid = { x =  6, y =  6 } }, -- tp:   2000,  1000
  ["Asia, India, Delhi"]                        = { name = "Delhi", position = { x = 2200, y =  1300 }, map_grid = { x =  7, y =  6 } }, -- tp:   3000,  1000
  ["Asia, India, Hampi"]                        = { name = "Hampi", position = { x = 2100, y =  1600 }, map_grid = { x =  7, y =  8 } }, -- tp:   2800,  1600
  ["Asia, Thailand, Bangkok"]                   = { name = "Bangkok", position = { x = 2650, y =  1600 }, map_grid = { x =  8, y =  8 } }, -- tp:   3900,  1600
  ["Arabia, Saudi Arabia, Tabuk"]               = { name = "Tabuk", position = { x = 1200, y =  1300 }, map_grid = { x =  5, y =  7 } }, -- tp:   1000,  1000
  ["Africa, Morocco, Akka"]                     = { name = "Akka", position = { x =  200, y =  1300 }, map_grid = { x =  2, y =  6 } }, -- tp:  -1000,  1000
  ["Africa, North Africa, Waddan"]              = { name = "Waddan", position = { x =  700, y =  1300 }, map_grid = { x =  3, y =  7 } }, -- tp:      0,  1000
  ["Africa, Mali, Bamako"]                      = { name = "Bamako", position = { x =  200, y =  1675 }, map_grid = { x =  2, y =  8 } }, -- tp:  -1000,  1750
  ["Africa, Chad, Mongo"]                       = { name = "Mongo", position = { x =  700, y =  1675 }, map_grid = { x =  3, y =  8 } }, -- tp:      0,  1750
  ["Africa, Ethiopia, Dangila"]                 = { name = "Dangila", position = { x = 1200, y =  1675 }, map_grid = { x =  5, y =  8 } }, -- tp:   1000,  1750
  ["Africa, Angola, Huambo"]                    = { name = "Huambo", position = { x =  775, y =  2100 }, map_grid = { x =  3, y =  9 } }, -- tp:    150,  2600
  ["Africa, Tanzania, Songea"]                  = { name = "Songea", position = { x = 1200, y =  2100 }, map_grid = { x =  5, y =  9 } }, -- tp:   1000,  2600
  ["Africa, South Africa, Johannesburg"]        = { name = "Johannesburg", position = { x = 1000, y =  2500 }, map_grid = { x =  4, y = 10 } }, -- tp:    600,  3400
  ["Oceania, Australia, Newman"]                = { name = "Newman", position = { x = 3050, y =  2500 }, map_grid = { x =  9, y = 10 } }, -- tp:   4700,  3400
  ["Oceania, Australia, Griffith"]              = { name = "Griffith", position = { x = 3700, y =  2600 }, map_grid = { x = 10, y = 10 } }, -- tp:   6000,  3800
  ["North America, Greenland, Qaanaaq"]         = { name = "Qaanaaq", position = { x = 7000, y =   200 }, map_grid = { x = 18, y =  1 } }, -- tp:  12600, -1200
  ["North America, Greenland, Uranienborg"]     = { name = "Uranienborg", position = { x = 7600, y =   200 }, map_grid = { x = 20, y =  1 } }, -- tp:  13800, -1200
  ["North America, Greenland, Summit Camp"]     = { name = "Summit Camp", position = { x = 7250, y =   450 }, map_grid = { x = 19, y =  2 } }, -- tp:  13100,  -700
  ["North America, Canada, Ellesmere Island"]   = { name = "Ellesmere Island", position = { x = 6400, y =   200 }, map_grid = { x = 16, y =  1 } }, -- tp:  11400, -1200
  ["North America, Canada, Fort Liard"]         = { name = "Fort Liard", position = { x = 5350, y =   500 }, map_grid = { x = 13, y =  2 } }, -- tp:   9300,  -600
  ["North America, Canada, Yellowknife"]        = { name = "Yellowknife", position = { x = 5900, y =   475 }, map_grid = { x = 14, y =  2 } }, -- tp:  10400,  -600
  ["North America, Canada, Mid Baffin"]         = { name = "Mid Baffin", position = { x = 6600, y =   400 }, map_grid = { x = 17, y =  2 } }, -- tp:  11800,  -800
  ["North America, Canada, Okak"]               = { name = "Okak", position = { x = 6800, y =   675 }, map_grid = { x = 18, y =  3 } }, -- tp:  12200,  -250
  ["North America, Canada, Saskatoon"]          = { name = "Saskatoon", position = { x = 5850, y =   775 }, map_grid = { x = 14, y =  4 } }, -- tp:  10400,     0
  ["North America, Canada, Hearst"]             = { name = "Hearst", position = { x = 6400, y =   800 }, map_grid = { x = 16, y =  4 } }, -- tp:  11400,     0
  ["North America, United States, Hughes"]      = { name = "Hughes", position = { x = 4750, y =   500 }, map_grid = { x = 12, y =  2 } }, -- tp:   8100,  -600
  ["North America, United States, Boise"]       = { name = "Boise", position = { x = 5650, y =  1000 }, map_grid = { x = 13, y =  5 } }, -- tp:   9900,   400
  ["North America, United States, Des Moines"]  = { name = "Des Moines", position = { x = 6125, y =  1000 }, map_grid = { x = 15, y =  5 } }, -- tp:  10850,   400
  ["North America, United States, Albany"]      = { name = "Albany", position = { x = 6575, y =  1000 }, map_grid = { x = 17, y =  5 } }, -- tp:  11750,   400
  ["North America, United States, El Paso"]     = { name = "El Paso", position = { x = 5800, y =  1200 }, map_grid = { x = 14, y =  6 } }, -- tp:  10200,   800
  ["North America, United States, Montgomery"]  = { name = "Montgomery", position = { x = 6300, y =  1200 }, map_grid = { x = 16, y =  6 } }, -- tp:  11200,   800
  ["Central America, Mexico, Mexico City"]      = { name = "Mexico City", position = { x = 6000, y =  1500 }, map_grid = { x = 14, y =  7 } }, -- tp:  10600,  1400
  ["South America, Peru, Iquitos"]              = { name = "Iquitos", position = { x = 6650, y =  2000 }, map_grid = { x = 16, y =  8 } }, -- tp:  11900,  2400
  ["South America, Brazil, Palmas"]             = { name = "Palmas", position = { x = 7200, y =  2150 }, map_grid = { x = 18, y =  9 } }, -- tp:  13000,  2700
  ["South America, Argentina, Cordoba"]         = { name = "Cordoba", position = { x = 6800, y =  2600 }, map_grid = { x = 17, y = 10 } }  -- tp:  12200,  3600
}
return cities_pacific
