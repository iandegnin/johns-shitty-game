class_name CoreStatComponent
extends Node

signal value_changed(current: int)
signal component_initialized(current: int)
signal depleted

@export_group("Identity")
@export var stat_name: String = "Stat"

@export_group("Settings")
@export var min_value: int = 0
@export var is_lethal: bool = false

@export_group("Runtime State")
@export var current: int = 0

func initialize(value: int) -> void:
	current = value
	value_changed.emit(current)

func modify(amount: int) -> void:
	current = current + amount
	value_changed.emit(current)
	
	if current <= 0:
		depleted.emit()
