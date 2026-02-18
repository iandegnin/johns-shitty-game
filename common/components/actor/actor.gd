class_name Actor
extends Node2D

signal actor_died(actor: Actor)
signal hit_received

@export var definition: ActorDefinition

@onready var stats: StatController = $StatController
@onready var visuals: EntityVisuals = $EntityVisuals
@onready var health_ui: Control = $HealthUI

var hand: Array[CardDefinition] = []
var buffer: Array[CardDefinition] = []

func _ready() -> void:
	add_to_group("actors")
	_connect_signals()
	
	if definition:
		initialize(definition)

func initialize(data: ActorDefinition) -> void:
	# Dispatch sub-resources to specialized components
	if visuals and data.visuals:
		visuals.apply_configuration(data.visuals)
	
	if stats and data.base_stats:
		stats.initialize(data.base_stats)
	
	# Initial UI sync
	_update_ui()

func _connect_signals() -> void:
	if stats:
		stats.health_changed.connect(_on_health_updated)
		stats.health_depleted.connect(_on_death)

func take_damage(amount: int) -> void:
	stats.apply_damage(amount)
	# Feedback is now handled by the Visuals component
	if visuals:
		visuals.flash_hurt()
	hit_received.emit()

func _on_health_updated(_current: int, _max_h: int) -> void:
	_update_ui()

func _update_ui() -> void:
	if health_ui and health_ui.has_method("update_display"):
		health_ui.update_display(stats.current_health)

func _on_death() -> void:
	actor_died.emit(self)
	queue_free()
