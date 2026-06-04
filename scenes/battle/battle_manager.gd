extends Node
class_name BattleManager

signal combatant_created

@onready var turn_handler: TurnHandler = $TurnHandler

@onready var left_team: CombatantTeam = $CombatantTeamLeft
@onready var right_team: CombatantTeam = $CombatantTeamRight

@onready var advance_phase_button: Button = get_node("DebugAdvancePhase")
@onready var make_left_slime_button: Button = get_node("MakeLeftSlime")

@onready var get_hurt_left: Button = get_node("DebugGetHurtLeftButton")

@onready var active_label: Label = get_node("ActiveCombatantLabel")
@onready var inactive_1: Label = get_node("InactiveCombatantLabel1")
@onready var inactive_2: Label = get_node("InactiveCombatantLabel2")

@onready var swap1: Button = get_node("Swap1")
@onready var swap2: Button = get_node("Swap2")

var current_phase: String:
	get:
		return turn_handler.Phase.keys()[turn_handler.current_phase] as String
		
var current_beat: int:
	get:
		return turn_handler.current_beat as int

var current_turn: int:
	get:
		return turn_handler.current_turn as int

func _ready() -> void:
	_connect_debug_button_signals()
	
func end_phase() -> void:
	turn_handler.advance_phase()
	#battle_ui.update_phase_label(current_phase, current_beat)
	
func end_turn() -> void:
	turn_handler.advance_turn()
	#battle_ui.update_turn_label(current_turn)

func create_new_combatant(combatant_id: String, target_team: CombatantTeam) -> void:
	var new_combatant: Combatant = CombatantFactory.spawn_combatant(combatant_id)
	add_child(new_combatant)
	target_team.add_combatant(new_combatant)
	
	combatant_created.emit()
	



#Debug helper functions

func _connect_debug_button_signals() -> void:
	advance_phase_button.pressed.connect(end_phase)
	
	make_left_slime_button.pressed.connect(_on_make_left_slime_button_pressed)

	get_hurt_left.pressed.connect(_on_hurt_left)
	
	swap1.pressed.connect(_on_swap_1_pressed)
	swap2.pressed.connect(_on_swap_2_pressed)

func _on_hurt_left() -> void:
	left_team.active_combatant.modify_resource(CoreStats.CoreStatType.HEALTH, -1)
		
func _on_make_left_slime_button_pressed() -> void:
	create_new_combatant("slime", left_team)
	
func _on_make_right_slime_button_pressed() -> void:
	create_new_combatant("slime", right_team)
	
func _on_swap_1_pressed() -> void:
	left_team.swap_active(left_team.roster[1])

func _on_swap_2_pressed() -> void:
	left_team.swap_active(left_team.roster[2])
