class_name Actor
extends Node2D

signal health_changed(current_health: int)
signal died(actor: Actor)

@export var actor_definition: ActorDefinition:
	set(value):
		actor_definition = value
		if is_node_ready():
			_setup_from_definition()
			
@onready var actor_view: ActorView = $ActorView
@onready var stat_controller: StatController = $StatController

var hand: Array[CardDefinition] = []
var buffer: Array[CardDefinition] = []

func _ready() -> void:
	if actor_definition:
		_setup_from_definition()
		
func _setup_from_definition() -> void:
	if not actor_definition: return
	
	self.name = actor_definition.name
	if actor_view and actor_definition.visuals:
		actor_view.apply_configuration(actor_definition.visuals)
	
	if stat_controller and actor_definition.core_stats:
		stat_controller.initialize(actor_definition.core_stats)
	
	stat_controller.health_depleted.connect(_on_death)
	
	if not stat_controller.health_changed.is_connected(_on_controller_health_changed):
		stat_controller.health_changed.connect(_on_controller_health_changed)
	
	add_to_group("actors")

func receive_hit(amount: int) -> void:
	if actor_view:
		actor_view.flash_hurt()
	stat_controller.use_resource(amount, stat_controller.health_component, "Health")	

func _on_controller_health_changed(new_health: int) -> void:
	health_changed.emit(new_health)

func _on_death() -> void:
	died.emit(self)
	queue_free()
	
func get_current_health() -> int:
	return stat_controller.health_component.current
	
func get_initial_health() -> int:
	return actor_definition.core_stats.starting_health
