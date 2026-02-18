class_name StaminaComponent
extends Node

signal stamina_changed(current: int)
signal stamina_depleted

var current_stamina: int = 0

func initialize(data: BaseStats) -> void:
	current_stamina = data.starting_stamina
	stamina_changed.emit(current_stamina)

func consume(amount: int) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		stamina_changed.emit(current_stamina)
		if current_stamina <= 0:
			stamina_depleted.emit()
		return true
	return false

func restore(amount: int) -> void:
	current_stamina += amount
	stamina_changed.emit(current_stamina)
