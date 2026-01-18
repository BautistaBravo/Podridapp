class_name SaveManager
extends Node

# Handles serialization and deserialization of the game state

static func save_game(party: Array[Combatant], overworld_manager: OverworldManager) -> Dictionary:
	print("--- Saving Game ---")
	var save_data = {}

	# 1. Save Party
	var party_data = []
	for member in party:
		var mem_data = {
			"unit_name": member.unit_name,
			"current_health": member.current_health,
			"max_health": member.max_health,
			# Save type if we had it, for now assume name maps to type or is custom
			# Ideally Combatant should have a 'type_id' too.
		}
		# Handle specific Hero properties
		if member is Hero:
			mem_data["mana"] = member.mana
			mem_data["class"] = "Hero" # Simple tag

		party_data.append(mem_data)
	save_data["party"] = party_data

	# 2. Save Overworld Entities
	var entities_data = []
	for entity in overworld_manager.active_entities:
		entities_data.append(entity.serialize())
	save_data["overworld_entities"] = entities_data

	# 3. Save Player Position
	if overworld_manager.player:
		save_data["player_position_x"] = overworld_manager.player.grid_position.x
		save_data["player_position_y"] = overworld_manager.player.grid_position.y

	print("Game Saved.")
	return save_data

static func load_game(save_data: Dictionary, overworld_manager: OverworldManager) -> Array[Combatant]:
	print("--- Loading Game ---")

	# 1. Load Party
	var loaded_party: Array[Combatant] = []
	var party_data = save_data.get("party", [])

	for mem_data in party_data:
		var unit
		if mem_data.get("class") == "Hero":
			unit = Hero.new()
			unit.mana = mem_data["mana"]
		else:
			# Fallback or generic
			unit = Hero.new()

		unit.unit_name = mem_data["unit_name"]
		unit.max_health = mem_data["max_health"]
		unit.current_health = mem_data["current_health"]
		unit._ready() # Re-init if needed
		# Override current health again in case _ready reset it
		unit.current_health = mem_data["current_health"]

		loaded_party.append(unit)

	# 2. Load Overworld Entities
	overworld_manager.active_entities.clear()
	var entities_data = save_data.get("overworld_entities", [])
	for e_data in entities_data:
		var entity = WorldEntity.deserialize(e_data)
		overworld_manager.add_entity(entity)

	# 3. Load Player Position
	if overworld_manager.player:
		var x = save_data.get("player_position_x", 0)
		var y = save_data.get("player_position_y", 0)
		overworld_manager.player.grid_position = Vector2(x, y)
		# Force update visibility based on new position
		overworld_manager.check_entity_visibility()

	print("Game Loaded.")
	return loaded_party

static func save_to_file(filepath: String, party: Array[Combatant], overworld_manager: OverworldManager):
	var data = save_game(party, overworld_manager)
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()
		print("Saved to file: " + filepath)
	else:
		push_error("Failed to open file for saving: " + filepath)

static func load_from_file(filepath: String, overworld_manager: OverworldManager) -> Array[Combatant]:
	if not FileAccess.file_exists(filepath):
		print("Save file not found: " + filepath)
		return []

	var file = FileAccess.open(filepath, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			return load_game(data, overworld_manager)
		else:
			print("JSON Parse Error: ", json.get_error_message())
			return []
	else:
		print("Failed to open file for loading.")
		return []
