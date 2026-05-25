extends Node
class_name BattleManager

signal combatant_created

@onready var turn_handler: TurnHandler = $TurnHandler

@onready var left_team: CombatantTeam = $CombatantTeamLeft
@onready var right_team: CombatantTeam = $CombatantTeamRight

@onready var advance_phase_button: Button = get_node("DebugAdvancePhase")
@onready var make_left_slime_button: Button = get_node("MakeLeftSlime")
@onready var make_right_slime_button: Button = get_node("MakeRightSlime")

@onready var attack_left: Button = get_node("DebugAttackLeftButton")
@onready var cast_spell_left: Button = get_node("DebugCastSpellLeftButton")
@onready var get_hurt_left: Button = get_node("DebugGetHurtLeftButton")

@onready var attack_right: Button = get_node("DebugAttackRightButton")
@onready var cast_spell_right: Button = get_node("DebugCastSpellRightButton")
@onready var get_hurt_right: Button = get_node("DebugGetHurtRightButton")

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
	
	new_combatant.died.connect(_on_combatant_died)
	
	combatant_created.emit()
	
func _on_combatant_spawned() -> void:
	pass

func _on_combatant_died(combatant: Combatant) -> void:
	pass
	#Find a way to toggle stat bars off

#Debug helper functions

func _connect_debug_button_signals() -> void:
	advance_phase_button.pressed.connect(end_phase)
	
	make_left_slime_button.pressed.connect(_on_make_left_slime_button_pressed)
	make_right_slime_button.pressed.connect(_on_make_right_slime_button_pressed)
	
	get_hurt_left.pressed.connect(_on_hurt_left)
	attack_left.pressed.connect(_on_attack_left)
	cast_spell_left.pressed.connect(_on_cast_spell_left)
	
	get_hurt_right.pressed.connect(_on_hurt_right)
	attack_right.pressed.connect(_on_attack_right)
	cast_spell_right.pressed.connect(_on_cast_spell_right)

func _on_hurt_left() -> void:
	if left_team.active_combatant and is_instance_valid(left_team.active_combatant):
		left_team.active_combatant.pay_cost(1, CoreStats.CoreStatType.HEALTH)
		left_team.active_combatant.receive_hit()
	else:
		print("No target selected!")

func _on_attack_left() -> void:
	if left_team.active_combatant and is_instance_valid(left_team.active_combatant):
		left_team.active_combatant.pay_cost(1, CoreStats.CoreStatType.STAMINA)
	else:
		print("No target selected!")

func _on_cast_spell_left() -> void:
	if left_team.active_combatant and is_instance_valid(left_team.active_combatant):
		left_team.active_combatant.pay_cost(1, CoreStats.CoreStatType.MANA)
	else:
		print("No target selected!")
		
func _on_hurt_right() -> void:
	if right_team.active_combatant and is_instance_valid(right_team.active_combatant):
		right_team.active_combatant.pay_cost(1, CoreStats.CoreStatType.HEALTH)
		right_team.active_combatant.receive_hit()
	else:
		print("No target selected!")

func _on_attack_right() -> void:
	if right_team.active_combatant and is_instance_valid(right_team.active_combatant):
		right_team.active_combatant.pay_cost(1, CoreStats.CoreStatType.STAMINA)
	else:
		print("No target selected!")

func _on_cast_spell_right() -> void:
	if right_team.active_combatant and is_instance_valid(right_team.active_combatant):
		right_team.active_combatant.pay_cost(1, CoreStats.CoreStatType.MANA)
	else:
		print("No target selected!")
		
func _on_make_left_slime_button_pressed() -> void:
	create_new_combatant("slime", left_team)
	
func _on_make_right_slime_button_pressed() -> void:
	create_new_combatant("slime", right_team)
