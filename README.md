# Loot Goblin
Item muler designed to work with PD2 singleplayer. Provides an infinite and filterable storage for items.

## **Warning experimental software**
Always keep a separate backup of your PD2 data:
- `pd2_shared.stash` and/or `pd2_hc_shared.stash`
- Any character files `.d2s`
- Any PlugY files `.d2x`, `.sss`
- Easiest is to copy the entire `Save` folder

Loot Goblin only writes to `pd2_shared.stash` and keeps the 5 most recent backups by default in:

`%Appdata%/Roaming/Godot/app_userdata/Loot Goblin/backups/`

Always confirm ingame that items have been moved correctly when retrieving them from the stash.
If you find that an item:
- Didnt move at all
- Moved to a different stash page or position than intended
  
You should restore both `goblin_stash.gstash` and `pd2_shared.stash` from a previous backup (these can be imported into Loot Goblin for preview). 

## Setup
When starting for the first time, choose the PD2 save file location (the `Save` folder in the Diablo II installation containing `pd2_shared.stash`). The last shared stash page will be used by default for importing/exporting items. You can choose to automatically store the items from this page to the main stash whenever Loot Goblin is started or reloaded.

## Important
Loot Goblin is designed to mule items out of game with Diablo II closed. Logging into a character in Diablo II with Loot Goblin open leads to desync as the save file gets read/written by the game. You will be prompted to reload if this occurs. If you want to have Loot Goblin running with the game you should **always** reload after entering/exiting a game with a character.

Its always safe to transfer items when:
- Out of game (Diablo II closed, Loot Goblin open)

When both Diablo II and Loot Goblin are running:
- In D2 main menu*
- In D2 character select screen*
- *Save files must be reloaded in Loot Goblin if a character enters/exits a game

Its never safe to transfer items when:
- In game / in town with a character
- After exiting a game and not reloading/restarting Loot Goblin

# Filtering
Typing in the search bar will by default match:
- Item name (e.g "The Vile Husk")
- Item base name (e.g "Balrog Sword")
- Item base type (e.g "Sword")
- Any magical properties (e.g "Enhanced Damage")

Additionally you can search with the following tags:
- `sockets:` or `s:` will match the number of sockets. Ranges can be provided: `s: 3-5` will match between 3 and 5 sockets
- `type:` or `t:` will only match the base type
- `rarity:` or `r:` will only match the rarity (e.g. "Unique")

Its possible to combine and negate terms with `&` and `!`. 

For example: `t: ring & r: rare & faster cast rate & !corrupt` will match all uncorrupted rare rings with FCR.

# PlugY import
Its possible to import personal/shared pages from PlugY using the importer under settings. However, items cannot be exported back to PlugY currently. You must save the stash after performing an import.

# Read only stashes
Character files are currently read only. The items are displayed, but can not be selected or moved. This includes:
- The character personal page (P)
- The PD2 materials page (M)
- The character inventory, equipment, cube and mercenary items

# Softcore / Hardcore
Loot Goblin maintains separate save files for the two gamemodes. Switching to hardcore will attempt to load `pd2_hc_shared.stash` instead of `pd2_shared.stash` in the PD2 folder.
