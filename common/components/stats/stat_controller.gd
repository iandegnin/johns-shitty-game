class_name StatController
extends Node

signal health_depleted
signal health_changed(current: int)
signal mana_changed(current: int)

@onready var health_component: HealthComponent = $HealthComponent
@onready var mana_component: ManaComponent = $ManaComponent
@onready var stamina_component: StaminaComponent = $StaminaComponent

var current_health: int:
	get:
		return health_component.current_health if health_component else 0

var current_mana: int:
	get:
		return mana_component.current_mana if mana_component else 0

var current_stamina: int:
	get:
		return stamina_component.current_stamina if stamina_component else 0

func initialize(data: BaseStats) -> void:
	if health_component: health_component.initialize(data)
	if mana_component: mana_component.initialize(data)
	if stamina_component: stamina_component.initialize(data)
	_initialize_signals()

func _initialize_signals() -> void:
	if health_component and not health_component.health_changed.is_connected(_on_health_changed):
		health_component.health_changed.connect(_on_health_changed)
		health_component.died.connect(func() -> void: health_depleted.emit())
	
	if mana_component and not mana_component.mana_changed.is_connected(_on_mana_changed):
		mana_component.mana_changed.connect(_on_mana_changed)

func _on_health_changed(current: int) -> void:
	health_changed.emit(current)

func _on_mana_changed(current: int) -> void:
	mana_changed.emit(current)

func apply_damage(amount: int) -> void:
	if health_component: health_component.modify_health(-amount)
