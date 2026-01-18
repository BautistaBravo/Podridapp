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

func setup(p_player: OverworldPlayer):
	player = p_player
	# Ensure player has reference to manager for input handling
	if player and "manager" in player:
		player.manager = self
	print("Overworld Manager Initialized")

func add_entity(entity: WorldEntity):
	active_entities.append(entity)
	check_entity_visibility()

func attempt_move_player(direction: Vector2):
	# Deprecated: Player moves itself now via _process
	# But we can still keep this for external control
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
	# Create a goblin
	# Placing it to the right of the player (Player is at 576, 324)
	var goblin = WorldEntity.new("goblin_1", "Goblin", Vector2(700, 324))

	# Add to scene tree as sibling of player if possible
	if player and player.get_parent():
		player.get_parent().add_child(goblin)
		add_entity(goblin)
		print("Debug World Setup: Goblin added at (700, 324)")
	else:
		print("Error: Player parent not found, cannot add entities to scene.")
