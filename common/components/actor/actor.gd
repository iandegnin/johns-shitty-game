class_name Actor
extends Node2D

signal stat_changed(stat_type: StatTypes.CoreStatType, current_value: int)
signal stat_depleted(stat_type: StatTypes.CoreStatType)
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
		
	if not stat_controller.stat_changed.is_connected(_on_controller_stat_changed):
		stat_controller.stat_changed.connect(_on_controller_stat_changed)
	
	if not stat_controller.stat_depleted.is_connected(_on_controller_stat_depleted):
		stat_controller.stat_depleted.connect(_on_controller_stat_depleted)
	
	add_to_group("actors")

func receive_hit(amount: int) -> void:
	if actor_view:
		actor_view.flash_hurt()
	stat_controller.use_resource(amount, StatTypes.CoreStatType.HEALTH)	

func _on_controller_stat_changed(type: StatTypes.CoreStatType, new_value: int) -> void:
	stat_changed.emit(type, new_value)
	
func _on_controller_stat_depleted(type: StatTypes.CoreStatType) -> void:
	if type == StatTypes.CoreStatType.HEALTH:
		died.emit(self)
		queue_free()

func _on_death() -> void:
	died.emit(self)
	queue_free()
	
func get_current_resource(stat_type: StatTypes.CoreStatType) -> int:
	var component: CoreStatComponent = stat_controller.components.get(stat_type)
	return component.current if component else 0
	
func get_initial_resource(stat_type: StatTypes.CoreStatType) -> int:
	if not actor_definition or not actor_definition.core_stats:
		return 0
	return actor_definition.core_stats.get_initial_value(stat_type)
