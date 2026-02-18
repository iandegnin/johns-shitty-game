extends Node
class_name ManaComponent

@export var mana_stats: ManaStats

signal mana_changed(new_mana: int)
var current_mana: int

func initialize(incoming_stats: ManaStats) -> void:
	mana_stats = incoming_stats
	current_mana = mana_stats.start_mana
	print("Mana Component initialized with %d mana" % current_mana)

func gain_mana(amount: int) -> void:
	if not mana_stats: return
	mana_stats.current_mana += amount
	mana_changed.emit
	print("Gained %d mana" % amount)

func lose_mana(amount: int) -> void:
	if not mana_stats: return
	mana_stats.current_mana -= amount
	mana_changed.emit
	print ("Lost " + str(amount) + " mana")
