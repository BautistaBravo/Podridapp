class_name BattleUI
extends Node

# References to UI elements
@export var status_label: Label
@export var action_menu: Control
@export var player_container: Control
@export var enemy_container: Control

var battle_manager: BattleManager

func setup(manager: BattleManager):
	battle_manager = manager
	if not battle_manager.state_changed.is_connected(_on_battle_state_changed):
		battle_manager.state_changed.connect(_on_battle_state_changed)

	# Initial UI update
	print("UI Setup Complete")
	update_status("Waiting for Battle...")

func update_status(text: String):
	if status_label:
		status_label.text = text
	print("UI Status: ", text)

func _on_battle_state_changed(new_state):
	match new_state:
		BattleManager.BattleState.SETUP:
			update_status("Setting up Battle...")
			generate_combatant_visuals(battle_manager.player_party, battle_manager.enemy_party)
		BattleManager.BattleState.PLAYER_TURN:
			update_status("Player Turn")
			if action_menu: action_menu.visible = true
		BattleManager.BattleState.ENEMY_TURN:
			update_status("Enemy Turn")
			if action_menu: action_menu.visible = false
		BattleManager.BattleState.VICTORY:
			update_status("Victory!")
		BattleManager.BattleState.DEFEAT:
			update_status("Defeat!")
		BattleManager.BattleState.ESCAPED:
			update_status("Escaped!")

func generate_combatant_visuals(players: Array, enemies: Array):
	# Clear existing
	if player_container:
		for child in player_container.get_children():
			child.queue_free()
	if enemy_container:
		for child in enemy_container.get_children():
			child.queue_free()

	# Create Player Visuals
	if player_container:
		for p in players:
			var panel = create_combatant_panel(p, Color(0.2, 0.2, 0.8))
			player_container.add_child(panel)

	# Create Enemy Visuals
	if enemy_container:
		for e in enemies:
			var panel = create_combatant_panel(e, Color(0.8, 0.2, 0.2))
			enemy_container.add_child(panel)

func create_combatant_panel(combatant, color: Color) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(150, 60)

	# Background style
	var style = StyleBoxFlat.new()
	style.bg_color = color
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.layout_mode = 1 # Anchors Layout
	vbox.anchors_preset = 15 # Full Rect
	panel.add_child(vbox)

	var name_lbl = Label.new()
	name_lbl.text = combatant.unit_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	var hp_lbl = Label.new()
	hp_lbl.text = "HP: %d/%d" % [combatant.current_health, combatant.max_health]
	hp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hp_lbl)

	return panel

# Simulate button press
func on_attack_button_pressed(target_index: int):
	print("UI: Attack button pressed for target index ", target_index)
	battle_manager.player_action_attack(target_index)

func on_flee_button_pressed():
	print("UI: Flee button pressed")
	battle_manager.player_action_flee()
