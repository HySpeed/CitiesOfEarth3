-- Cities_Atlantic
-- These are the choices in the mod settings panel before starting the game.

local cities_atlantic = {
  ["Europe, Czech Republic, Prague"]            = { position = { x = 4100, y =   800 }, map_grid = { x = 13, y =  4 } }, -- tp:      0,     0
  ["Europe, United Kingdom, London"]            = { position = { x = 3800, y =   800 }, map_grid = { x = 12, y =  4 } }, -- tp:   -600,     0
  ["Europe, Spain, Madrid"]                     = { position = { x = 3700, y =  1050 }, map_grid = { x = 11, y =  5 } }, -- tp:   -800,   500
  ["Europe, Ukraine, Kharkiv"]                  = { position = { x = 4600, y =   800 }, map_grid = { x = 15, y =  4 } }, -- tp:   1000,     0
  ["Europe, Russia, Kovdor"]                    = { position = { x = 4450, y =   500 }, map_grid = { x = 14, y =  2 } }, -- tp:    700,  -600
  ["Europe, Russia, Munguy"]                    = { position = { x = 5600, y =   500 }, map_grid = { x = 17, y =  2 } }, -- tp:   3000,  -600
  ["Europe, Russia, Xeta"]                      = { position = { x = 6100, y =   300 }, map_grid = { x = 18, y =  1 } }, -- tp:   4000, -1000
  ["Europe, Russia, Yakutia"]                   = { position = { x = 6600, y =   500 }, map_grid = { x = 19, y =  2 } }, -- tp:   5000,  -600
  ["Europe, Russia, Zyryanka"]                  = { position = { x = 7100, y =   500 }, map_grid = { x = 20, y =  2 } }, -- tp:   6000,  -600
  ["Asia, Kazakhstan, Aktobe"]                  = { position = { x = 5100, y =   800 }, map_grid = { x = 16, y =  4 } }, -- tp:   2000,     0
  ["Asia, Kazakhstan, Semey"]                   = { position = { x = 5600, y =   800 }, map_grid = { x = 17, y =  4 } }, -- tp:   3000,     0
  ["Asia, Mongolia, Moron"]                     = { position = { x = 6100, y =   800 }, map_grid = { x = 18, y =  4 } }, -- tp:   4000,     0
  ["Asia, China, Songling"]                     = { position = { x = 6600, y =   800 }, map_grid = { x = 19, y =  4 } }, -- tp:   5000,     0
  ["Asia, China, Nanchang"]                     = { position = { x = 6400, y =  1300 }, map_grid = { x = 19, y =  6 } }, -- tp:   4600,  1000
  ["Asia, China, Chengdu"]                      = { position = { x = 6100, y =  1300 }, map_grid = { x = 18, y =  6 } }, -- tp:   4000,  1000
  ["Asia, Iran, Bam"]                           = { position = { x = 5100, y =  1300 }, map_grid = { x = 16, y =  6 } }, -- tp:   2000,  1000
  ["Asia, India, Delhi"]                        = { position = { x = 5600, y =  1300 }, map_grid = { x = 17, y =  6 } }, -- tp:   3000,  1000
  ["Asia, India, Hampi"]                        = { position = { x = 5500, y =  1600 }, map_grid = { x = 17, y =  8 } }, -- tp:   2800,  1600
  ["Asia, Thailand, Bangkok"]                   = { position = { x = 6050, y =  1600 }, map_grid = { x = 18, y =  8 } }, -- tp:   3900,  1600
  ["Arabia, Saudi Arabia, Tabuk"]               = { position = { x = 4600, y =  1300 }, map_grid = { x = 15, y =  6 } }, -- tp:   1000,  1000
  ["Africa, Morocco, Akka"]                     = { position = { x = 3600, y =  1300 }, map_grid = { x = 12, y =  6 } }, -- tp:  -1000,  1000
  ["Africa, North Africa, Waddan"]              = { position = { x = 4100, y =  1300 }, map_grid = { x = 13, y =  6 } }, -- tp:      0,  1000
  ["Africa, Mali, Bamako"]                      = { position = { x = 3600, y =  1675 }, map_grid = { x = 12, y =  8 } }, -- tp:  -1000,  1750
  ["Africa, Chad, Mongo"]                       = { position = { x = 4100, y =  1675 }, map_grid = { x = 13, y =  8 } }, -- tp:      0,  1750
  ["Africa, Ethiopia, Dangila"]                 = { position = { x = 4600, y =  1675 }, map_grid = { x = 15, y =  8 } }, -- tp:   1000,  1750
  ["Africa, Angola, Huambo"]                    = { position = { x = 4175, y =  2100 }, map_grid = { x = 13, y =  9 } }, -- tp:    150,  2600
  ["Africa, Tanzania, Songea"]                  = { position = { x = 4600, y =  2100 }, map_grid = { x = 15, y =  9 } }, -- tp:   1000,  2600
  ["Africa, South Africa, Johannesburg"]        = { position = { x = 4400, y =  2500 }, map_grid = { x = 14, y = 10 } }, -- tp:    600,  3400
  ["Oceania, Australia, Newman"]                = { position = { x = 6450, y =  2500 }, map_grid = { x = 19, y = 10 } }, -- tp:   4700,  3400
  ["Oceania, Australia, Griffith"]              = { position = { x = 7100, y =  2600 }, map_grid = { x = 20, y = 10 } }, -- tp:   6000,  3800
  -- from Pacific: x - 4350 (tp x not adjusted)
  ["North America, Greenland, Qaanaaq"]         = { position = { x = 2550, y =   200 }, map_grid = { x =  7, y =  1 } }, -- tp:  ?, -1200
  ["North America, Greenland, Uranienborg"]     = { position = { x = 3150, y =   200 }, map_grid = { x =  9, y =  1 } }, -- tp:  ?, -1200
  ["North America, Greenland, Summit Camp"]     = { position = { x = 2800, y =   450 }, map_grid = { x =  8, y =  2 } }, -- tp:  ?,  -700
  ["North America, Canada, Ellesmere Island"]   = { position = { x = 1950, y =   200 }, map_grid = { x =  5, y =  1 } }, -- tp:  ?, -1200
  ["North America, Canada, Fort Liard"]         = { position = { x =  900, y =   500 }, map_grid = { x =  2, y =  2 } }, -- tp:  ?,  -600
  ["North America, Canada, Yellowknife"]        = { position = { x = 1450, y =   475 }, map_grid = { x =  3, y =  2 } }, -- tp:  ?,  -600
  ["North America, Canada, Mid Baffin"]         = { position = { x = 2150, y =   400 }, map_grid = { x =  6, y =  2 } }, -- tp:  ?,  -800
  ["North America, Canada, Okak"]               = { position = { x = 2350, y =   675 }, map_grid = { x =  7, y =  3 } }, -- tp:  ?,  -250
  ["North America, Canada, Saskatoon"]          = { position = { x = 1400, y =   775 }, map_grid = { x =  3, y =  4 } }, -- tp:  ?,     0
  ["North America, Canada, Hearst"]             = { position = { x = 1950, y =   800 }, map_grid = { x =  5, y =  4 } }, -- tp:  ?,     0
  ["North America, United States, Hughes"]      = { position = { x =  300, y =   500 }, map_grid = { x =  1, y =  2 } }, -- tp:  ?,  -600
  ["North America, United States, Boise"]       = { position = { x = 1200, y =  1000 }, map_grid = { x =  2, y =  5 } }, -- tp:  ?,   400
  ["North America, United States, Des Moines"]  = { position = { x = 1675, y =  1000 }, map_grid = { x =  4, y =  5 } }, -- tp:  ?,   400
  ["North America, United States, Albany"]      = { position = { x = 2125, y =  1000 }, map_grid = { x =  6, y =  5 } }, -- tp:  ?,   400
  ["North America, United States, El Paso"]     = { position = { x = 1350, y =  1200 }, map_grid = { x =  3, y =  6 } }, -- tp:  ?,   800
  ["North America, United States, Montgomery"]  = { position = { x = 1900, y =  1200 }, map_grid = { x =  5, y =  6 } }, -- tp:  ?,   800
  ["Central America, Mexico, Mexico City"]      = { position = { x = 1550, y =  1500 }, map_grid = { x =  3, y =  7 } }, -- tp:  ?,  1400
  ["South America, Peru, Iquitos"]              = { position = { x = 2200, y =  2000 }, map_grid = { x =  5, y =  8 } }, -- tp:  ?,  2400
  ["South America, Brazil, Palmas"]             = { position = { x = 2750, y =  2150 }, map_grid = { x =  7, y =  9 } }, -- tp:  ?,  2700
  ["South America, Argentina, Cordoba"]         = { position = { x = 2350, y =  2600 }, map_grid = { x =  6, y = 10 } }  -- tp:  ?,  3600
}
return cities_atlantic
