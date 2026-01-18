class_name Hero
extends Combatant

# Skills or other specific hero properties can be added here
@export var mana: int = 50

func _ready():
	super._ready()
	unit_name = "Hero"

func heal(target: Combatant):
	if mana >= 10:
		mana -= 10
		# Simple heal logic
		target.current_health = min(target.current_health + 20, target.max_health)
		target.health_changed.emit(target.current_health, target.max_health)
		print("%s healed %s for 20 HP. Mana left: %d" % [unit_name, target.unit_name, mana])
	else:
		print("Not enough mana!")
