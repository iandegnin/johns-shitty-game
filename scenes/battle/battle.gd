extends Node2D
class_name Battle

enum Side {LEFT, RIGHT}
@onready var battle_ui: BattleUI = $BattleUI
@onready var battle_manager: BattleManager = $BattleManager

signal combatant_created




func _ready() -> void:
	battle_manager.turn_handler.phase_updated.connect(battle_ui.update_phase_label)
	battle_manager.turn_handler.turn_updated.connect(battle_ui.update_turn_label)
	
	_connect_ui_signals()

func _connect_ui_signals() -> void:
	battle_manager.left_team.combatant_activated.connect(battle_ui.core_stats_left._on_new_active_combatant)
	battle_manager.right_team.combatant_activated.connect(battle_ui.core_stats_right._on_new_active_combatant)
