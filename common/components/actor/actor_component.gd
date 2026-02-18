extends Node
class_name ActorComponent

var stats: ActorResource

signal actor_died(actor: Node)
signal hit_received

func initialize(data: ActorResource) -> void:
	stats = data
	_setup_visuals()
	_setup_stats()

func _setup_visuals() -> void:
	var parent: Node = get_parent()
	var sprite: Sprite2D = parent.get_node_or_null("Sprite2D") as Sprite2D
	
	if sprite and stats:
		sprite.texture = stats.texture
		sprite.hframes = stats.h_frames
		sprite.vframes = stats.v_frames
		sprite.modulate = stats.modulate
		sprite.offset = stats.offset

func _setup_stats() -> void:
	var parent: Node = get_parent()
	var health: HealthComponent = parent.get_node_or_null("HealthComponent") as HealthComponent
	var ui: HealthUI = parent.get_node_or_null("HealthUI") as HealthUI
	
	if health and stats:
#connect UI, then connect death signal, then set health, otherwise things get fucky with UI i think?
		if ui and not health.health_changed.is_connected(ui.update_display):
			health.health_changed.connect(ui.update_display)
		
		if not health.died.is_connected(_on_health_died):
			health.died.connect(_on_health_died)
			
		health.current_health = stats.current_health

func _on_health_died() -> void:
	actor_died.emit(get_parent())

func _on_health_hit() -> void:
	hit_received.emit()
