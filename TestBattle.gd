extends SceneTree

# This script simulates the Main Scene or Main Loop
# Run this with: godot -s TestBattle.gd --headless (if godot is installed)

func _init():
	print("--- Starting Battle Simulation ---")

	# Instantiate Managers
	var battle_manager = BattleManager.new()
	var battle_ui = BattleUI.new()

	# Instantiate Units
	var hero = Hero.new()
	hero.max_health = 100
	hero.strength = 15
	hero.unarmed_damage = 5 # Total 20
	hero.unit_name = "Cloud"

	var enemy = Enemy.new()
	enemy.max_health = 50
	enemy.strength = 5
	enemy.unarmed_damage = 0
	enemy.unit_name = "Slime"

	# Add to tree (simulated parent-child relationships for _ready to work if this was a real scene)
	# Since we are running -s (script only), _ready is not called automatically unless we are in the scene tree.
	# We will manually call _ready for simulation purposes or set them up.
	hero._ready()
	enemy._ready()
	battle_manager._ready()

	# Setup UI
	battle_ui.setup(battle_manager)

	# Setup Battle
	print("\n--- Setup Phase ---")
	battle_manager.setup_battle([hero], [enemy])

	# Simulation Loop
	# 1. Player Turn
	print("\n--- Player Turn 1 ---")
	# Simulate player clicking "Attack" on the first enemy (index 0)
	battle_ui.on_attack_button_pressed(0)

	# Enemy Logic is handled inside end_turn -> process_enemy_turn in the manager
	# So after player attacks, if enemy survives, it automatically triggers enemy turn and attacks back

	print("\n--- Player Turn 2 ---")
	if enemy.is_alive():
		battle_ui.on_attack_button_pressed(0)

	print("\n--- Player Turn 3 ---")
	if enemy.is_alive():
		battle_ui.on_attack_button_pressed(0)

	# The Enemy has 50 HP and Hero deals 20 Damage.
	# Turn 1: 30 HP left
	# Turn 2: 10 HP left
	# Turn 3: -10 HP (Dead) -> Victory

	print("\n--- Simulation Ended ---")
	quit()
