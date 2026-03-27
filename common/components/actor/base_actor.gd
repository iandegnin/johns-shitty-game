class_name BaseActor
extends Node2D

signal actor_died(actor: BaseActor)
signal health_changed(actor: BaseActor)

@export var actor_data: ActorDefinition

@onready var stat_controller: StatController = $StatController
@onready var visuals: ActorView = $ActorView

var hand: Array[CardDefinition] = []
var buffer: Array[CardDefinition] = []

func _ready() -> void:
	if actor_data:
		initialize(actor_data)
	add_to_group("actors")
	_connect_signals()

func initialize(data: ActorDefinition) -> void:
	self.name = data.name
	if visuals and data.visuals:
		visuals.apply_configuration(data.visuals)
	
	if stat_controller and data.core_stats:
		stat_controller.initialize(data.core_stats)

func _connect_signals() -> void:
	if stat_controller:
		stat_controller.health_depleted.connect(_on_death)

func take_hit(amount: int) -> void:
	stat_controller.apply_damage(amount)

	if visuals:
		visuals.flash_hurt()
		health_changed.emit(self)

func _on_death() -> void:
	actor_died.emit(self)
	queue_free()
