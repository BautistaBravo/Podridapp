class_name OptionsMenu
extends Node

signal back

func _ready():
	print("OptionsMenu: Ready")

func on_back_pressed():
	print("OptionsMenu: Back Pressed")
	back.emit()
