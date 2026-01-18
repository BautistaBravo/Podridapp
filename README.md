# Godot JRPG Project

This project contains a modular JRPG structure written in GDScript for Godot 4.

## How to Run
1. Open Godot 4.
2. Click "Import" and select the `project.godot` file in this directory.
3. The project should open.
4. Press F5 (Run) to play the `scenes/Main.tscn` scene.

## What is included
- **GameManager**: Handles state (Menu, Overworld, Battle).
- **BattleManager**: Handles turn-based combat.
- **SaveManager**: Handles saving/loading to `user://savegame.json`.
- **GameDatabase**: Contains stats for creatures (Goblin, Wolf, etc.).
- **Scenes**: `Main.tscn` sets up the managers and UI. `BattleUI.tscn` provides a basic interface.

## What you need to do
- **Art**: The project uses basic UI controls. You will need to add Sprites, Tilemaps, and Sounds.
- **Overworld**: The `OverworldManager` handles logic, but you need to build the actual 2D Map (TileMap) and Player Sprite logic in a `Node2D` scene if you want visual movement.
- **Signals**: The UI buttons are connected in the `.tscn` files provided, but as you expand, you'll need to connect more signals in the Editor.
