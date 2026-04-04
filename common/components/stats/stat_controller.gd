class_name StatController
extends Node
 

signal stat_changed(type: StatTypes.CoreStatType, value: int)

signal stat_depleted(type: StatTypes.CoreStatType)

@onready var health_component: CoreStatComponent = $HealthComponent
@onready var stamina_component: CoreStatComponent = $StaminaComponent
@onready var mana_component: CoreStatComponent = $ManaComponent

var components: Dictionary = {}

func _ready() -> void:
	components = {
			StatTypes.CoreStatType.HEALTH : health_component,
			StatTypes.CoreStatType.STAMINA : stamina_component,
			StatTypes.CoreStatType.MANA : mana_component,
	}
	
func initialize(core_stats: CoreStats) -> void:
	_init_stat(StatTypes.CoreStatType.HEALTH, core_stats.initial_health)
	_init_stat(StatTypes.CoreStatType.STAMINA, core_stats.initial_stamina)
	_init_stat(StatTypes.CoreStatType.MANA, core_stats.initial_mana)
	
func _init_stat(type: StatTypes.CoreStatType, initial_value: int) -> void:
	var component: CoreStatComponent = components.get(type)
	if component:
		component.initialize(initial_value)
		_safe_connect(component.value_changed, func(value: int) -> void: stat_changed.emit(type, value))
		_safe_connect(component.depleted, func() -> void: stat_depleted.emit(type))	

func _safe_connect(sig: Signal, target: Callable) -> void:
	if not sig.is_connected(target):
		sig.connect(target)
		
func use_resource(amount: int, type: StatTypes.CoreStatType) -> void:
	var component: CoreStatComponent = components.get(type)
	if component:
		component.modify(-amount)
	else:
		print("Component for stat type ", type, " not found in ", self.name)
		
