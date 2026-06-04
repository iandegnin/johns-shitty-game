class_name CombatantTeam
extends Node

signal roster_ordered(combatant_team: CombatantTeam)

var roster: Array[Combatant] = []

var active_combatant: Combatant:
	get:
		return roster[0]

func add_combatant(combatant: Combatant) -> void:
	roster.append(combatant)
	print("Combatant added: ", combatant.get_name())
	roster_ordered.emit(self)

func swap_active(combatant_to_swap: Combatant) -> void:
	var target_index: int = roster.find(combatant_to_swap)
	if target_index <= 0:
		print("Set_active error: Combatant to swap doesn't exist or was already at index 0")
		return

	var temp: Combatant = roster[0]
	roster[0] = roster[target_index]
	roster[target_index] = temp
	
	print("Active Combatant swapped to: ", roster[0].get_name(), "from roster index: ", target_index)
	
	roster_ordered.emit(self)


func get_stat(combatant: Combatant, stat: CoreStats.CoreStatType) -> int:
	match stat:
		CoreStats.CoreStatType.HEALTH:
			return combatant.health
		CoreStats.CoreStatType.STAMINA:
			return combatant.stamina
		CoreStats.CoreStatType.MANA:
			return combatant.mana
		_:
			return 0
