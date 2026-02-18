extends Node
class_name StaminaComponent

@export var stamina_stats: StaminaStats
@export var starting_stamina: int
@export var stamina_regen: int

@export var current_stamina: int

signal stamina_changed(new_stamina: int)

func initialize(incoming_stats: StaminaStats) -> void:
	stamina_stats = incoming_stats
	starting_stamina = stamina_stats.starting_stamina
	stamina_regen = stamina_stats.stamina_regen
	print("Stamina Component initialized with %d stamina" % starting_stamina)
	
func gain_stamina(amount: int) -> void:
	if not stamina_stats: return
	
	current_stamina += amount
	stamina_changed.emit
	print("Gained % stamina" [amount])
	
func lose_stamina(amount: int) -> void:
	if not stamina_stats: return
	
	current_stamina -= amount
	stamina_changed.emit
	print ("Lost " + str(amount) + " stamina")

func regen_stamina() -> void:
	current_stamina += stamina_regen
	
