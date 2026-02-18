class_name ActorDefinition
extends Resource

@export_group("Identity")
@export var actor_name: String = ""

@export_group("Required")
@export var visuals: VisualsConfig
@export var base_stats: BaseStats

@export_group("Optional")
## Only populate this if the actor needs specialized attributes (e.g., Strength, Intellect)
@export var specialized_stats: Resource
