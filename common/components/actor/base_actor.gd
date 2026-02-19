class_name BaseActor
extends Node2D

signal actor_died(actor: BaseActor)
signal hit_received

@export var definition: ActorDefinition

@onready var stats: StatController = $StatController
@onready var visuals: ActorView = $ActorView

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
	
	if stats and data.core_stats:
		stats.initialize(data.core_stats)

func _connect_signals() -> void:
	if stats:
		stats.health_depleted.connect(_on_death)

func take_damage(amount: int) -> void:
	stats.apply_damage(amount)
	# Feedback is now handled by the Visuals component
	if visuals:
		visuals.flash_hurt()
	hit_received.emit()

func _on_death() -> void:
	actor_died.emit(self)
	queue_free()
