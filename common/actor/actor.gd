extends Node2D
class_name Actor

@export var actor_data: ActorResource

@onready var health_component: HealthComponent = $HealthComponent
@onready var health_ui: Control = $HealthUI

var hand: Array[CardResource] = []
var buffer: Array[CardResource] = []

signal actor_died(actor: Actor) ##
signal hit_received ## Emits when the health component 

func _ready() -> void:
	add_to_group("actors")

	health_component.health_changed.connect(_on_health_updated)
	_on_health_updated(health_component.current_health, health_component.max_health)


func initialize(data: ActorResource) -> void:
	_setup_visuals(data)
	_setup_components(data)
	_on_initialize(data)
	
func _setup_visuals(data: ActorResource) -> void:
	assert(data.actor_visuals != null, "ERROR: You forgot to assign visuals to " + data.resource_path)
	if data.actor_visuals:
		var visuals: Sprite2D = $Sprite2D
		visuals.texture = data.actor_visuals.texture
		visuals.hframes = data.actor_visuals.h_frames
		visuals.vframes = data.actor_visuals.v_frames
		visuals.modulate = data.actor_visuals.modulate
		visuals.offset = data.actor_visuals.offset
		var sprite: Sprite2D = get_node_or_null("Sprite2D")
		if sprite:
			sprite.texture = data.actor_visuals.texture
			print("SUCCESS: Assigned texture: ", sprite.texture.resource_path)
		else:
			print("FAILURE: Could not find Sprite2D node!")
	else:
		print("FAILURE: No sprite_data found in ActorData!")
	
func _setup_components(data: ActorResource) -> void:
	# Map the Data Resource property name to the Node name
	var component_map: Dictionary = {
		"health_stats": "HealthComponent",
		"stamina_stats": "StaminaComponent",
		"mana_stats": "ManaComponent"
						}
	for stat_key: String in component_map:
		var node_name: String = component_map[stat_key]
		var stat_resource: Resource = data.get(stat_key)
		
		if has_node(node_name) and stat_resource:
			var component: Node = get_node(node_name)
			component.initialize(stat_resource)
			
			# Handle unique signal connections for specific components
			if node_name == "HealthComponent":
				component.died.connect(_on_death)
				component.hit_received.connect(_on_health_hit)
				
func _on_initialize(_data: ActorResource) -> void:
	pass

func _on_health_hit(_amount: int) -> void:
	hit_received.emit()

func _on_death(actor: Actor) -> void:
	actor_died.emit(actor)
	
func _on_health_updated(current: int, max_h: int) -> void:
	health_ui.update_display(current, max_h)
