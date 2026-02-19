class_name ManaComponent
extends Node

signal mana_changed(current: int)

var current_mana: int

func initialize(data: CoreStats) -> void:
	current_mana = data.starting_mana
	mana_changed.emit(current_mana)

func consume(amount: int) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		mana_changed.emit(current_mana)
		return true
	return false

func restore(amount: int) -> void:
	current_mana += amount
	mana_changed.emit(current_mana)
