class_name BattleManager
extends Node

enum BattleState { SETUP, PLAYER_TURN, ENEMY_TURN, VICTORY, DEFEAT, ESCAPED }

var current_state = BattleState.SETUP
var player_party: Array[Combatant] = []
var enemy_party: Array[Combatant] = []
var exp_pool: int = 0

# Signals
signal state_changed(new_state)
signal battle_ended(result) # result: BattleState.VICTORY or BattleState.DEFEAT or ESCAPED

func _ready():
	# In a real scenario, you would populate parties here or inject them
	pass

func setup_battle(players: Array[Combatant], enemies: Array[Combatant]):
	player_party = players
	enemy_party = enemies
	exp_pool = 0

	# Connect signals for death handling
	for p in player_party:
		if not p.died.is_connected(_on_party_member_died):
			p.died.connect(_on_party_member_died)
	for e in enemy_party:
		if not e.died.is_connected(_on_enemy_died):
			e.died.connect(_on_enemy_died)

	change_state(BattleState.SETUP)
	start_battle()

func change_state(new_state):
	current_state = new_state
	state_changed.emit(current_state)
	print("Battle State Changed to: ", BattleState.keys()[current_state])

func start_battle():
	print("Battle Started!")
	change_state(BattleState.PLAYER_TURN)
	# Here you would typically notify the UI to enable player input

func end_turn():
	if current_state == BattleState.PLAYER_TURN:
		change_state(BattleState.ENEMY_TURN)
		process_enemy_turn()
	elif current_state == BattleState.ENEMY_TURN:
		change_state(BattleState.PLAYER_TURN)

func process_enemy_turn():
	print("Enemies are thinking...")
	# Simulate a slight delay or process sequentially
	for enemy in enemy_party:
		if enemy.is_alive():
			# We assume Enemy class has a choose_action method
			if enemy.has_method("choose_action"):
				enemy.choose_action(player_party)
			else:
				enemy.attack(player_party[0]) # Fallback

	# Check win/loss after turn
	if check_battle_end():
		return

	end_turn()

func _on_party_member_died():
	check_battle_end()

func _on_enemy_died():
	# Calculate XP from dead enemies?
	# Or just do it at the end. Let's do it at the end to avoid double counting if resurrected (not yet impl).
	# For now, we can just iterate the enemy party at victory.
	check_battle_end()

func check_battle_end() -> bool:
	var all_players_dead = true
	for p in player_party:
		if p.is_alive():
			all_players_dead = false
			break

	if all_players_dead:
		change_state(BattleState.DEFEAT)
		print("Game Over")
		battle_ended.emit(BattleState.DEFEAT)
		return true

	var all_enemies_dead = true
	for e in enemy_party:
		if e.is_alive():
			all_enemies_dead = false
			break

	if all_enemies_dead:
		change_state(BattleState.VICTORY)
		print("Victory!")
		distribute_experience()
		battle_ended.emit(BattleState.VICTORY)
		return true

	return false

func distribute_experience():
	# Calculate total exp
	var total_exp = 0
	for e in enemy_party:
		total_exp += e.exp_reward

	if total_exp > 0:
		print("Battle Yielded %d Total EXP." % total_exp)
		# Distribute evenly or full amount? Standard is full amount to each active member usually in modern, or split.
		# Let's give full amount to everyone for simplicity.
		for p in player_party:
			if p.is_alive():
				p.gain_exp(total_exp)

# Function called by UI when player selects an action
func player_action_attack(target_index: int):
	if current_state != BattleState.PLAYER_TURN:
		return

	var active_hero = get_active_hero() # Simplification: Assuming single hero or taking turns
	if active_hero and target_index < enemy_party.size():
		var target = enemy_party[target_index]
		if target.is_alive():
			active_hero.attack(target)
			if not check_battle_end():
				end_turn() # End turn after action

func player_action_flee():
	if current_state != BattleState.PLAYER_TURN:
		return

	# Simple 50% chance for now, or based on agility comparison
	var chance = 0.5
	if randf() < chance:
		print("Player successfully fled!")
		change_state(BattleState.ESCAPED)
		battle_ended.emit(BattleState.ESCAPED)
	else:
		print("Failed to flee!")
		end_turn()

func get_active_hero():
	# Simplification: Just getting the first alive hero
	for p in player_party:
		if p.is_alive():
			return p
	return null
