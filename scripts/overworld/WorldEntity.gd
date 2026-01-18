class_name WorldEntity
extends Node2D

# Represents an entity in the overworld that persists
# This class holds the STATE of the entity.

var entity_id: String
var type_id: String # Key for GameDatabase
# Position is handled by Node2D
var is_loaded: bool = false # Is in player vision?

# Persistent stats that might differ from base (e.g., took damage previously)
var current_health: int
var is_dead: bool = false
var is_enemy: bool = false # Loaded from stats

func _init(p_id: String = "", p_type: String = "", p_pos: Vector2 = Vector2.ZERO):
	entity_id = p_id
	type_id = p_type
	position = p_pos

	# Load base stats to init
	var stats = GameDatabase.get_base_stats(type_id)
	if not stats.is_empty():
		current_health = stats["max_health"]
		is_enemy = stats.get("is_enemy", false)
	else:
		current_health = 1
		is_enemy = false

func _ready():
	# Visual representation
	var visual = ColorRect.new()
	visual.size = Vector2(32, 32)
	visual.position = Vector2(-16, -16)
	if is_enemy:
		visual.color = Color(1, 0, 0) # Red
	else:
		visual.color = Color(0, 1, 0) # Green
	add_child(visual)

func set_loaded(state: bool):
	if is_loaded != state:
		is_loaded = state
		visible = is_loaded # Toggle visibility
		if is_loaded:
			print("Entity %s (%s) Loaded into vision at %s" % [entity_id, type_id, position])
		else:
			print("Entity %s (%s) Unloaded from vision" % [entity_id, type_id])

func serialize() -> Dictionary:
	return {
		"entity_id": entity_id,
		"type_id": type_id,
		"position_x": position.x,
		"position_y": position.y,
		"current_health": current_health,
		"is_dead": is_dead
	}

static func deserialize(data: Dictionary) -> WorldEntity:
	var entity = WorldEntity.new(
		data["entity_id"],
		data["type_id"],
		Vector2(data["position_x"], data["position_y"])
	)
	entity.current_health = data["current_health"]
	entity.is_dead = data["is_dead"]
	return entity
