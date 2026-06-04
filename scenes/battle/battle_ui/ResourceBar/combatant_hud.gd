extends Control
class_name CombatantHUD

@export var health_bar: ResourceBar
@export var stamina_bar: ResourceBar
@export var mana_bar: ResourceBar

var current_combatant: Combatant

func bind_combatant(combatant: Combatant) -> void:
	unbind_current()
	
	current_combatant = combatant
	if not current_combatant:
		hide()
		return
		
	show()

	_refresh_all_bars()

	current_combatant.health_changed.connect(_on_health_changed)
	current_combatant.stamina_changed.connect(_on_stamina_changed)
	current_combatant.mana_changed.connect(_on_mana_changed)
	
	self.visible = true

func unbind_current() -> void:
	if is_instance_valid(current_combatant):
		if current_combatant.health_changed.is_connected(_on_health_changed):
			current_combatant.health_changed.disconnect(_on_health_changed)
		if current_combatant.stamina_changed.is_connected(_on_stamina_changed):
			current_combatant.stamina_changed.disconnect(_on_stamina_changed)
		if current_combatant.mana_changed.is_connected(_on_mana_changed):
			current_combatant.mana_changed.disconnect(_on_mana_changed)
	current_combatant = null
	self.visible = false

func _refresh_all_bars() -> void:
	health_bar.update_bar(current_combatant.health)
	stamina_bar.update_bar(current_combatant.stamina)
	mana_bar.update_bar(current_combatant.mana)

func _on_health_changed() -> void:
	health_bar.update_bar(current_combatant.health)

func _on_stamina_changed() -> void:
	stamina_bar.update_bar(current_combatant.stamina)

func _on_mana_changed() -> void:
	mana_bar.update_bar(current_combatant.mana)
