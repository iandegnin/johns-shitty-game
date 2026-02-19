extends MarginContainer

# Export references so you can drag the specific bars in the inspector
@export var health_bar: HBoxContainer
@export var stamina_bar: HBoxContainer
@export var mana_bar: HBoxContainer

func setup(actor: Node2D) -> void:
	# 1. Connect the entity's signals to our update functions
	actor.health_changed.connect(_on_actor_health_changed)
	actor.stamina_changed.connect(_on_actor_stamina_changed)
	actor.mana_changed.connect(_on_actor_mana_changed)
	
	# 2. Perform an initial sync so the bars don't start at 0
	_on_actor_health_changed(actor.health, actor.max_health)
	_on_actor_stamina_changed(actor.stamina, actor.max_stamina)
	_on_actor_mana_changed(actor.mana, actor.max_mana)

func _on_actor_health_changed(current: int, max_val: int) -> void:
	health_bar.update_bar(current, max_val)

func _on_actor_stamina_changed(current: int, max_val: int) -> void:
	stamina_bar.update_bar(current, max_val)

func _on_actor_mana_changed(current: int, max_val: int) -> void:
	mana_bar.update_bar(current, max_val)
