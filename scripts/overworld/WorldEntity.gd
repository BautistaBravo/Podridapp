class_name WorldEntity
extends Node2D

# Represents an entity in the overworld that persists
# This class holds the STATE of the entity.

@export var entity_id: String = ""
@export var type_id: String = "Goblin" # Default for testing

var is_loaded: bool = false # Is in player vision?

# Persistent stats that might differ from base (e.g., took damage previously)
var current_health: int
var is_dead: bool = false
var is_enemy: bool = false # Loaded from stats

func _ready():
	# If no ID provided, generate a random one (for editor placed entities)
	if entity_id == "":
		entity_id = "entity_" + str(get_instance_id())

	# Load base stats to init
	var stats = GameDatabase.get_base_stats(type_id)
	if not stats.is_empty():
		current_health = stats.get("max_health", 10)
		is_enemy = stats.get("is_enemy", false)
	else:
		current_health = 1
		is_enemy = false

	# Visual representation
	# In a real game, you might use a Sprite2D and set the texture based on type_id
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
	var entity = WorldEntity.new()
	entity.entity_id = data["entity_id"]
	entity.type_id = data["type_id"]
	entity.position = Vector2(data["position_x"], data["position_y"])
	entity.current_health = data["current_health"]
	entity.is_dead = data["is_dead"]
	return entity
