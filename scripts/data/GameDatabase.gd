class_name GameDatabase
extends Node

# Dictionary holding base stats for all creatures/NPCs/Classes
# Based on ID map provided.

static var bestiary_stats = {
	"Hero_Cloud": {
		# Mocking stats based on generic hero (similar to SOLDADO or ALDEANO but better)
		"id": "0000",
		"name": "Cloud",
		"lvl_base": 1,
		"max_health": 100,
		"max_mana": 50,
		"strength": 25,
		"agility": 30,
		"defense": 20,
		"resistance": 20,
		"intelligence": 10,
		"faith": 5,
		"unarmed_damage": 5,
		"exp_growth_factor": 1.2,
		"exp_reward": 0,
		"is_enemy": false,
		# Growth
		"health_growth": 10,
		"mana_growth": 5,
		"strength_growth": 3,
		"agility_growth": 3,
		"defense_growth": 2,
		"resistance_growth": 2,
		"intelligence_growth": 1,
		"faith_growth": 0
	},
	"Goblin": {
		"id": "0001",
		"name": "Goblin Razo",
		"lvl_base": 1,
		"max_health": 45,
		"max_mana": 150, # As per image column MAGIA
		"strength": 20,
		"agility": 70,
		"defense": 15,
		"resistance": 100,
		"intelligence": 10,
		"faith": 5,
		"unarmed_damage": 5,
		"exp_growth_factor": 1.1,
		"exp_reward": 50,
		"is_enemy": true,
		# Growth
		"health_growth": 5,
		"mana_growth": 1, # MAGIAG
		"strength_growth": 2, # FUERZAG
		"agility_growth": 6, # AGILIDADG
		"defense_growth": 1, # DEFENSAG
		"resistance_growth": 10, # RESISTENCIAG
		"intelligence_growth": 1,
		"faith_growth": 0
	},
	"Villager": {
		"id": "0002",
		"name": "Aldeano",
		"lvl_base": 1,
		"max_health": 60,
		"max_mana": 20,
		"strength": 40,
		"agility": 50,
		"defense": 10,
		"resistance": 70,
		"intelligence": 30,
		"faith": 20,
		"unarmed_damage": 5,
		"exp_growth_factor": 1.3,
		"exp_reward": 100,
		"is_enemy": false,
		# Growth
		"health_growth": 6,
		"mana_growth": 2,
		"strength_growth": 5,
		"agility_growth": 6,
		"defense_growth": 1,
		"resistance_growth": 8,
		"intelligence_growth": 2,
		"faith_growth": 6
	},
	"Wolf": {
		"id": "0003",
		"name": "Lobo",
		"lvl_base": 1,
		"max_health": 60,
		"max_mana": 10,
		"strength": 45,
		"agility": 65,
		"defense": 35,
		"resistance": 65,
		"intelligence": 8,
		"faith": 0,
		"unarmed_damage": 10,
		"exp_growth_factor": 1.6,
		"exp_reward": 100,
		"is_enemy": true,
		# Growth
		"health_growth": 5,
		"mana_growth": 1,
		"strength_growth": 5,
		"agility_growth": 7,
		"defense_growth": 2,
		"resistance_growth": 5,
		"intelligence_growth": 1,
		"faith_growth": 0
	},
	"Rat": {
		"id": "0019",
		"name": "Rata",
		"lvl_base": 1,
		"max_health": 10,
		"max_mana": 1,
		"strength": 5,
		"agility": 30,
		"defense": 10,
		"resistance": 30,
		"intelligence": 1,
		"faith": 0,
		"unarmed_damage": 1,
		"exp_growth_factor": 1.25,
		"exp_reward": 50,
		"is_enemy": true,
		# Growth
		"health_growth": 2,
		"mana_growth": 1,
		"strength_growth": 1,
		"agility_growth": 3,
		"defense_growth": 1,
		"resistance_growth": 3,
		"intelligence_growth": 1,
		"faith_growth": 0
	}
}

static func get_base_stats(type_id: String) -> Dictionary:
	if bestiary_stats.has(type_id):
		return bestiary_stats[type_id].duplicate()
	else:
		push_error("Stats for " + type_id + " not found in GameDatabase.")
		return {}
