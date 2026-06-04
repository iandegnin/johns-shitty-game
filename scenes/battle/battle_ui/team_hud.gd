
extends MarginContainer
class_name CoreStatsHUD

@export var combatant_slots: Array[CombatantHUD] = []

func _ready() -> void:
	self.visible = false

func _on_roster_ordered(target_team: CombatantTeam) -> void:
	self.visible = true
	_sync_hud_to_roster(target_team.roster)

func _sync_hud_to_roster(roster: Array[Combatant]) -> void:
	for c in roster:	
		print("Roster contains: ", c.name if c else "null")
	for i in range(combatant_slots.size()):
		if i < roster.size():
			combatant_slots[i].bind_combatant(roster[i])
		else:
			combatant_slots[i].bind_combatant(null)
