class_name OverworldManager
extends Node

signal encounter_triggered(entity)

var player: OverworldPlayer
# Encounter rate in percentage (0-100) or steps? Let's use steps or probability.
@export var encounter_chance_percent: int = 0

# List of all logical entities in the world
var active_entities: Array[WorldEntity] = []
# Range at which entities are "loaded" into the scene
var load_distance: float = 300.0

func setup(p_player: OverworldPlayer, root_node: Node = null):
	player = p_player
	# Ensure player has reference to manager for input handling
	if player and "manager" in player:
		player.manager = self

	# Scan for entities if a root node is provided
	if root_node:
		scan_entities(root_node)

	print("Overworld Manager Initialized. Active Entities: ", active_entities.size())

func scan_entities(root_node: Node):
	active_entities.clear()
	# Recursive search or just direct children?
	# For now, let's assume they are direct children or children of an "Entities" node
	# But recursive is safer.
	_recursive_find_entities(root_node)

func _recursive_find_entities(node: Node):
	if node is WorldEntity:
		add_entity(node)

	for child in node.get_children():
		_recursive_find_entities(child)

func add_entity(entity: WorldEntity):
	if not active_entities.has(entity):
		active_entities.append(entity)
		check_entity_visibility()

func attempt_move_player(direction: Vector2):
	if player:
		# player.move(direction)
		check_entity_visibility()

func player_interact():
	if not player:
		return

	print("Player Interact Triggered at %s" % player.position)

	for entity in active_entities:
		if entity.is_loaded and not entity.is_dead:
			var dist = player.position.distance_to(entity.position)
			# Interaction range: 50 pixels
			if dist < 50.0:
				print("Interacted with %s" % entity.entity_id)
				if entity.is_enemy:
					encounter_triggered.emit(entity)
					return
				else:
					print("Just a friendly entity.")

func check_entity_visibility():
	if not player:
		return

	for entity in active_entities:
		if entity.is_dead:
			entity.set_loaded(false)
			continue

		var dist = player.position.distance_to(entity.position)
		if dist <= load_distance:
			entity.set_loaded(true)
		else:
			entity.set_loaded(false)

func setup_debug_world():
	# Legacy/Manual fallback
	if active_entities.size() == 0 and player and player.get_parent():
		print("No entities found in scene, creating debug Goblin.")
		var goblin = WorldEntity.new()
		goblin.entity_id = "goblin_debug"
		goblin.type_id = "Goblin"
		goblin.position = Vector2(700, 324)

		player.get_parent().add_child(goblin)
		add_entity(goblin)
