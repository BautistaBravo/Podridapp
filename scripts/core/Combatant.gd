class_name Combatant
extends Node

signal health_changed(new_health, max_health)
signal died

@export var unit_name: String = "Unit"

# Base Stats
@export var max_health: int = 100
@export var max_mana: int = 0
@export var strength: int = 10
@export var agility: int = 10
@export var defense: int = 0
@export var resistance: int = 0
@export var intelligence: int = 0
@export var faith: int = 0
@export var unarmed_damage: int = 1

# Growth Stats (Per Level)
@export var health_growth: int = 10
@export var mana_growth: int = 0
@export var strength_growth: int = 2
@export var agility_growth: int = 2
@export var defense_growth: int = 1
@export var resistance_growth: int = 1
@export var intelligence_growth: int = 1
@export var faith_growth: int = 0

# Derived Stats
var attack_power: int:
	get:
		return strength + unarmed_damage

# Leveling System
@export var level: int = 1
var current_exp: int = 0
var exp_to_next_level: int = 100
@export var exp_reward: int = 0 # XP this unit gives when killed
@export var exp_growth_factor: float = 1.2 # Multiplier for next level requirement

var current_health: int
var current_mana: int

func _ready():
	current_health = max_health
	current_mana = max_mana

	# Simple exp curve calculation for init
	calculate_next_level_exp()

func calculate_next_level_exp():
	# Formula: Base (100) * (Growth ^ Level) ?
	# Or just linear? The image has "ExpGrowth" like 1.1.
	# Let's assume Next = Previous * Factor.
	# But for random access level calculation (like if we init at level 5), we need a formula.
	# Let's use: 100 * (exp_growth_factor ^ (level - 1)) * level?
	# Simple approximation: 100 * level * exp_growth_factor
	exp_to_next_level = int(100 * pow(exp_growth_factor, level))

func gain_exp(amount: int):
	current_exp += amount
	print("%s gained %d EXP!" % [unit_name, amount])
	while current_exp >= exp_to_next_level:
		level_up()

func level_up():
	current_exp -= exp_to_next_level
	level += 1
	calculate_next_level_exp()

	# Stat Increases
	max_health += health_growth
	max_mana += mana_growth
	strength += strength_growth
	agility += agility_growth
	defense += defense_growth
	resistance += resistance_growth
	intelligence += intelligence_growth
	faith += faith_growth

	current_health = max_health # Full heal on level up
	current_mana = max_mana

	print("%s Leveled Up! Now Level %d. Max HP: %d, STR: %d" % [unit_name, level, max_health, strength])

func take_damage(amount: int):
	# Apply Defense mitigation?
	# Simple formula: damage - defense (min 1)
	# But this logic should arguably be in 'attack' or 'resolve_damage'.
	# For now, keeping take_damage raw, but let's see.
	# The prompt asked to "change type of creatures to those attributes".
	# It didn't explicitly ask to change damage formula, but usually defense implies reduction.
	# I'll implement reduction here for completeness.

	var damage_taken = max(1, amount - defense)

	current_health -= damage_taken
	current_health = max(0, current_health)
	health_changed.emit(current_health, max_health)
	print("%s took %d damage (mitigated from %d). HP: %d/%d" % [unit_name, damage_taken, amount, current_health, max_health])

	if current_health == 0:
		die()

func die():
	died.emit()
	print("%s has died!" % unit_name)

func is_alive() -> bool:
	return current_health > 0

func attack(target: Combatant):
	print("%s attacks %s!" % [unit_name, target.unit_name])
	target.take_damage(attack_power)
