class_name OverworldPlayer
extends Node2D

@export var move_speed: float = 200.0

var is_active: bool = false
var manager = null

func _ready():
	# Create a visual representation
	var visual = ColorRect.new()
	visual.color = Color(0, 0, 1) # Blue
	visual.size = Vector2(32, 32)
	visual.position = Vector2(-16, -16) # Center it
	add_child(visual)

	# Start inactive by default, enabled by GameManager
	set_active(false)

func set_active(state: bool):
	is_active = state
	set_process(is_active)
	set_process_unhandled_input(is_active)

func _process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	if direction.length() > 0:
		direction = direction.normalized()
		position += direction * move_speed * delta

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"): # Space / Enter
		if manager and manager.has_method("player_interact"):
			manager.player_interact()
