@tool
extends EditorPlugin


func _enter_tree()->void:
	# Initialization of the plugin goes here.
	add_autoload_singleton("HeatSimulationServer","res://addons/heatsystem/HeatSimulationServer.gd")
	add_custom_type("HeatObject","Resource",preload("res://addons/heatsystem/HeatObject.gd"),preload("res://addons/heatsystem/heatobj.png"))


func _exit_tree()->void:
	# Clean-up of the plugin goes here.
	remove_autoload_singleton("HeatSimulationServer")
	remove_custom_type("HeatObject")
