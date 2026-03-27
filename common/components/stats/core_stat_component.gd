class_name StatComponent
extends Node

signal value_changed(current: int)
signal depleted

@export_group("Identity")
@export var stat_name: String = "Stat" # Set this to "Health" etc. in the Inspector

@export_group("Settings")
@export var min_value: int = 0
@export var is_lethal: bool = false

@export_group("Runtime State")
@export var current: int = 0

func initialize(value: int) -> void:
	current = value
	value_changed.emit(current)

func modify(amount: int) -> void:
#	current = clampi(current + amount, min_value, 999999) 
	current = current + amount
	value_changed.emit(current)
	
	if current <= min_value:
		depleted.emit()
