extends MarginContainer
class_name CoreStatsHUD

var _assigned_combatants: Array[Combatant]
var _active_combatant: Combatant

var _resource_bars: Dictionary = {}

@export var active_health_bar: ResourceBar
@export var active_stamina_bar: ResourceBar
@export var active_mana_bar: ResourceBar

@export var health_color: Color = Color("RED")
@export var stamina_color: Color = Color("GREEN")
@export var mana_color: Color = Color("BLUE")

var active_combatant_health: int:
	get:
		return _active_combatant.health_component.current as int
		
var active_combatant_stamina: int:
	get:
		return _active_combatant.stamina_component.current as int

var active_combatant_mana: int:
	get:
		return _active_combatant.mana_component.current as int
	
func _ready() -> void:
	var resource_bars: Array = [active_health_bar, active_stamina_bar, active_mana_bar]
	_resource_bars = {
		CoreStats.CoreStatType.HEALTH: active_health_bar,
		CoreStats.CoreStatType.STAMINA: active_stamina_bar,
		CoreStats.CoreStatType.MANA: active_mana_bar,
		}
		
	active_health_bar.modulate = health_color
	active_stamina_bar.modulate = stamina_color
	active_mana_bar.modulate = mana_color
	self.visible = false
	
func assign_combatant(combatant: Combatant) -> void:
	_assigned_combatants.append(combatant)
	
func activate_combatant(combatant: Combatant) -> void:
	_active_combatant = combatant
	
func update_resource(resource_bar: ResourceBar, value: int) -> void:
	resource_bar.update_bar(value)

func toggle_combatant_stats() -> void:
	if not is_instance_valid(_active_combatant):
		if active_health_bar: active_health_bar.toggle_all_pips(false)
		if active_stamina_bar: active_stamina_bar.toggle_all_pips(false)
		if active_mana_bar: active_mana_bar.toggle_all_pips(false)
	else:
		if active_health_bar: active_health_bar.toggle_all_pips(true)
		if active_stamina_bar: active_stamina_bar.toggle_all_pips(true)
		if active_mana_bar: active_mana_bar.toggle_all_pips(true)
	
func _on_combatant_stat_changed(type: CoreStats.CoreStatType, new_value: int) -> void:
	var resource_bar: ResourceBar = _resource_bars.get(type)
	if resource_bar:
		update_resource(resource_bar, new_value)	

func _on_combatant_died(_combatant: Combatant) -> void:
	_active_combatant = null
	self.visible = false
	
func _on_combatant_team_new_combatant(new_combatant: Combatant) -> void:
	_assigned_combatants.append(new_combatant)
	
func _on_combatant_team_new_active_combatant(new_combatant: Combatant) -> void:
	_active_combatant = new_combatant
	self.visible = true
	update_resource(active_health_bar, active_combatant_health)
	update_resource(active_stamina_bar, active_combatant_stamina)
	update_resource(active_mana_bar, active_combatant_mana)
	_active_combatant.resource_changed.connect(_on_combatant_stat_changed)
	_active_combatant.died.connect(_on_combatant_died)
	self.visible = true
