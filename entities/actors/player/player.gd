extends Node2D

var max_health:int = 0
var current_health:int = max_health
var max_mana: int = 0
var current_mana:int = max_mana
var damage:int = 0
var defense:int = 0
var initiative:int = 0

@onready var statslabel: Label = get_node('StatsLabel')
@onready var healthbar: ProgressBar = get_node('HealthBar')

func _ready() -> void:
	set_start_stats(3, 0, 1, 1, 1)
	set_statslabel()
	set_healthbar()

func take_damage(damage:int) -> void:
	current_health -= damage
	healthbar.set_value(current_health)
	
func set_start_stats(start_max_health:int, start_max_mana:int, start_damage:int, start_defense:int, start_initiative:int) -> void:
		max_health = start_max_health
		max_mana = start_max_mana
		damage = start_damage
		defense = start_defense
		initiative = start_initiative

func set_statslabel() -> void:
	var statstext: String = """Mana: %s
	Damage: %s
	Defense: %s
	Initiative: %s"""
	statslabel.text = statstext % [max_mana, damage, defense, initiative]

func set_healthbar() -> void:
	healthbar.set_show_percentage(false)
	healthbar.set_max(max_health)
	healthbar.set_min(0)
	healthbar.set_value(current_health)
	
