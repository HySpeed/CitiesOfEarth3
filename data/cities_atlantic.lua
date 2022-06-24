-- Cities_Atlantic
-- These are the choices in the mod settings panel before starting the game.
--- @type coe.City
local cities_atlantic = {
  ["Europe, Czech Republic, Prague"]            = { name = "Prague", position = { x = 4100, y =   800 }, map_grid = { x = 13, y =  4 } }, -- tp:      0,     0
  ["Europe, United Kingdom, London"]            = { name = "London", position = { x = 3800, y =   800 }, map_grid = { x = 12, y =  4 } }, -- tp:   -600,     0
  ["Europe, Spain, Madrid"]                     = { name = "Madrid", position = { x = 3700, y =  1050 }, map_grid = { x = 11, y =  5 } }, -- tp:   -800,   500
  ["Europe, Ukraine, Kharkiv"]                  = { name = "Kharkiv", position = { x = 4600, y =   800 }, map_grid = { x = 15, y =  4 } }, -- tp:   1000,     0
  ["Europe, Russia, Kovdor"]                    = { name = "Kovdor", position = { x = 4450, y =   500 }, map_grid = { x = 14, y =  2 } }, -- tp:    700,  -600
  ["Europe, Russia, Munguy"]                    = { name = "Munguy", position = { x = 5600, y =   500 }, map_grid = { x = 17, y =  2 } }, -- tp:   3000,  -600
  ["Europe, Russia, Xeta"]                      = { name = "Xeta", position = { x = 6100, y =   300 }, map_grid = { x = 18, y =  1 } }, -- tp:   4000, -1000
  ["Europe, Russia, Yakutia"]                   = { name = "Yakutia", position = { x = 6600, y =   500 }, map_grid = { x = 19, y =  2 } }, -- tp:   5000,  -600
  ["Europe, Russia, Zyryanka"]                  = { name = "Zyryanka", position = { x = 7100, y =   500 }, map_grid = { x = 20, y =  2 } }, -- tp:   6000,  -600
  ["Asia, Kazakhstan, Aktobe"]                  = { name = "Aktobe", position = { x = 5100, y =   800 }, map_grid = { x = 16, y =  4 } }, -- tp:   2000,     0
  ["Asia, Kazakhstan, Semey"]                   = { name = "Semey", position = { x = 5600, y =   800 }, map_grid = { x = 17, y =  4 } }, -- tp:   3000,     0
  ["Asia, Mongolia, Moron"]                     = { name = "Moron", position = { x = 6100, y =   800 }, map_grid = { x = 18, y =  4 } }, -- tp:   4000,     0
  ["Asia, China, Songling"]                     = { name = "Songling", position = { x = 6600, y =   800 }, map_grid = { x = 19, y =  4 } }, -- tp:   5000,     0
  ["Asia, China, Nanchang"]                     = { name = "Nanchang", position = { x = 6400, y =  1300 }, map_grid = { x = 19, y =  6 } }, -- tp:   4600,  1000
  ["Asia, China, Chengdu"]                      = { name = "Chengdu", position = { x = 6100, y =  1300 }, map_grid = { x = 18, y =  6 } }, -- tp:   4000,  1000
  ["Asia, Iran, Bam"]                           = { name = "Bam", position = { x = 5100, y =  1300 }, map_grid = { x = 16, y =  6 } }, -- tp:   2000,  1000
  ["Asia, India, Delhi"]                        = { name = "Delhi", position = { x = 5600, y =  1300 }, map_grid = { x = 17, y =  6 } }, -- tp:   3000,  1000
  ["Asia, India, Hampi"]                        = { name = "Hampi", position = { x = 5500, y =  1600 }, map_grid = { x = 17, y =  8 } }, -- tp:   2800,  1600
  ["Asia, Thailand, Bangkok"]                   = { name = "Bangkok", position = { x = 6050, y =  1600 }, map_grid = { x = 18, y =  8 } }, -- tp:   3900,  1600
  ["Arabia, Saudi Arabia, Tabuk"]               = { name = "Tabuk", position = { x = 4600, y =  1300 }, map_grid = { x = 15, y =  6 } }, -- tp:   1000,  1000
  ["Africa, Morocco, Akka"]                     = { name = "Akka", position = { x = 3600, y =  1300 }, map_grid = { x = 12, y =  6 } }, -- tp:  -1000,  1000
  ["Africa, North Africa, Waddan"]              = { name = "Waddan", position = { x = 4100, y =  1300 }, map_grid = { x = 13, y =  6 } }, -- tp:      0,  1000
  ["Africa, Mali, Bamako"]                      = { name = "Bamako", position = { x = 3600, y =  1675 }, map_grid = { x = 12, y =  8 } }, -- tp:  -1000,  1750
  ["Africa, Chad, Mongo"]                       = { name = "Mongo", position = { x = 4100, y =  1675 }, map_grid = { x = 13, y =  8 } }, -- tp:      0,  1750
  ["Africa, Ethiopia, Dangila"]                 = { name = "Dangila", position = { x = 4600, y =  1675 }, map_grid = { x = 15, y =  8 } }, -- tp:   1000,  1750
  ["Africa, Angola, Huambo"]                    = { name = "Huambo", position = { x = 4175, y =  2100 }, map_grid = { x = 13, y =  9 } }, -- tp:    150,  2600
  ["Africa, Tanzania, Songea"]                  = { name = "Songea", position = { x = 4600, y =  2100 }, map_grid = { x = 15, y =  9 } }, -- tp:   1000,  2600
  ["Africa, South Africa, Johannesburg"]        = { name = "Johannesburg", position = { x = 4400, y =  2500 }, map_grid = { x = 14, y = 10 } }, -- tp:    600,  3400
  ["Oceania, Australia, Newman"]                = { name = "Newman", position = { x = 6450, y =  2500 }, map_grid = { x = 19, y = 10 } }, -- tp:   4700,  3400
  ["Oceania, Australia, Griffith"]              = { name = "Griffith", position = { x = 7100, y =  2600 }, map_grid = { x = 20, y = 10 } }, -- tp:   6000,  3800
  -- from Pacific: x - 4350 (tp x not adjusted)
  ["North America, Greenland, Qaanaaq"]         = { name = "Qaanaaq", position = { x = 2550, y =   200 }, map_grid = { x =  7, y =  1 } }, -- tp:  ?, -1200
  ["North America, Greenland, Uranienborg"]     = { name = "Uranienborg", position = { x = 3150, y =   200 }, map_grid = { x =  9, y =  1 } }, -- tp:  ?, -1200
  ["North America, Greenland, Summit Camp"]     = { name = "Summit Camp", position = { x = 2800, y =   450 }, map_grid = { x =  8, y =  2 } }, -- tp:  ?,  -700
  ["North America, Canada, Ellesmere Island"]   = { name = "Ellesmere Island", position = { x = 1950, y =   200 }, map_grid = { x =  5, y =  1 } }, -- tp:  ?, -1200
  ["North America, Canada, Fort Liard"]         = { name = "Fort Liard", position = { x =  900, y =   500 }, map_grid = { x =  2, y =  2 } }, -- tp:  ?,  -600
  ["North America, Canada, Yellowknife"]        = { name = "Yellowknife", position = { x = 1450, y =   475 }, map_grid = { x =  3, y =  2 } }, -- tp:  ?,  -600
  ["North America, Canada, Mid Baffin"]         = { name = "Mid Baffin", position = { x = 2150, y =   400 }, map_grid = { x =  6, y =  2 } }, -- tp:  ?,  -800
  ["North America, Canada, Okak"]               = { name = "Okak", position = { x = 2350, y =   675 }, map_grid = { x =  7, y =  3 } }, -- tp:  ?,  -250
  ["North America, Canada, Saskatoon"]          = { name = "Saskatoon", position = { x = 1400, y =   775 }, map_grid = { x =  3, y =  4 } }, -- tp:  ?,     0
  ["North America, Canada, Hearst"]             = { name = "Hearst", position = { x = 1950, y =   800 }, map_grid = { x =  5, y =  4 } }, -- tp:  ?,     0
  ["North America, United States, Hughes"]      = { name = "Hughes", position = { x =  300, y =   500 }, map_grid = { x =  1, y =  2 } }, -- tp:  ?,  -600
  ["North America, United States, Boise"]       = { name = "Boise", position = { x = 1200, y =  1000 }, map_grid = { x =  2, y =  5 } }, -- tp:  ?,   400
  ["North America, United States, Des Moines"]  = { name = "Des Moines", position = { x = 1675, y =  1000 }, map_grid = { x =  4, y =  5 } }, -- tp:  ?,   400
  ["North America, United States, Albany"]      = { name = "Albany", position = { x = 2125, y =  1000 }, map_grid = { x =  6, y =  5 } }, -- tp:  ?,   400
  ["North America, United States, El Paso"]     = { name = "El Paso", position = { x = 1350, y =  1200 }, map_grid = { x =  3, y =  6 } }, -- tp:  ?,   800
  ["North America, United States, Montgomery"]  = { name = "Montgomery", position = { x = 1900, y =  1200 }, map_grid = { x =  5, y =  6 } }, -- tp:  ?,   800
  ["Central America, Mexico, Mexico City"]      = { name = "Mexico City", position = { x = 1550, y =  1500 }, map_grid = { x =  3, y =  7 } }, -- tp:  ?,  1400
  ["South America, Peru, Iquitos"]              = { name = "Iquitos", position = { x = 2200, y =  2000 }, map_grid = { x =  5, y =  8 } }, -- tp:  ?,  2400
  ["South America, Brazil, Palmas"]             = { name = "Palmas", position = { x = 2750, y =  2150 }, map_grid = { x =  7, y =  9 } }, -- tp:  ?,  2700
  ["South America, Argentina, Cordoba"]         = { name = "Cordoba", position = { x = 2350, y =  2600 }, map_grid = { x =  6, y = 10 } }  -- tp:  ?,  3600
}
return cities_atlantic
