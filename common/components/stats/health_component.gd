class_name HealthComponent
extends Node

signal health_changed(current: int)
signal died

var current_health: int
var _starting_health: int # Stored for "Reset/Heal to Full" logic

func initialize(data: CoreStats) -> void:
	_starting_health = data.starting_health
	current_health = _starting_health
	health_changed.emit(current_health)

func modify_health(amount: int) -> void:
	current_health += amount
	health_changed.emit(current_health)
	if current_health <= 0:
		died.emit()

func reset_to_starting() -> void:
	current_health = _starting_health
	health_changed.emit(current_health)
