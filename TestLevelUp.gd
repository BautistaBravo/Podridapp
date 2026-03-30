extends SceneTree

# Simulation for Level Up and Interaction

func _init():
	print("=== Starting Level Up & Interaction Simulation ===")

	# --- Instantiate Systems ---
	var game_manager = GameManager.new()
	var overworld_manager = OverworldManager.new()
	var battle_manager = BattleManager.new()
	var battle_ui = BattleUI.new()
	var main_menu = MainMenu.new()
	var options_menu = OptionsMenu.new()

	var player = OverworldPlayer.new()
	overworld_manager.setup(player)
	battle_manager._ready()

	# Setup GameManager (Starts in MAIN_MENU)
	game_manager.setup(overworld_manager, battle_manager, battle_ui, main_menu, options_menu)

	# --- Setup Scenario ---
	# 1. Start New Game
	main_menu.on_new_game_pressed()
	var hero = game_manager.player_party[0]

	print("\nHero Stats (Level %d): HP %d, STR %d, EXP %d/%d" % [hero.level, hero.max_health, hero.strength, hero.current_exp, hero.exp_to_next_level])

	# 2. Add an Enemy Entity to the map at (1,0)
	# "Goblin" gives 50 EXP (from Database). Hero needs >100 EXP to level.
	# We need a few Goblins to level up.

	var slime1 = WorldEntity.new("goblin_1", "Goblin", Vector2(1, 0))
	overworld_manager.add_entity(slime1)

	# 3. Move Player to (1,0) - Should NOT trigger encounter automatically now
	print("\n--- Moving Player to Enemy ---")
	game_manager.simulate_input_move(Vector2(1, 0))

	if game_manager.current_state == GameManager.GameState.BATTLE:
		print("FAIL: Battle started automatically (Random encounter logic still active?)")
		quit()
		return

	# 4. Interact triggers battle
	print("\n--- Interacting with Enemy ---")
	game_manager.simulate_input_interact()

	if game_manager.current_state != GameManager.GameState.BATTLE:
		print("FAIL: Battle did not start after interaction.")
		quit()
		return
	else:
		print("PASS: Battle Started via Interaction.")

	# 5. Fight Battle 1
	# Hero Strength 25 + 5 Unarmed = 30 ATK.
	# Goblin Defense 15. Damage = 30 - 15 = 15.
	# Goblin HP 45. 3 hits.
	print("\n--- Fighting Battle 1 ---")
	game_manager.simulate_input_battle_attack(0) # 45 -> 30
	game_manager.simulate_input_battle_attack(0) # 30 -> 15
	game_manager.simulate_input_battle_attack(0) # 15 -> 0 (Death) -> Victory

	# Battle Ends, EXP gained.
	if game_manager.current_state == GameManager.GameState.OVERWORLD:
		print("PASS: Returned to Overworld.")
	else:
		print("FAIL: Did not return to Overworld.")

	print("Hero Stats: EXP %d/%d" % [hero.current_exp, hero.exp_to_next_level])
	if hero.current_exp != 50:
		print("FAIL: Incorrect EXP amount. Expected 50.")

	# 6. Fight Battle 2 (To trigger Level Up)
	# Add another Goblin at current pos (1,0) since player is there
	# We need 2 more battles probably? 50 EXP per goblin.
	# Hero needs 120 (100 * 1.2^0 * 1 = 100). Wait.
	# Hero exp_to_next_level calc in Combatant: int(100 * pow(1.2, 1)) = 120.
	# So 3 Goblins total needed (150 EXP).

	var slime2 = WorldEntity.new("goblin_2", "Goblin", Vector2(1, 0))
	overworld_manager.add_entity(slime2)

	print("\n--- Fighting Battle 2 ---")
	game_manager.simulate_input_interact() # Trigger
	game_manager.simulate_input_battle_attack(0)
	game_manager.simulate_input_battle_attack(0)
	game_manager.simulate_input_battle_attack(0)

	var slime3 = WorldEntity.new("goblin_3", "Goblin", Vector2(1, 0))
	overworld_manager.add_entity(slime3)

	print("\n--- Fighting Battle 3 ---")
	game_manager.simulate_input_interact() # Trigger
	game_manager.simulate_input_battle_attack(0)
	game_manager.simulate_input_battle_attack(0)
	game_manager.simulate_input_battle_attack(0)

	# 7. Verify Level Up
	print("\n--- Verification ---")
	print("Hero Stats (Level %d): HP %d, STR %d, EXP %d/%d" % [hero.level, hero.max_health, hero.strength, hero.current_exp, hero.exp_to_next_level])

	if hero.level == 2:
		print("PASS: Hero Leveled Up!")
		if hero.max_health > 100: # Base was 100
			print("PASS: Stats Increased.")
	else:
		print("FAIL: Hero did not level up.")

	print("\n=== Simulation Ended ===")
	quit()
