class_name CombatantDefinition
extends Resource

@export_group("Required")
@export var name: String = ""
@export var visuals: CombatantVisuals
@export var core_stats: CoreStats

@export_group("Optional")
@export var specialized_stats: Resource
