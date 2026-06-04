extends Node2D
class_name Battle

enum Side {LEFT, RIGHT}

@onready var battle_manager: BattleManager = $BattleManager
@onready var battle_ui: BattleUI = $BattleUI

signal combatant_created

func _ready() -> void:	
	battle_manager.turn_handler.phase_updated.connect(battle_ui.update_phase_label)
	battle_manager.turn_handler.turn_updated.connect(battle_ui.update_turn_label)
	
	_connect_HUD_signals()
	
func _connect_HUD_signals() -> void:
	battle_manager.left_team.roster_ordered.connect(battle_ui.left_team_hud._on_roster_ordered)
	battle_manager.right_team.roster_ordered.connect(battle_ui.right_team_hud._on_roster_ordered)
