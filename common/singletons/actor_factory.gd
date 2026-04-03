extends Node

@onready var actor_scene: PackedScene = load("res://common/components/actor/actor.tscn")

func spawn_actor(actor_id: String, parent: Node, spawn_position: Vector2) -> Actor:
	var new_actor: Actor = _instantiate_new_actor_scene()
	var actor_definition: Dictionary = _get_actor_definition_from_registry(actor_id)

	_set_actor_definition(new_actor, actor_definition["data_def"])
	_add_actor_to_parent(new_actor, parent)
	_set_actor_position(new_actor, spawn_position)
	
	return new_actor

func _instantiate_new_actor_scene() -> Actor:
	return actor_scene.instantiate()

func _get_actor_definition_from_registry(actor_id: String) -> Dictionary:
	var actor_definition: Dictionary = ActorRegistry.get_entry(actor_id)
	#if actor_entry.is_empty():
	#throw exception
	return actor_definition

func _set_actor_definition(actor: Actor, actor_definition:ActorDefinition) -> void:
	actor.actor_definition = actor_definition

func _add_actor_to_parent(child: Actor, parent: Node) -> void:
	parent.add_child(child)
	
func _set_actor_position(actor: Actor, spawn_position: Vector2) -> void:
	actor.global_position = spawn_position
	
