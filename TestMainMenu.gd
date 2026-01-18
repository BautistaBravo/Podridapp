extends SceneTree

# Simulation for Main Menu Flow

func _init():
	print("=== Starting Main Menu Simulation ===")

	# --- Instantiate All Systems ---
	var game_manager = GameManager.new()
	var overworld_manager = OverworldManager.new()
	var battle_manager = BattleManager.new()
	var battle_ui = BattleUI.new()
	var main_menu = MainMenu.new()
	var options_menu = OptionsMenu.new()

	var player = OverworldPlayer.new()
	overworld_manager.setup(player)
	battle_manager._ready()

	# Use a temp file for this test
	game_manager.save_filepath = "user://test_save_menu.json"

	# Setup GameManager (Starts in MAIN_MENU)
	game_manager.setup(overworld_manager, battle_manager, battle_ui, main_menu, options_menu)

	if game_manager.current_state != GameManager.GameState.MAIN_MENU:
		print("FAIL: Did not start in Main Menu")
		quit()

	# --- SCENARIO 1: Options ---
	print("\n--- Scenario 1: Options ---")
	main_menu.on_options_pressed()
	if game_manager.current_state == GameManager.GameState.OPTIONS:
		print("PASS: Entered Options")
	else:
		print("FAIL: Failed to enter Options")

	options_menu.on_back_pressed()
	if game_manager.current_state == GameManager.GameState.MAIN_MENU:
		print("PASS: Returned to Main Menu")
	else:
		print("FAIL: Failed to return to Main Menu")

	# --- SCENARIO 2: New Game ---
	print("\n--- Scenario 2: New Game ---")
	main_menu.on_new_game_pressed()
	if game_manager.current_state == GameManager.GameState.OVERWORLD:
		print("PASS: Started New Game (Overworld)")
		print("Party Size: ", game_manager.player_party.size())
	else:
		print("FAIL: New Game did not start Overworld")

	# --- SCENARIO 3: Save Game ---
	print("\n--- Scenario 3: Saving Game ---")
	# Modify state to prove load works
	game_manager.player_party[0].take_damage(50)
	print("Hero HP before save: ", game_manager.player_party[0].current_health)

	SaveManager.save_to_file(game_manager.save_filepath, game_manager.player_party, overworld_manager)

	# Return to Main Menu (Simulate Quit to Menu)
	game_manager.switch_state(GameManager.GameState.MAIN_MENU)

	# --- SCENARIO 4: Load Game ---
	print("\n--- Scenario 4: Load Game ---")
	# Reset local party to default to ensure load overwrites/replaces it
	game_manager.player_party.clear()

	main_menu.on_load_game_pressed()

	if game_manager.current_state == GameManager.GameState.OVERWORLD:
		print("PASS: Load Game switched to Overworld")
		if not game_manager.player_party.is_empty():
			print("Loaded Hero HP: ", game_manager.player_party[0].current_health)
			if game_manager.player_party[0].current_health == 50:
				print("PASS: State correctly restored.")
			else:
				print("FAIL: State mismatch.")
		else:
			print("FAIL: Party empty after load.")
	else:
		print("FAIL: Load Game did not switch to Overworld")

	print("\n=== Simulation Ended ===")
	quit()
