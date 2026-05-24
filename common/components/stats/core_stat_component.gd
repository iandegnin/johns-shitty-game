class_name CoreStatComponent
extends Node

signal value_changed(current: int, type: CoreStats.CoreStatType)
signal depleted(type: CoreStats.CoreStatType)

signal component_initialized(current: int)

@export_group("Identity")
@export var stat_type: CoreStats.CoreStatType

@export_group("Settings")
@export var min_value: int = 0
@export var is_lethal: bool = false

@export_group("Current")
@export var current: int = 0

func initialize(value: int) -> void:
	current = value
	value_changed.emit(stat_type, current)

func modify(amount: int) -> void:
	current = current + amount
	value_changed.emit(stat_type, current)
	
	if current <= 0:
		depleted.emit(stat_type)
