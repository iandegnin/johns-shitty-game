extends MarginContainer
class_name CoreStatsHUD

var _assigned_combatants: Array[Combatant]
var _active_combatant: Combatant

var _resource_bars: Dictionary = {}

@export var health_bar: ResourceBar
@export var stamina_bar: ResourceBar
@export var mana_bar: ResourceBar

@export var health_color: Color = Color("RED")
@export var stamina_color: Color = Color("GREEN")
@export var mana_color: Color = Color("BLUE")

func _ready() -> void:
	var resource_bars: Array = [health_bar, stamina_bar, mana_bar]
	_resource_bars = {
		CoreStats.CoreStatType.HEALTH: health_bar,
		CoreStats.CoreStatType.STAMINA: stamina_bar,
		CoreStats.CoreStatType.MANA: mana_bar,
		}
		
	health_bar.modulate = health_color
	stamina_bar.modulate = stamina_color
	mana_bar.modulate = mana_color
	self.visible = false
	
func assign_combatant(combatant: Combatant) -> void:
	_assigned_combatants.append(combatant)
	
func activate_combatant(combatant: Combatant) -> void:
	_active_combatant = combatant
	
func update_resource(resource_bar: ResourceBar, value: int) -> void:
	resource_bar.update_bar(value)

func toggle_combatant_stats() -> void:
	if not is_instance_valid(_active_combatant):
		if health_bar: health_bar.toggle_all_pips(false)
		if stamina_bar: stamina_bar.toggle_all_pips(false)
		if mana_bar: mana_bar.toggle_all_pips(false)
	else:
		if health_bar: health_bar.toggle_all_pips(true)
		if stamina_bar: stamina_bar.toggle_all_pips(true)
		if mana_bar: mana_bar.toggle_all_pips(true)
	
func _on_combatant_stat_changed(type: CoreStats.CoreStatType, new_value: int) -> void:
	var resource_bar: ResourceBar = _resource_bars.get(type)
	if resource_bar:
		update_resource(resource_bar, new_value)	

func _on_combatant_died(_combatant: Combatant) -> void:
	_active_combatant = null
	self.visible = false
	
func _on_new_combatant(new_combatant: Combatant) -> void:
	pass
	
func _on_new_active_combatant(new_combatant: Combatant) -> void:
	_active_combatant = new_combatant
	self.visible = true
	update_resource(health_bar, _active_combatant.health_component.current)
	update_resource(stamina_bar, _active_combatant.stamina_component.current)
	update_resource(mana_bar, _active_combatant.mana_component.current)
	_active_combatant.resource_changed.connect(_on_combatant_stat_changed)
	_active_combatant.died.connect(_on_combatant_died)
	self.visible = true
