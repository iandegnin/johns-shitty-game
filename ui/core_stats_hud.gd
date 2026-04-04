extends MarginContainer
class_name CoreStatsHUD

var _target_actor: Actor
var _resource_bars: Dictionary = {}

@export var health_bar: ResourceBar
@export var stamina_bar: ResourceBar
@export var mana_bar: ResourceBar

func _ready() -> void:
	_resource_bars = {
		StatTypes.CoreStatType.HEALTH: health_bar,
		StatTypes.CoreStatType.STAMINA: stamina_bar,
		StatTypes.CoreStatType.MANA: mana_bar,
		}

func assign_actor(actor: Actor) -> void:
	_clean_signals()
	_target_actor = actor
	
	for stat_type: StatTypes.CoreStatType in _resource_bars:
		var bar: ResourceBar = _resource_bars[stat_type]
		if bar and is_instance_valid(_target_actor.stat_controller):
			update_resource(bar, _target_actor.get_current_resource(stat_type))
	
	if not actor.stat_changed.is_connected(_on_actor_stat_changed):
		actor.stat_changed.connect(_on_actor_stat_changed)
	
	if not actor.died.is_connected(_on_actor_died):
		actor.died.connect(_on_actor_died)
			
func toggle_combatant_stats() -> void:
	if not is_instance_valid(_target_actor):
		if health_bar: health_bar.toggle_all_pips(false)
	
func update_resource(resource_bar: ResourceBar, value: int) -> void:
	resource_bar.update_bar(value)
	
func _clean_signals() -> void:
	if _target_actor and is_instance_valid(_target_actor):
		if _target_actor.stat_changed.is_connected(_on_actor_stat_changed):
			_target_actor.stat_changed.disconnect(_on_actor_stat_changed)
		
		if _target_actor.died.is_connected(_on_actor_died):
			_target_actor.died.disconnect(_on_actor_died)
		
	
func _on_actor_stat_changed(type: StatTypes.CoreStatType, new_value: int) -> void:
	var resource_bar: ResourceBar = _resource_bars.get(type)
	if resource_bar:
		update_resource(resource_bar, new_value)

func _on_actor_died(_actor: Actor) -> void:
	_clean_signals()
	_target_actor = null
