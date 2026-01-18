class_name BattleUI
extends Node

# References to UI elements
@export var status_label: Label
@export var action_menu: Control

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
		BattleManager.BattleState.PLAYER_TURN:
			update_status("Player Turn")
			if action_menu: action_menu.visible = true
			# show_action_menu()
		BattleManager.BattleState.ENEMY_TURN:
			update_status("Enemy Turn")
			if action_menu: action_menu.visible = false
			# hide_action_menu()
		BattleManager.BattleState.VICTORY:
			update_status("Victory!")
		BattleManager.BattleState.DEFEAT:
			update_status("Defeat!")

# Simulate button press
func on_attack_button_pressed(target_index: int):
	print("UI: Attack button pressed for target index ", target_index)
	battle_manager.player_action_attack(target_index)
