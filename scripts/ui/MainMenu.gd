class_name MainMenu
extends Node

signal new_game
signal load_game
signal options

func _ready():
	# In a real scene, this would connect buttons
	print("MainMenu: Ready")

# Simulated Button Presses
func on_new_game_pressed():
	print("MainMenu: New Game Pressed")
	new_game.emit()

func on_load_game_pressed():
	print("MainMenu: Load Game Pressed")
	load_game.emit()

func on_options_pressed():
	print("MainMenu: Options Pressed")
	options.emit()
