class_name ActorDefinition
extends Resource

@export_group("Identity")
@export var name: String = ""

@export_group("Required")
@export var visuals: ActorVisuals
@export var core_stats: CoreStats

@export_group("Optional")
@export var specialized_stats: Resource
