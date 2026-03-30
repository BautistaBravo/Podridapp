class_name Enemy
extends Combatant

func _ready():
	super._ready()
	unit_name = "Enemy"

func choose_action(player_party: Array):
	# Simple AI: Attack a random player
	if player_party.is_empty():
		return

	var target = player_party.pick_random()
	if target and target.is_alive():
		attack(target)
