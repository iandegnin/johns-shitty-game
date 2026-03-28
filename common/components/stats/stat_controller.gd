class_name StatController
extends Node

signal health_changed(val: int)
signal health_depleted
signal mana_changed(val: int)
signal stamina_changed(val: int)

@onready var health: StatComponent = $HealthComponent
@onready var mana: StatComponent = $ManaComponent
@onready var stamina: StatComponent = $StaminaComponent

func initialize(core_stats: CoreStats) -> void:
	if health:
		health.initialize(core_stats.starting_health)
		_safe_connect(health.value_changed, health_changed.emit)
		_safe_connect(health.depleted, health_depleted.emit)
	
	if mana:
		mana.initialize(core_stats.starting_mana)
		_safe_connect(mana.value_changed, mana_changed.emit)
		
	if stamina:
		stamina.initialize(core_stats.starting_stamina)
		_safe_connect(stamina.value_changed, stamina_changed.emit)

func _safe_connect(sig: Signal, target: Callable) -> void:
	if not sig.is_connected(target):
		sig.connect(target)
		
func apply_damage(raw_amount: int) -> void:
	if not health: return
	health.modify(-raw_amount)

func use_mana(amount: int) -> void:
	if not mana: return
	mana.modify(-amount)

func use_stamina(amount: int) -> void:
	if not stamina: return
	stamina.modify(-amount)
