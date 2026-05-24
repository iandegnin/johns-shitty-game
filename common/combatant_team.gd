class_name CombatantTeam
extends Node

signal combatant_added(combatant: Combatant)
signal combatant_activated(active_combatant: Combatant)

var roster: Array[Combatant] = []
var active_combatant: Combatant

func add_combatant(combatant: Combatant) -> void:
	roster.append(combatant)
	print("Combatant added: ", combatant.get_name())
	if active_combatant == null or combatant.is_active:
		set_active(combatant)
	combatant_added.emit(combatant)

func set_active(combatant: Combatant) -> void:
	if active_combatant:
		print("Removing ", active_combatant, " as active combatant")
	if combatant in roster:
		active_combatant = combatant
		combatant_activated.emit(combatant)
	print("Combatant set to active: ", combatant.get_name())
