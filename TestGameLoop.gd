extends SceneTree

# This script simulates the Full Game Loop (Overworld <-> Battle)
# Run with: godot -s TestGameLoop.gd --headless

func _init():
	print("=== Starting Full Game Simulation ===")

	# 1. Instantiate Core Systems
	var game_manager = GameManager.new()
	var battle_manager = BattleManager.new()
	var overworld_manager = OverworldManager.new()
	var battle_ui = BattleUI.new()
	var main_menu = MainMenu.new()
	var options_menu = OptionsMenu.new()

	# 2. Instantiate Entities
	var ow_player = OverworldPlayer.new()

	# 3. Setup Dependencies
	# In a real scene, this is done via Node path exports or Autoloads
	battle_manager._ready()
	overworld_manager.setup(ow_player)
	battle_ui.setup(battle_manager)

	game_manager.setup(overworld_manager, battle_manager, battle_ui, main_menu, options_menu)

	# 4. Simulation Start

	# Phase 0: Start New Game
	print("\n--- Phase 0: Starting New Game via Menu ---")
	# We simulate pressing the New Game button to initialize the party and state
	main_menu.on_new_game_pressed()

	# Hack: Ensure hero stats are what we expect for the test
	if not game_manager.player_party.is_empty():
		var hero = game_manager.player_party[0]
		hero.strength = 10
		hero.unarmed_damage = 5 # Total 15

	# Phase 1: Walk in Overworld and Interact
	print("\n--- Phase 1: Finding Enemy in Overworld ---")

	# Add an enemy to interact with at (1,0)
	var enemy_entity = WorldEntity.new("test_slime", "Slime", Vector2(1, 0))
	overworld_manager.add_entity(enemy_entity)

	# Move to the enemy
	print("Moving to Enemy...")
	game_manager.simulate_input_move(Vector2(1, 0))

	# Interact
	print("Interacting...")
	game_manager.simulate_input_interact()

	if game_manager.current_state != GameManager.GameState.BATTLE:
		print("FAIL: Interaction did not trigger battle.")
		quit()

	# Phase 2: Battle
	print("\n--- Phase 2: Battle Combat ---")
	# Enemy has 30 HP (defined in GameManager). Hero has 15 ATK.
	# Should take 2 hits.

	if game_manager.current_state == GameManager.GameState.BATTLE:
		# Turn 1
		print("Battle Turn 1")
		game_manager.simulate_input_battle_attack(0)

		# Turn 2
		print("Battle Turn 2")
		# Check if battle is still ongoing (Enemy might attack back)
		if game_manager.current_state == GameManager.GameState.BATTLE:
			game_manager.simulate_input_battle_attack(0)

	# Phase 3: Back to Overworld
	print("\n--- Phase 3: Post-Battle ---")
	if game_manager.current_state == GameManager.GameState.OVERWORLD:
		print("Successfully returned to Overworld.")
		print("Moving one more step to prove we are back.")
		game_manager.simulate_input_move(Vector2(1, 0))
	else:
		print("Error: Did not return to Overworld.")

	print("\n=== Simulation Ended ===")
	quit()
