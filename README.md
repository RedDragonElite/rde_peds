RDE Peds Resource for FiveM
The rde_peds resource is a comprehensive NPC management system designed for FiveM, a multiplayer modification framework for GTA V. This resource allows administrators to easily spawn, manage, and interact with NPCs (Non-Player Characters) within the game world.

Features
NPC Spawning: Admins can spawn NPCs at their current location with customizable models, types (static or guard), scenarios, and other attributes.
NPC Management: Admins can manage existing NPCs, including changing their position, scenario, name, and speech. They can also delete individual NPCs or all NPCs at once.
Paginated NPC List: The resource includes a paginated list of active NPCs, making it easy to manage a large number of NPCs.
Admin Menu: An admin menu provides easy access to all NPC management features.
Interaction System: NPCs can be interacted with, displaying their information or custom speech.
Syncing: NPCs are synced across the server, ensuring all players see the same NPCs.
Installation
Place the rde_peds folder in your FiveM server's resources directory.
Add ensure rde_peds to your server.cfg file to ensure the resource is started.
Configure the resource by editing the config.lua file to set up ped models, guard weapons, scenarios, and other settings.
Usage
Admin Command: Use the /pedadmin command to open the admin menu.
Keybind: Press F6 (default keybind) to open the admin menu.
Admin Menu: The admin menu allows you to create new NPCs, manage existing NPCs, and delete all NPCs.
Configuration
The config.lua file allows you to customize various aspects of the resource:

Ped Models: Define the available ped models.
Guard Weapons: Set the weapons that guard NPCs can use.
Scenarios: Define the scenarios that NPCs can perform.
Events
The resource includes several events for syncing NPCs across the server:

rde_peds:syncPed: Syncs a single NPC.
rde_peds:deletePed: Deletes a single NPC.
rde_peds:deleteAllPeds: Deletes all NPCs.
rde_peds:updatePedPosition: Updates an NPC's position.
rde_peds:updatePedScenario: Updates an NPC's scenario.
rde_peds:renamePed: Renames an NPC.
rde_peds:setPedSpeech: Sets an NPC's speech.
Dependencies
ox_lib: Required for UI and input dialogs.
ox_target: Required for targeting and interacting with NPCs.
Contributing
Contributions are welcome! Please open an issue or submit a pull request if you have any suggestions, bug reports, or improvements.

License
This resource is licensed under the MIT License. See the LICENSE file for more information.
