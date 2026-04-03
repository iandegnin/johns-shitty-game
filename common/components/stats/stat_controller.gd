class_name StatController
extends Node

signal health_changed(val: int)
signal mana_changed(val: int)
signal stamina_changed(val: int)

signal health_depleted
signal mana_depleted
signal stamina_depleted

@onready var health_component: CoreStatComponent = $HealthComponent
@onready var stamina_component: CoreStatComponent = $StaminaComponent
@onready var mana_component: CoreStatComponent = $ManaComponent

func initialize(core_stats: CoreStats) -> void:
	if health_component:
		health_component.initialize(core_stats.initial_health)
		_safe_connect(health_component.value_changed, health_changed.emit)
		_safe_connect(health_component.depleted, health_depleted.emit)
		
	if stamina_component:
		stamina_component.initialize(core_stats.initial_stamina)
		_safe_connect(stamina_component.value_changed, stamina_changed.emit)
		
	if mana_component:
		mana_component.initialize(core_stats.initial_mana)
		_safe_connect(mana_component.value_changed, mana_changed.emit)

func _safe_connect(sig: Signal, target: Callable) -> void:
	if not sig.is_connected(target):
		sig.connect(target)
		
func use_resource(amount: int, stat_component: CoreStatComponent, stat: String) -> void:
	if not stat_component:
		print(stat + " component not found in " + self.name)
		return
	stat_component.modify(-amount)
		
