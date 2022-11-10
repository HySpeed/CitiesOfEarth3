# CitiesOfEarth 3

A Factorio mod that uses maps of Earth for world generation.  Choose from four different world layouts.  The world size can be set at startup but does not tile (repeat).
* Optional: Teleporters at each city allowing for moving around the map.
* Optional: "Pre-Place Silo".  The Rocket Silo will be built at map creation and cannot be crafted by players. 
* Optional: For "Pre-Placed Silo", the Rocket Silo can be re-instated after a configurable number of rocket launches.
* Optional "Penalty Per Death".  Each death increases the number of launches required to win.

No control is made over resources other than water: only terrain generation.

Thanks to TheOddler, OARC, MojoD, Nexela, and the testers.


## Recommended "Helper" Mods:
#### Beautiful Bridge Railway by kapaer
This mod allows you to build bridges over water.  Because Earth has many small pocket of water and rivers, using landfill is very challenging.  In using landfill to connect islands can ruin the look of the Earth.  https://mods.factorio.com/mod/beautiful_bridge_railway

#### Walkable Water by RedRafe
Configure this mod to give the biters the ability to walk on water, but not the player.  This will resolve the issue of biters not being able to cross rivers.  The rivers cause many pathing problems for biters, which may cause performance issues.  Note, however, that biters will be able to cross from the smaller islands with this mod.  (more challenge) https://mods.factorio.com/mod/walkable-water


## World Layouts, Cities, and Sizes

#### There are four **World Layouts**:
This is chosen at map setup and cannot be changed later.
* **Atlantic** - The center of the map is the Atlantic Ocean.  This puts America on the 'left' side and Africa & Europe on the 'right' side of the game map.  This is the traditional view of Earth on a map.
* **Pacific**  - The center of the map is the Pacific Ocean.   This puts Africa & Europe on the 'left' side and America on the 'right' side of the game map.  This allows for a connection between Russia and Alaska to be built.
* **Olde World** - Only Europe, Asia, Africa, and Australia.  This removes the Americas for a denser map.
* **Americas** - Canada, Greenland, North, Central, and South Americas.  This also allows for a denser map.

### **Cities**
Each world layout has a list of 'cities'.  These are markers on the map.  With Teleporters enabled, there will be an entity at these locations.  The 'city' is an area on the map with a map view tag.  No additional buildings are placed. 
The 'Atlantic' and 'Pacific' layouts have 50 cities and use the same city list.  
The 'Olde World' and 'Americas' layouts have 30 and 20 cities repectively - a subset of the Atlantic / Pacific layouts.
City information was pulled from [Mapcarta](https://mapcarta.com/) and all locations are approximate.

### **Sizes**
The world map size is specified at setup and can be a value between 1 and 100.  The default is 1.  The larger the map, the more detail  the map will have.  All of the city areas are charted (but not revealed) at map creation.  This will result in a long initialization time and a larger-than-normal map size when first starting.  (note: the surface name is "Earth")

The map size depends on the map layout and the scale chosen.  This table shows the sizes for `scale = 1`

| Layout        | Top Left    | Bot Right | Size        | Tiles |
|:--------------|-------------|-----------|-------------|------:|
| Atlantic      | -7800,-3200 | 7800,3200 | 15600, 6400 | ~100M |
| Pacific       | -7800,-3200 | 7800,3200 | 15600, 6400 | ~100M |
| Olde World    | -4500,-3000 | 4500,3000 |  9000, 6000 |  ~54M |
| Americas      | -3500,-3300 | 3500,3300 |  7000, 6600 |  ~46M |

Mutliply these values by the scale for the world size.

Note: Because the world does not repeat or 'tile', there are a finite amound of resources.

For comparison, a 5k SPM base can be about 9k x 4k = ~36M tiles.  A 10k SPM base can be 10k x 12k = ~ 120M tiles

## Options:
These are the options for the mod:

### Map to use for the game
- The map name determines the world layout.
- Options available: Atlantic, Pacific, Olde World, Americas
- Setup option (Cannot be changed after creating the world.)

### Map scaling factor
- Map Size - for Solo play, 1 is good.  For Multiplayer, 2 is good.  The Map does not tile (repeat).
- From testing experience, sizes beyond 4 do not provide a good experience.
- Smaller sizes (0.25 & 0.5) are intended for testing and evaluation.
- This is a Setup option and cannot be changed after creating the world.

### Create Teleporter Buildings
- Without these, only the label is created.
- If playing without teleporters, disable this option and no entity will be created at the city.
- If playing with teleporters, the action of teleporting can be controlled by using the "Teleporters Enabled" control (see below).
- This is a Setup option and cannot be changed after creating the world.

### All Teleporters Available
- If playing with Teleporers, this option enables all teleporters in the UI without requiring them to be revealed first.  This will chart all of the city locations on the map.
- When unchecked this option requires that each teleporter be revealed in the world before it is avalable to be teleported to.
- This is a Setup option and cannot be changed after creating the world.

### Pre-Place Silo
- There are 3 options: None, Single, All
- - None: No Silos are pre-placed; recipes are normal; no related win conditions
- - Single: One Silos is pre-placed at a city (chosen below); crafting a silo is disabled until the chosen number of rockets is launched; the chosen number of rockets must be launched to win.
- - All: A Silo is pre-placed at all cities; crafting a silo is disabled until a rocket is launched from each silo; a rocket must be launched from each silo to win; each silo can only launch one rocket until all silos have launched a rocket
- This is a Setup option and cannot be changed after creating the world.

### Spawn City / Silo City
- There is a dedicated drop-down for each Spawn and Silo City.  
(This duplication is required because a mod cannot dynamically change the options based on other choices.)
- Only choose the Spawn for the world layout being used.  The others are ignored.
- Only choose the Silo if "Pre-Place Silo" is "Single".  Only choose the Silo option for the world layout being used - the others are ignored.
- This is a Setup option and cannot be changed after creating the world.

### All Teleporters Available
- If playing with Teleporers, this option enables all teleporters in the UI without requiring them to be revealed first.  This will chart all of the city locations on the map.
- When unchecked this option requires that each teleporter be revealed in the world before it is avalable to be teleported to.
- This is a Setup option and cannot be changed after creating the world.

### Launches to Restore Silo Crafting
- For "Pre-placed Silo: Single" only: After this many rocket launches, Rocket Silos may be crafted. (**with cargo**)
- This has no effect if Launches per Death is disabled.
- Use a value of zero(0) to disable.
- This is a Setup option and cannot be changed after creating the world.

### Launches per Death
- The number of **additional** Rocket Launches (**with cargo**) that must be completed to win the game.
- Use a value of zero(0) to disable.
- This is a Setup option and cannot be changed after creating the world.

### Teleporting Enabled
- This allows control of usage of the teleporters.  "Create Teleporter Buildings" must be enabled.
- This is used to control usage of the teleporters after the world has been created.
- This is a Run-Time Option and can be changed while playing.

### Teleporters Require Power
- Teleporters require power to teleport from. 
- A revealed teleporter can be teleported **to**, even without power there.  An unpowered teleporter cannot be accessed.
- The amount of power depends upon the distance.  Teleporters recharge slowly over time.
- This is a Run-Time Option and can be changed while playing.

### Drain Equipment Energy on Teleport
- After the teleport, the player's equipped equipment is drained of power (batteries, roboports, etc.).  
- This feature addresses players using late game equipment to jump into biter filled areas and easily clearing them.
- This is a Run-Time Option and can be changed while playing.

--------------------------------------------------------------------------------

## Known Issues:
* In multiplayer, manually teleporting to an uncharted location may cause a desync.
* Rocket Silo crafting may not restore in some situations.  Fixed in 1.5.8.  Use the command below to restore it if needed.
** Fix for if recipe for rocket silo doesn't get restored:
* /c game.player.force.recipes["rocket-silo"].enabled=true

--------------------------------------------------------------------------------

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

/c local player = game.player
player.insert({name="nuclear-fuel", count=20})

### Unlocks & Game Setup
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
  player.insert{name="rocket-launcher", count = 1}
  player.insert{name="atomic-bomb", count = 10}

#### Steam Power
/c local player = game.player
  player.insert({name="offshore-pump", count=20})
  player.insert({name="substation", count=20})
  player.insert({name="nuclear-fuel", count=40})
  player.insert({name="boiler", count=20})
  player.insert({name="steam-engine", count=40})
  player.insert({name="pipe", count=100})
  player.insert({name="inserter", count=50})
  player.insert({name="transport-belt", count=50})


#### Nuclear power 
/c local player = game.player
  player.insert({name="nuclear-reactor", count=1})
  player.insert({name="heat-exchanger", count=2})
  player.insert({name="steam-turbine", count=4})
  player.insert({name="offshore-pump", count=1})
  player.insert({name="pipe", count=1})
  player.insert({name="uranium-fuel-cell", count=50})
  player.insert({name="substation", count=10})

#### Rocket Silo
/c local player = game.player
  player.insert({name="rocket-silo", count=1})
  player.insert({name="stack-inserter", count=50})
  player.insert({name="roboport", count=10})
  player.insert({name="logistic-robot", count=1000})
  player.insert({name="beacon", count=20})
  player.insert({name="speed-module-3", count=50})
  player.insert({name="logistic-chest-requester", count=50})
  player.insert({name="satellite", count=10})

#### Robot Speed
/c game.player.force.technologies['worker-robots-speed-5'].researched=true

#### Create a silo
/c game.surfaces["Earth"].create_entity({name="rocket-silo", position=game.player.position, force=game.player.force, move_stuck_players=true})

#### Create chests of these items where the player is standing
/c local s = game.surfaces["Earth"] local p = game.player.position local f = game.player.force l = "logistic-chest-passive-provider"
  for i = 1, 25 do
    local rf_c  = s.create_entity({name=l, position={p.x+1,p.y+i}, force=f, move_stuck_players=true}) rf_c.insert({name="rocket-fuel", count=400})
    local rcu_c = s.create_entity({name=l, position={p.x+2,p.y+i}, force=f, move_stuck_players=true}) rcu_c.insert({name="rocket-control-unit", count=400})
    local lds_c = s.create_entity({name=l, position={p.x+3,p.y+i}, force=f, move_stuck_players=true}) lds_c.insert({name="low-density-structure", count=400})
  end
/c local player = game.player   player.insert({name="satellite", count=10})

#### Solar Power
/c local player = game.player   player.insert({name="solar-panel", count=10})   player.insert({name="substation", count=10})  

#### Unresearch technologies
/c for _, tech in pairs(game.player.force.technologies) do 
	tech.researched=false
	game.player.force.set_saved_technology_progress(tech, 0)
end

### Biters
/c game.map_settings.enemy_evolution.time_factor = 0

