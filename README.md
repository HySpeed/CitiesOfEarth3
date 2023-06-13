# CitiesOfEarth 3

A Factorio mod that uses maps of Earth for world generation.  

Choose from different world layouts.  

The world size can be set at startup but does not tile or repeat.

* Optional: Teleporters at each city provide fast movement across the world.
* Optional: "Pre-Place Silo".  The Rocket Silo will be built at map creation and cannot be crafted by players.
* Optional: "Team Co-op".  Each city is a team, players can build a factory to launch from their Silo.

No changes are made for resources other than water: only terrain generation.

Thanks to TheOddler, OARC, MojoD, Nexela, and the testers.

**Please note that this mod changes terrain generation.**  If you have the Cities of Earth mod enabled and load another save, the land and water will be re-created.

## **Recommended "Helper" Mods**

### **Cargo Ships** by schnurrebutz

> Adds massive cargo ships to the game that function similarly to trains. Also adds deep sea oil, oil platforms, tanker ships, train bridges and other water based content.

* <https://mods.factorio.com/mod/cargo-ships>

### **Beautiful Bridge Railway for Cargo Ships** by GeneralTank

> This mod allows you to build bridges over water.  Because Earth has many small pocket of water and rivers, using landfill is very challenging.  In using landfill to connect islands can ruin the look of the Earth.  

* <https://mods.factorio.com/mod/beautiful_bridge_railway_Cargoships>

## **World Layouts, Cities, and Sizes**

### There are several **World Layouts** (aka 'Map')

This is chosen at map setup and cannot be changed later.

* **Atlantic** - The center of the map is the Atlantic Ocean.  This puts America on the 'left' side and Africa & Europe on the 'right' side of the game map.  This is the traditional view of Earth on a map.
* **Pacific**  - The center of the map is the Pacific Ocean.   This puts Africa & Europe on the 'left' side and America on the 'right' side of the game map.  This allows for a connection between Russia and Alaska to be built.
* **Olde World** - Only Europe, Asia, Africa, and Australia.  This removes the Americas for a denser map.
* **Americas** - Only Canada, Greenland, North, Central, and South Americas.  This also allows for a denser map.
* **Africa** - Only the African continent - 47 Capitol Cities of the Countries.
* **Europe** - Only the European Area - 41 Capitol Cities of the Countries.  London -> Mosow, Lisbon -> Antarka.
* **Oceania** - Mostly Australia, Indonesia, and Thailand areas.  Many islands do not support a Rocket Silo.
* **United States** - Only the Continental United States of America - 48 Capitol Cities of the States.

### **Cities**

Each world layout has a list of 'cities' as markers on the map.  When Teleporters enabled, there will be an entity at these locations.  The 'city' is an area on the map with a map view tag.  
The 'Atlantic' and 'Pacific' maps have 50 cities and use the same city list.  
The 'Olde World' map has 30 cities, the 'Americas' maps has 20 cities. (Subsets of the Atlantic / Pacific layouts)
The 'Europe' Map has 41 cities.  These are the capitol cities of the countries of Europe.
The 'United States' Map has 48 cities.  These are the capitol cities of the states of the continental US.
City information was pulled from [Mapcarta](https://mapcarta.com/) and all **locations are approximate**.

### **Sizes**

The world map size is specified at setup and can be a value between 1 and 10.  The default is 1.  The larger the map, the more detail  the map will have.  All of the city areas are charted (but not revealed) at map creation.  This will result in a long initialization time and a larger-than-normal map size when first starting.  (note: the surface name is "Earth")

The map size depends on the map layout and the scale chosen.  This table shows the sizes for `scale = 1` (default is 2)

| Layout        | Top Left     | Bot. Right | Size        | Tiles |
|:--------------|--------------|------------|-------------|------:|
| Atlantic      | -7800, -3200 | 7800, 3200 | 15600, 6400 | ~100M |
| Pacific       | -7800, -3200 | 7800, 3200 | 15600, 6400 | ~100M |
| Olde World    | -4500, -3000 | 4500, 3000 |  9000, 6000 |  ~54M |
| Americas      | -3500, -3300 | 3500, 3300 |  7000, 6600 |  ~46M |
| Africa        | -1600, -1700 | 1600, 1700 |  3200, 3400 |  ~11M |
| Europe        | -1200,  -850 | 1200,  850 |  2400, 1700 |   ~4M |
| Oceania       | -1400, -1500 | 1400, 1500 |  2700, 3000 |   ~8M |
| United States | -1400,  -550 | 1400,  550 |  2800, 1100 |   ~3M |

Mutliply these values by the scale for the world size.

Note: Because the world does not repeat or 'tile', there are a finite amound of resources.

For comparison, a 5k SPM base can be about 9k x 4k = ~36M tiles.  A 10k SPM base can be 10k x 12k = ~120M tiles.  However, the Earth maps have a lot of water, which reduces resources.

## Options

These are the options for the mod:

### Map to use for the game

* The map name determines the world layout.
* Options available: Atlantic, Pacific, Olde World, Americas, Europe, Oceania, United States.
* > This is a Setup option and cannot be changed after creating the world.

### Map scaling factor

* Map Size. For Solo play, 2 is the default.  For Multiplayer, 3 or 4 will be good.  The Map does not tile (repeat).
* For the larger maps, sizes beyond 5 do not provide a good experience as there is too great a distance between elements.
* For the smaller maps, higher sizes may provide more detail and space between cities.
* Smaller sizes (0.25 & 0.5) are intended for testing and evaluation.
* > This is a Setup option and cannot be changed after creating the world.

### Create Teleporter Buildings

* When disabled, no buildings or markers are created.
* If playing without teleporters, disable this option and no entity will be created at the city.
* If playing with teleporters, the action of teleporting can be further controlled by using the "Teleporters Enabled" control (see below).
* > This is a Setup option and cannot be changed after creating the world.

### All Teleporters Available

* If playing with Teleporters, this option enables all teleporters in the UI without requiring them to be revealed first.  This will also reveal all of the city locations on the map at initialization.
* When disabled this option requires that each teleporter be revealed in the world before it is avalable to be teleported to.
* > This is a Setup option and cannot be changed after creating the world.

### Pre-Place Silo

* There are 3 options: None, Single, All
  * **None**: No Silos are pre-placed; recipes are normal.
    * No related win conditions
  * **Single**: One Silo is pre-placed at a city (chosen below).
    * Crafting a silo is disabled until a rocket is launched.
  * **All**: A Silo is pre-placed at all cities.  
    * Crafting a silo is disabled until a rocket is launched from each silo.
    * A rocket must be launched from each silo to win.
    * Each silo has limited launches until all silos have launched a rocket.
      * The limit is the number of silos launched from and increases with each silo.
* > This is a Setup option and cannot be changed after creating the world.

### Spawn City / Silo City

* There is a dedicated drop-down for each Spawn and Silo City.  
(This duplication is required because a mod cannot dynamically change the options based on other choices.)
* Only choose the Spawn for the world layout being used.  The others are ignored.
* Only choose the Silo if "Pre-Place Silo" is "Single".  
* Only choose the Silo option for the world layout being used - the others are ignored.
* > These are Setup options and cannot be changed after creating the world.

### Teleporting Enabled

* This allows control of usage of the teleporters.  "Create Teleporter Buildings" must be enabled.
* This is used to control usage of the teleporters after the world has been created.
* > This is a Run-Time Option and can be changed while playing.

### Teleporters Require Power

* Teleporters require power to teleport from.
* A revealed teleporter can be teleported **to**, even without power there.  An unpowered teleporter cannot be accessed.
* The amount of power depends upon the distance.  Teleporters recharge slowly over time.
* > This is a Run-Time Option and can be changed while playing.

### Drain Equipment Energy on Teleport

* After the teleport, the player's equipped equipment is drained of power (batteries, roboports, etc.).  
* This feature addresses players using late game equipment to jump into biter-filled areas and easily clearing them.
* > This is a Run-Time Option and can be changed while playing.

--------------------------------------------------------------------------------

## Known Issues

* In multiplayer, manually teleporting to an uncharted location may cause a desync.
* Rocket Silo crafting may not restore properly in some situations.  Fixed in 1.5.8.  Use the command below to restore it if needed.
** Fix for if recipe for rocket silo doesn't get restored:
  * /sc game.player.force.recipes["rocket-silo"].enabled = true
* For mod settings of Pre-Placed Silo of "None", the label counter for completed launches does not increment.
* On Pacific and Atlantic maps, the city of Chengdo may not have enough space to spawn at larger scaling values (water)

--------------------------------------------------------------------------------

## Helpful commands

### Chart, day mode, free movement, 10x speed

* /sc local player = game.player; local pos = player.position; local rad=500; player.force.chart(player.surface, {{x = pos.x-rad, y = pos.y-rad}, {x = pos.x+rad, y = pos.y+rad}});
      game.player.surface.always_day=true;
      game.player.character=nil;
      game.speed=10

### Charting

Chart around player for 500 / Always Daytime

* /sc local player = game.player; local pos = player.position; local rad=500; player.force.chart(player.surface, {{x = pos.x-rad, y = pos.y-rad}, {x = pos.x+rad, y = pos.y+rad}});
* /sc game.player.surface.always_day=true

Print the object 'area':

* /sc game.print( serpent.block( event.area ))

### Players

Get player index based on name: ( /*player_index*/ == hyspeed --> 1  )

* /sc for i, p in pairs( game.players ) do game.player.print( p.name .. " -> " .. i ) end

Get player's current position

* /sc local p = game.player.position; game.print( p.x .. "," .. p.y )

Teleport player id to a location:

* /sc game.players[z].teleport( {x, y} )

'god mode'

* /sc game.player.character = nil

Undo 'god mode':

* /sc game.player.create_character()

### Speed

Speed up the game for mapping and moving during testing

* /sc game.speed=10

### Items

Add items to the player's inventory:

* /sc game.player.insert{name="grenade" | count=10}
* /sc game.player.insert{name="car" | count=1}
* /sc game.player.insert{name="rocket-fuel" | count=10}

* /sc local player = game.player;
      player.insert({name="rocket-fuel", count=40})

### Unlocks & Game Setup

* /sc local player = game.player
      player.surface.always_day=true
      player.force.research_all_technologies()
      player.cheat_mode=true

#### Robot Speed

* /sc game.player.force.technologies['worker-robots-speed-6'].researched=true;
      game.player.force.technologies['worker-robots-speed-6'].level = 10

#### Armor & Equipment

* /sc local player = game.player
      player.insert{name="power-armor-mk2", count = 1}
      local armor = player.get_inventory(5)[1].grid
            armor.put({name = "fusion-reactor-equipment"})
            armor.put({name = "fusion-reactor-equipment"})
            armor.put({name = "exoskeleton-equipment"})
            armor.put({name = "exoskeleton-equipment"})
            armor.put({name = "exoskeleton-equipment"})
            armor.put({name = "exoskeleton-equipment"})
            armor.put({name = "exoskeleton-equipment"})
            armor.put({name = "exoskeleton-equipment"})
            armor.put({name = "personal-roboport-mk2-equipment"})
            armor.put({name = "personal-roboport-mk2-equipment"})
            armor.put({name = "battery-mk2-equipment"})
            armor.put({name = "battery-mk2-equipment"})
            armor.put({name = "battery-mk2-equipment"})
            armor.put({name = "battery-mk2-equipment"})
      player.insert{name="construction-robot", count = 50}
      player.insert{name="landfill", count = 200}
      player.insert{name="grenade", count = 100}
      player.insert{name="rocket-launcher", count = 1}
      player.insert{name="rocket", count = 200}
      player.insert{name="atomic-bomb", count = 10}

#### Create a silo

* /sc game.surfaces["Earth"].create_entity( {name = "rocket-silo", position = game.player.position, force = game.player.force, move_stuck_players = true} )

#### Fill Silos with Rocket Parts

* /sc local silos = game.surfaces["Earth"].find_entities_filtered({ type="rocket-silo" })
      for _, silo in pairs( silos ) do
        silo.rocket_parts = 99
      end

#### Solar Power

* /sc local player = game.player   player.insert({name="solar-panel", count=10})   player.insert({name="substation", count=10})  

#### Unresearch technologies

* /sc for _, tech in pairs(game.player.force.technologies) do;
        tech.researched=false
        game.player.force.set_saved_technology_progress(tech, 0)
      end

### Biters

* /sc game.map_settings.enemy_evolution.time_factor = 0
