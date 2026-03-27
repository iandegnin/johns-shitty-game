extends Node

@onready var base_actor_scene: PackedScene = load("res://common/components/actor/base_actor.tscn")

func spawn_actor(actor_id: String, parent: Node, spawn_pos: Vector2) -> BaseActor:
	
	var actor_entry: Dictionary = ActorRegistry.get_entry(actor_id)
	if actor_entry.is_empty(): return null

	var actor_data: ActorDefinition = actor_entry["data_def"]
	var new_actor: BaseActor = base_actor_scene.instantiate()
	
	new_actor.actor_data = actor_data
	
	parent.add_child(new_actor)
	new_actor.global_position = spawn_pos
	
	return new_actor
