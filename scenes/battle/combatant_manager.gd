extends Node
class_name CombatantManager

signal combatant_spawned(actor: Actor, side: String)

class CombatantData:
	var actor: Actor
	var core_stat_hud: CoreStatsHUD
	var side: String
	var is_active: bool
	
	func _init(_actor: Actor, _side: String) -> void:
		actor = _actor
		side = _side
		is_active = false
		
var combatants: Dictionary = {}

func spawn_combatant(actor_name: String, side: String, spawn_position: Vector2) -> Actor:
	var new_actor: Actor = ActorFactory.spawn_actor(actor_name, self, spawn_position)
	var data: CombatantData = CombatantData.new(new_actor, side)
	combatants[new_actor] = data
	combatant_spawned.emit(new_actor, side)
	return new_actor
		
func register_combatant(actor: Actor	, side: String) -> void:
	var data: CombatantData = CombatantData.new(actor, side)
	
func get_data_for(actor: Actor) -> CombatantData:
	return combatants.get(actor)
