# CitiesOfEarth 3

A Factorio mod that uses a map of Earth for world generation.  The map is a scalable size but does not tile (repeat).
* Optional: A teleporter allowing for moving around the map at each city area.
* Optional "Pre-Place Silo".  The Rocket Silo will be built at map creation and cannot be crafted by players. Optionally can be re-instated after rocket launches.
* Optional "Penalty Per Death".  Each death increases the number of launches to win.

thanks to TheOddler, OARC, MojoD, Nexela, the testers

## Worlds, Regions, and Cities

There are four 'worlds', set on Earth.  
* Atlantic - The center of the map is the Atlantic Ocean.  This puts America on the 'right' side and Africa & Europe on the 'left' side of the game map.  This is the traditional view of Earth on a map.
* Pacific  - The center of the map is the Pacific Ocean.   This puts Africa & Europe on the 'left' side and America on the 'right' side of the game map.  This allows for a connection between Russia and Alaska to be built.
* Olde World - Europe, Asia, Africa, and Australia.  This removes the Americas for a denser map.
* Americas - Canada, Greenland, North, Central, and South Americas.  This also allows for a denser map.

Each 'World' has a list of cities.  'Atlantic' and 'Pacific' have the same city list.  'Olde World' and 'Americas' have a subset.

Earth image processing by [The Oddler](https://mods.factorio.com/user/TheOddler)
City information was pulled from [Mapcarta](https://mapcarta.com/).

--------------------------------------------------------------------------------

## Known Issues:
* none

## Helpful commands:
#### chart, day mode, free movement, 10x speed
* /c local player = game.player; local pos = player.position; local rad=500; player.force.chart(player.surface, {{x = pos.x-rad, y = pos.y-rad}, {x = pos.x+rad, y = pos.y+rad}});
game.player.surface.always_day=true;
game.player.character=nil;
game.speed=10

### Charting
* chart around player for 500
* /c local player = game.player; local pos = player.position; local rad=500; player.force.chart(player.surface, {{x = pos.x-rad, y = pos.y-rad}, {x = pos.x+rad, y = pos.y+rad}});
* /c game.player.surface.always_day=true
  Print the object 'area':
* /c game.print(serpent.block(event.area))

### Players
* get player index based on name: ( /*player_index*/ == hyspeed --> 1  )
* /c for k | v in pairs(game.players) do game.player.print(v.name .. " -> " .. k) end

* get player's current position
* /c local p = game.player.position; game.print( p.x..","..p.y)

* teleport player id to a location:
* /c game.players[z].teleport({x,y})

* 'god mode'
* /c game.player.character=nil
* undo 'god mode':
* /c game.player.create_character()

### Speed
* speed up the game for mapping and moving during testing
* /c game.speed=10

### Items
* add items to the player's inventory:
* /c game.player.insert{name="grenade" | count=10}
* /c game.player.insert{name="car" | count=1}
* /c game.player.insert{name="rocket-fuel" | count=10}

### Unlocks & settings
/c local player = game.player
  player.surface.always_day=true
  player.force.research_all_technologies()
  player.cheat_mode=true

#### Equipment
/c local player = game.player
  player.insert{name="power-armor-mk2", count = 1}
  local armor = player.get_inventory(5)[1].grid
    armor.put({name = "fusion-reactor-equipment"})
    armor.put({name = "fusion-reactor-equipment"})
    armor.put({name = "fusion-reactor-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "exoskeleton-equipment"})
    armor.put({name = "personal-roboport-mk2-equipment"})
    armor.put({name = "personal-roboport-mk2-equipment"})
    armor.put({name = "personal-roboport-mk2-equipment"})
    armor.put({name = "personal-roboport-mk2-equipment"})
    armor.put({name = "battery-mk2-equipment"})
    armor.put({name = "battery-mk2-equipment"})
  player.insert{name="construction-robot", count = 100}
  player.insert{name="landfill", count = 500}

#### Power
/c local player = game.player
  player.insert({name="nuclear-reactor", count=1})
  player.insert({name="heat-exchanger", count=2})
  player.insert({name="steam-turbine", count=4})
  player.insert({name="offshore-pump", count=1})
  player.insert({name="pipe", count=1})
  player.insert({name="uranium-fuel-cell", count=50})
  player.insert({name="substation", count=10})
  player.insert({name="stack-inserter", count=10})
  player.insert({name="roboport", count=5})
  player.insert({name="logistic-robot", count=200})
  player.insert({name="beacon", count=20})
  player.insert({name="speed-module-3", count=50})
  player.insert({name="logistic-chest-requester", count=10})

  player.insert({name="rocket-silo", count=1})
  player.insert({name="", count=1})

#### Game setup
/c local player = game.player
  player.surface.always_day=true
  player.force.research_all_technologies()
  player.cheat_mode=true

#### Steam Power
/c local player = game.player
  player.insert({name="offshore-pump", count=10})
  player.insert({name="substation", count=10})
  player.insert({name="solid-fuel", count=500})
  player.insert({name="boiler", count=10})
  player.insert({name="steam-engine", count=20})
  player.insert({name="pipe", count=100})

## Nuclear power 
/c local player = game.player
  player.insert({name="nuclear-reactor", count=1})
  player.insert({name="heat-exchanger", count=2})
  player.insert({name="steam-turbine", count=4})
  player.insert({name="offshore-pump", count=1})
  player.insert({name="pipe", count=1})
  player.insert({name="uranium-fuel-cell", count=50})
  player.insert({name="substation", count=10})

## rocket silo support parts
/c local player = game.player
  player.insert({name="stack-inserter", count=50})
  player.insert({name="roboport", count=5})
  player.insert({name="logistic-robot", count=200})
  player.insert({name="beacon", count=20})
  player.insert({name="speed-module-3", count=50})
  player.insert({name="logistic-chest-requester", count=50})
  player.insert({name="satellite", count=10})

#### Create a silo
/c game.surfaces["Earth"].create_entity({name="rocket-silo", position=game.player.position, force=game.player.force, move_stuck_players=true})

#### Create chests of these items where the player is standing
/c local s = game.surfaces["Earth"] local p = game.player.position local f = game.player.force l = "logistic-chest-passive-provider"
  for i = 1, 25 do
    local rf_c  = s.create_entity({name=l, position={p.x+1,p.y+i}, force=f, move_stuck_players=true}) rf_c.insert({name="rocket-fuel", count=40})
    local rcu_c = s.create_entity({name=l, position={p.x+2,p.y+i}, force=f, move_stuck_players=true}) rcu_c.insert({name="rocket-control-unit", count=40})
    local lds_c = s.create_entity({name=l, position={p.x+3,p.y+i}, force=f, move_stuck_players=true}) lds_c.insert({name="low-density-structure", count=40})
  end

#### Solar Power
/c local player = game.player   player.insert({name="solar-panel", count=10})   player.insert({name="substation", count=10})  

#### Unresearch technologies
/c for _, tech in pairs(game.player.force.technologies) do 
	tech.researched=false
	game.player.force.set_saved_technology_progress(tech, 0)
end

### Biters
/c game.map_settings.enemy_evolution.time_factor = 0


