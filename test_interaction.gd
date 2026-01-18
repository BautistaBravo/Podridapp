extends SceneTree

func _init():
	print("Validating Overworld Interaction...")

	# 1. Instantiate GameManager
	var game_manager = load("res://scripts/managers/GameManager.gd").new()
	var overworld_manager = load("res://scripts/overworld/OverworldManager.gd").new()
	var battle_manager = load("res://scripts/managers/BattleManager.gd").new()

	# 2. Setup dependencies (Mocking UIs as Nodes)
	# Note: In a real run, these need to be packed scenes or proper scripts
	# For this test, we assume classes are globally registered (class_name)
	var battle_ui = load("res://scripts/managers/BattleUI.gd").new()
	var main_menu = load("res://scripts/ui/MainMenu.gd").new()
	var options_menu = load("res://scripts/ui/OptionsMenu.gd").new()

	game_manager.overworld_manager = overworld_manager
	game_manager.battle_manager = battle_manager
	game_manager.battle_ui = battle_ui
	game_manager.main_menu = main_menu
	game_manager.options_menu = options_menu

	# Add to tree to allow node processing if needed (mock root)
	root.add_child(game_manager)
	# overworld_manager is usually child of Game, but here we manually linked it.

	# 3. Start Game
	# We manually call setup because _ready might not fire automatically in this headless setup immediately
	game_manager.setup(overworld_manager, battle_manager, battle_ui, main_menu, options_menu)
	game_manager._on_new_game()

	# 4. Check Overworld Created
	if game_manager.overworld_root == null:
		print("FAIL: Overworld Root not created.")
		quit(1)
		return

	var player = game_manager.overworld_manager.player
	if player == null:
		print("FAIL: Player not created.")
		quit(1)
		return

	print("PASS: Player created at ", player.position)

	# 5. Check Goblin Created
	var entities = game_manager.overworld_manager.active_entities
	var goblin = null
	for e in entities:
		if e.type_id == "Goblin":
			goblin = e
			break

	if goblin == null:
		print("FAIL: Goblin not found in active entities.")
		quit(1)
		return

	print("PASS: Goblin created at ", goblin.position)

	# 6. Move Player near Goblin
	player.position = goblin.position # Teleport for test
	print("Moved player to Goblin position.")

	# 7. Simulate Interaction
	# We call player_interact directly on manager because Input is hard to simulate headless
	game_manager.overworld_manager.player_interact()

	# 8. Check Game State
	if game_manager.current_state == GameManager.GameState.BATTLE:
		print("PASS: Game switched to BATTLE state.")
	else:
		print("FAIL: Game did not switch to BATTLE state. State is: ", game_manager.current_state)
		quit(1)
		return

	print("All Tests Passed.")
	quit()
