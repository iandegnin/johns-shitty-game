extends MarginContainer
class_name CoreStatsHUD

var _target_actor: Actor

@export var health_bar: ResourceBar
@export var stamina_bar: ResourceBar
@export var mana_bar: ResourceBar

func assign_actor(actor: Actor) -> void:
	if _target_actor and is_instance_valid(_target_actor):
		if _target_actor.health_changed.is_connected(_on_actor_health_changed):
			_target_actor.health_changed.disconnect(_on_actor_health_changed)
		if _target_actor.died.is_connected(_on_actor_died):
			_target_actor.died.disconnect(_on_actor_died)
	_target_actor = actor
	
	if health_bar and actor.stat_controller:
		update_health(actor.get_current_health())
	
	if not actor.health_changed.is_connected(_on_actor_health_changed):
		actor.health_changed.connect(_on_actor_health_changed)
		
	if not actor.died.is_connected(_on_actor_died):
		actor.died.connect(_on_actor_died)
	
	update_health(_target_actor.get_current_health())
		
func _on_actor_health_changed(new_health: int) -> void:
	if _target_actor:
		update_health(new_health)

func _on_actor_died(_actor: Actor) -> void:
	_target_actor = null
	
func update_health(health: int) -> void:
	health_bar.update_bar(health)

func update_stamina(stamina: int) -> void:
	stamina_bar.update_bar(stamina)

func update_mana(mana: int) -> void:
	mana_bar.update_bar(mana)
