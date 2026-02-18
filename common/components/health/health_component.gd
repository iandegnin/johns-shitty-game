extends Node
class_name HealthComponent

signal health_changed(current: int)
signal hit_received
signal died

@export var current_health: int = 3:
	set(value):
		current_health = max(0, value)
		health_changed.emit(current_health)
		if current_health <= 0:
			died.emit()

func damage(amount: int) -> void:
	current_health -= amount
	hit_received.emit()

func heal(amount: int) -> void:
	current_health += amount
