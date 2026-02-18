extends Node

func spawn_actor(actor_id: String, parent: Node, spawn_pos: Vector2) -> Actor:
	# Access the Singleton directly
	var entry: Dictionary = ActorRegistry.get_entry(actor_id)
	
	if entry.is_empty():
		return null

	var data: ActorDefinition = entry["data"]
	var scene: PackedScene = entry["scene"]

	# 1. Instance the scene
	var new_actor: Actor = scene.instantiate()
	
	# 2. Add to tree BEFORE initializing so @onready variables are valid
	parent.add_child(new_actor)
	new_actor.global_position = spawn_pos
	
	# 3. Inject the data
	new_actor.initialize(data)
	
	return new_actor
