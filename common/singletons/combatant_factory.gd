extends Node

@onready var combatant_scene: PackedScene = load("res://common/components/combatant/combatant.tscn")

func spawn_combatant(combatant_id: String) -> Combatant:
	var new_combatant: Combatant = _instantiate_new_combatant_scene()
	var combatant_definition: Dictionary = _get_combatant_definition_from_registry(combatant_id)
	_set_combatant_definition(new_combatant, combatant_definition["data_def"])
	return new_combatant


func _instantiate_new_combatant_scene() -> Combatant:
	return combatant_scene.instantiate()

func _get_combatant_definition_from_registry(combatant_id: String) -> Dictionary:
	var combatant_definition: Dictionary = CombatantRegistry.get_entry(combatant_id)
	#if actor_entry.is_empty():
	#throw exception
	return combatant_definition

func _set_combatant_definition(combatant: Combatant, combatant_definition:CombatantDefinition) -> void:
	combatant.combatant_definition = combatant_definition
