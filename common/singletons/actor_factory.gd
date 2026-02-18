extends Node

var actor_registry: Dictionary = {"slime" : preload("res://entities/actors/slime/res_slime.tres")}

func spawn_actor(actor_id: String, parent: Node2D, spawn_pos: Vector2) -> Node2D:
	if not actor_registry.has(actor_id):
		printerr("Fail: Actor ID ", actor_id, " not in registry.")
		return null
		
	var data: ActorResource = actor_registry[actor_id]
	var path: String = "res://entities/actors/%s/%s.tscn" % [actor_id, actor_id]
	
	var scene: PackedScene = load(path) as PackedScene
	if not scene:
		printerr("Fail: Could not load scene at ", path)
		return null
	
	var entity: Node2D = scene.instantiate() as Node2D
	if not entity:
		printerr("Fail: ", path, " root node is not a Node2D.")
		return null
		
	entity.global_position = spawn_pos
	parent.add_child(entity)
	
	var component: ActorComponent = entity.get_node_or_null("ActorComponent") as ActorComponent
	if component:
		component.initialize(data)
		
	return entity
