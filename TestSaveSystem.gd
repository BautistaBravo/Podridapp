extends SceneTree

# Simulation for Save/Load System

func _init():
	print("=== Starting Save System Simulation ===")

	# --- Setup Environment ---
	var overworld_manager = OverworldManager.new()
	var player = OverworldPlayer.new()
	overworld_manager.setup(player)

	# Setup Party
	var hero = Hero.new()
	hero.unit_name = "Cloud"
	hero.max_health = 100
	hero._ready()
	# Damage hero to test persistence
	hero.take_damage(20)
	var party: Array[Combatant] = [hero]

	# Setup Entities
	# Entity 1: Close to player (0,0) -> Should be loaded
	var entity1 = WorldEntity.new("slime_1", "Slime", Vector2(100, 0))
	overworld_manager.add_entity(entity1)

	# Entity 2: Far from player -> Should be unloaded (Load dist is 300)
	var entity2 = WorldEntity.new("goblin_1", "Goblin", Vector2(1000, 1000))
	overworld_manager.add_entity(entity2)

	print("\n--- Initial State ---")
	print("Hero HP: ", hero.current_health)
	print("Entity 1 Loaded: ", entity1.is_loaded)
	print("Entity 2 Loaded: ", entity2.is_loaded)

	if not entity1.is_loaded or entity2.is_loaded:
		print("FAIL: Initial visibility check failed.")
		quit()

	# --- SAVE ---
	print("\n--- Saving ---")
	var saved_data = SaveManager.save_game(party, overworld_manager)
	# print("Save Data: ", saved_data)

	# --- RESET / DESTROY ---
	print("\n--- Resetting Game State ---")
	party.clear()
	overworld_manager.active_entities.clear()
	player.grid_position = Vector2(-999, -999) # Move player away

	# --- LOAD ---
	print("\n--- Loading ---")
	var loaded_party = SaveManager.load_game(saved_data, overworld_manager)

	# --- VERIFY ---
	print("\n--- Verification ---")

	# 1. Verify Party
	var loaded_hero = loaded_party[0]
	print("Loaded Hero HP: ", loaded_hero.current_health)
	if loaded_hero.current_health != 80:
		print("FAIL: Hero Health not restored correctly.")
	else:
		print("PASS: Hero Health restored.")

	# 2. Verify Entities
	if overworld_manager.active_entities.size() != 2:
		print("FAIL: Wrong number of entities loaded.")

	var loaded_e1
	var loaded_e2

	for e in overworld_manager.active_entities:
		if e.entity_id == "slime_1": loaded_e1 = e
		if e.entity_id == "goblin_1": loaded_e2 = e

	if loaded_e1 and loaded_e1.position == Vector2(100, 0):
		print("PASS: Entity 1 position restored.")
	else:
		print("FAIL: Entity 1 incorrect.")

	# 3. Verify Visibility (Based on restored player position)
	# Player should be back at 0,0 (default/saved), so E1 loaded, E2 unloaded.
	print("Player Pos: ", overworld_manager.player.grid_position)
	print("Entity 1 Loaded: ", loaded_e1.is_loaded)
	print("Entity 2 Loaded: ", loaded_e2.is_loaded)

	if loaded_e1.is_loaded and not loaded_e2.is_loaded:
		print("PASS: Visibility logic restored correctly.")
	else:
		print("FAIL: Visibility logic incorrect after load.")

	print("\n=== Simulation Ended ===")
	quit()
