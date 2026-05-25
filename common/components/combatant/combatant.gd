class_name Combatant
extends Node2D

signal resource_changed(stat_type: CoreStats.CoreStatType, current_value: int)
signal resource_depleted(stat_type: CoreStats.CoreStatType)
signal died(combatant: Combatant)

@export var combatant_definition: CombatantDefinition:
	set(value):
		combatant_definition = value
		if is_node_ready():
			_setup_from_definition()
			
@onready var combatant_view: CombatantView = $CombatantView
@onready var core_stats: CoreStats = combatant_definition.core_stats

@onready var health_component: CoreStatComponent = $HealthComponent
@onready var mana_component: CoreStatComponent = $ManaComponent
@onready var stamina_component: CoreStatComponent = $StaminaComponent

#get rid of dictionary
@onready var stat_components : Dictionary = { 			
			CoreStats.CoreStatType.HEALTH : health_component,
			CoreStats.CoreStatType.STAMINA : stamina_component,
			CoreStats.CoreStatType.MANA : mana_component
			}

var hand: Array[CardDefinition] = []
var buffer: Array[CardDefinition] = []

func _ready() -> void:
	_setup_from_definition()
	_setup_stat_components()
	add_to_group("combatants")
	print("New combatant created and set up: ", self.get_name())
	
#just make 3 functions
func pay_cost(amount: int, resource_type: CoreStats.CoreStatType) -> void:
	stat_components[resource_type].modify(-amount)

func receive_hit() -> void:
	if combatant_view:
		combatant_view.flash_hurt()

func _on_stat_changed(type: CoreStats.CoreStatType, new_value: int) -> void:
	resource_changed.emit(type, new_value)
	print("_on_stat_changed called: ", self.name, " ", stat_components[type].get_name(), " changed to ", new_value)
	
func _on_stat_depleted(type: CoreStats.CoreStatType) -> void:
	#ONLY DOES SOMETHING WITH HEALTH! ADD SIGNAL FOR STAT DEPLETED AND HAVE IT FIRE FOR ALL STATS
	if type == CoreStats.CoreStatType.HEALTH:
		died.emit(self)
		self.queue_free()
	print("_on_stat_depleted called: ", self.name, " ", stat_components[type].get_name(), " depleted")
		
func _setup_stat_components() -> void:
	if health_component:
		health_component.stat_type = CoreStats.CoreStatType.HEALTH
		health_component.initialize(core_stats.initial_health)
		health_component.value_changed.connect(_on_stat_changed)
		health_component.depleted.connect(_on_stat_depleted)
		
	if stamina_component:
		stamina_component.stat_type = CoreStats.CoreStatType.STAMINA
		stamina_component.initialize(core_stats.initial_stamina)
		stamina_component.value_changed.connect(_on_stat_changed)
		stamina_component.depleted.connect(_on_stat_depleted)
		
	if mana_component:
		mana_component.stat_type = CoreStats.CoreStatType.MANA
		mana_component.initialize(core_stats.initial_mana)
		mana_component.value_changed.connect(_on_stat_changed)
		mana_component.depleted.connect(_on_stat_depleted)
	
func _setup_from_definition() -> void:
	if not combatant_definition or not is_node_ready(): return
	
	self.name = combatant_definition.name
	
	if combatant_view and combatant_definition.visuals:
		combatant_view.apply_configuration(combatant_definition.visuals)
		
	if combatant_definition.core_stats:
		if health_component:
			health_component.initialize(combatant_definition.core_stats.initial_health)
		if stamina_component:
			stamina_component.initialize(combatant_definition.core_stats.initial_stamina)
		if mana_component:
			mana_component.initialize(combatant_definition.core_stats.initial_mana)
