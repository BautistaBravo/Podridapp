class_name GameManager
extends Node

enum GameState { MAIN_MENU, OPTIONS, OVERWORLD, BATTLE }

var current_state = GameState.MAIN_MENU

@export var overworld_manager: OverworldManager
@export var battle_manager: BattleManager
@export var battle_ui: BattleUI
@export var main_menu: MainMenu
@export var options_menu: OptionsMenu

# Tracking the entity currently being fought
var active_battle_entity: WorldEntity = null

# Global Player Party (persists between battles)
var player_party: Array[Combatant] = []
var save_filepath: String = "user://savegame.json"

# Container for the Overworld Scene
var overworld_root: Node2D = null

func _ready():
	print("Game Manager Ready")
	# If components are assigned via Inspector (Export), initialize connections automatically
	if overworld_manager and battle_manager and battle_ui and main_menu and options_menu:
		setup(overworld_manager, battle_manager, battle_ui, main_menu, options_menu)

func setup(p_overworld: OverworldManager, p_battle: BattleManager, p_ui: BattleUI, p_main_menu: MainMenu, p_options: OptionsMenu):
	overworld_manager = p_overworld
	battle_manager = p_battle
	battle_ui = p_ui
	main_menu = p_main_menu
	options_menu = p_options

	# Check if connections exist to avoid duplicate connection errors in Godot
	if not overworld_manager.encounter_triggered.is_connected(_on_encounter_triggered):
		overworld_manager.encounter_triggered.connect(_on_encounter_triggered)

	if not battle_manager.battle_ended.is_connected(_on_battle_ended):
		battle_manager.battle_ended.connect(_on_battle_ended)

	if not main_menu.new_game.is_connected(_on_new_game):
		main_menu.new_game.connect(_on_new_game)
	if not main_menu.load_game.is_connected(_on_load_game):
		main_menu.load_game.connect(_on_load_game)
	if not main_menu.options.is_connected(_on_options):
		main_menu.options.connect(_on_options)
	if not options_menu.back.is_connected(_on_options_back):
		options_menu.back.connect(_on_options_back)

	# Start in Main Menu
	switch_state(GameState.MAIN_MENU)

func switch_state(new_state):
	current_state = new_state

	# Handle Overworld visibility/activity
	if overworld_root:
		overworld_root.visible = (current_state == GameState.OVERWORLD)
		if overworld_manager.player:
			if overworld_manager.player.has_method("set_active"):
				overworld_manager.player.set_active(current_state == GameState.OVERWORLD)

	# Handle UI visibility
	if battle_ui:
		battle_ui.visible = (current_state == GameState.BATTLE)
	if main_menu:
		main_menu.visible = (current_state == GameState.MAIN_MENU)
	if options_menu:
		options_menu.visible = (current_state == GameState.OPTIONS)

	match current_state:
		GameState.MAIN_MENU:
			print("--- Switched to MAIN MENU ---")
		GameState.OPTIONS:
			print("--- Switched to OPTIONS ---")
		GameState.OVERWORLD:
			print("--- Switched to OVERWORLD ---")
		GameState.BATTLE:
			print("--- Switched to BATTLE ---")

func _on_new_game():
	print("GameManager: Starting New Game...")
	# Reset state if needed
	player_party.clear()
	overworld_manager.active_entities.clear()

	# Create default Hero
	var hero = Hero.new()
	var hero_stats = GameDatabase.get_base_stats("Hero_Cloud")

	hero.unit_name = hero_stats.get("name", "Cloud")
	hero.max_health = hero_stats.get("max_health", 100)
	hero.max_mana = hero_stats.get("max_mana", 50)
	hero.strength = hero_stats.get("strength", 25)
	hero.agility = hero_stats.get("agility", 30)
	hero.defense = hero_stats.get("defense", 20)
	hero.resistance = hero_stats.get("resistance", 20)
	hero.intelligence = hero_stats.get("intelligence", 10)
	hero.faith = hero_stats.get("faith", 5)
	hero.unarmed_damage = hero_stats.get("unarmed_damage", 5)

	hero.health_growth = hero_stats.get("health_growth", 10)
	hero.strength_growth = hero_stats.get("strength_growth", 3)
	# ... assume other growths

	hero._ready()
	player_party.append(hero)

	# Default Spawn
	setup_overworld_scene()

	switch_state(GameState.OVERWORLD)

func setup_overworld_scene():
	if overworld_root:
		overworld_root.queue_free()

	var overworld_scene = load("res://scenes/Overworld.tscn")
	if overworld_scene:
		overworld_root = overworld_scene.instantiate()
		add_child(overworld_root)

		var player = overworld_root.get_node("Player")
		if player:
			# Pass the overworld_root so the manager can scan for entities placed in the editor
			overworld_manager.setup(player, overworld_root)

			# Optional: Setup debug world only if no entities were found?
			# setup_debug_world now checks this internally
			overworld_manager.setup_debug_world()
		else:
			print("Error: Player node not found in Overworld scene.")
	else:
		print("Error: Could not load Overworld.tscn")

func _on_load_game():
	print("GameManager: Loading Game...")
	var loaded_party = SaveManager.load_from_file(save_filepath, overworld_manager)
	if not loaded_party.is_empty():
		player_party = loaded_party
		# For simplicity in this task, regenerate world or load it if we implemented world loading
		# We'll just reset world for now
		setup_overworld_scene()
		switch_state(GameState.OVERWORLD)
	else:
		print("GameManager: Load Failed or No Save File.")

func _on_options():
	switch_state(GameState.OPTIONS)

func _on_options_back():
	switch_state(GameState.MAIN_MENU)

func _on_encounter_triggered(entity_from_overworld: WorldEntity):
	print("GameManager: Encounter detected with %s! Starting Battle..." % entity_from_overworld.entity_id)
	start_battle(entity_from_overworld)

func start_battle(entity_source: WorldEntity = null):
	switch_state(GameState.BATTLE)
	active_battle_entity = entity_source

	# Create enemy Combatant from the Overworld Entity data
	var enemy = Enemy.new()

	if entity_source:
		# Copy stats from the persistent entity/database
		var stats = GameDatabase.get_base_stats(entity_source.type_id)
		enemy.unit_name = stats.get("name", "Enemy")

		# Load Stats
		enemy.max_health = stats.get("max_health", 10)
		enemy.max_mana = stats.get("max_mana", 0)
		enemy.strength = stats.get("strength", 10)
		enemy.agility = stats.get("agility", 10)
		enemy.defense = stats.get("defense", 0)
		enemy.resistance = stats.get("resistance", 0)
		enemy.intelligence = stats.get("intelligence", 0)
		enemy.faith = stats.get("faith", 0)
		enemy.unarmed_damage = stats.get("unarmed_damage", 1)

		# Load Growth
		enemy.health_growth = stats.get("health_growth", 0)
		enemy.mana_growth = stats.get("mana_growth", 0)
		enemy.strength_growth = stats.get("strength_growth", 0)
		enemy.agility_growth = stats.get("agility_growth", 0)
		enemy.defense_growth = stats.get("defense_growth", 0)
		enemy.resistance_growth = stats.get("resistance_growth", 0)
		enemy.intelligence_growth = stats.get("intelligence_growth", 0)
		enemy.faith_growth = stats.get("faith_growth", 0)

		enemy.exp_reward = stats.get("exp_reward", 0)
		enemy.exp_growth_factor = stats.get("exp_growth_factor", 1.2)
	else:
		# Fallback
		enemy.unit_name = "Wild Goblin"
		enemy.max_health = 30
		enemy.strength = 10
		enemy.unarmed_damage = 2
		enemy.exp_reward = 10

	enemy._ready() # Initialize stats

	# Override health with actual persistent health
	if entity_source:
		enemy.current_health = entity_source.current_health

	battle_manager.setup_battle(player_party, [enemy])

func _on_battle_ended(result):
	if result == BattleManager.BattleState.VICTORY:
		print("GameManager: Battle Won! returning to Overworld.")

		# Update the world entity state
		if active_battle_entity:
			print("GameManager: Marking entity %s as dead." % active_battle_entity.entity_id)
			active_battle_entity.is_dead = true
			active_battle_entity.current_health = 0
			active_battle_entity.set_loaded(false) # Hide it from view
			active_battle_entity = null

		switch_state(GameState.OVERWORLD)
	else:
		print("GameManager: Battle Lost! Game Over.")
		# Handle game over (reload, etc.)

# Input simulation hook
func simulate_input_move(direction: Vector2):
	if current_state == GameState.OVERWORLD:
		overworld_manager.attempt_move_player(direction)
	else:
		print("Cannot move in Overworld while in Battle!")

func simulate_input_battle_attack(target_index: int):
	if current_state == GameState.BATTLE:
		battle_ui.on_attack_button_pressed(target_index)
	else:
		print("Cannot attack while in Overworld!")

func simulate_input_interact():
	if current_state == GameState.OVERWORLD:
		overworld_manager.player_interact()
	else:
		print("Cannot interact while not in Overworld!")
