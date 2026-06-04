class_name Combatant
extends Node2D

signal health_changed()
signal stamina_changed()
signal mana_changed()

signal combatant_died(combatant: Combatant)

@export var combatant_definition: CombatantDefinition:
	set(value):
		combatant_definition = value
		if is_node_ready():
			_setup_from_definition()
			
@onready var combatant_view: CombatantView = $CombatantView

@export_group("Health")
@export var health: int

@export_group("Stamina")
@export var stamina: int

@export_group("Mana")
@export var mana: int

var hand: Array[CardDefinition] = []
var buffer: Array[CardDefinition] = []

func _ready() -> void:
	_setup_from_definition()
	add_to_group("combatants")
	print("New combatant created and set up: ", self.get_name())
	
func modify_resource(type: CoreStats.CoreStatType, amount: int) -> void:
	match type:
		CoreStats.CoreStatType.HEALTH:
			health = max(0, health + amount)
			health_changed.emit()
			if health <= 0:
				combatant_died.emit(self)
		CoreStats.CoreStatType.STAMINA:
			stamina = max(0, stamina + amount)
			stamina_changed.emit()
		CoreStats.CoreStatType.MANA:
			mana = max(0, mana + amount)
			mana_changed.emit()

func _setup_from_definition() -> void:
	if not combatant_definition or not is_node_ready(): return
	
	self.name = combatant_definition.name
	
	health = combatant_definition.core_stats.initial_health
	stamina = combatant_definition.core_stats.initial_stamina
	mana = combatant_definition.core_stats.initial_mana
	
	if combatant_view and combatant_definition.visuals:
		combatant_view.apply_configuration(combatant_definition.visuals)
		
