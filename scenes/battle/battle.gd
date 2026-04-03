extends Node2D

@onready var turn_handler: TurnHandler = $TurnHandler
@onready var combat_handler: CombatHandler = $CombatHandler
@onready var combatant_manager: CombatantManager = $CombatantManager
@onready var battle_ui: BattleUI = $BattleUI

@onready var left_spawn: Marker2D = $LeftSpawn
@onready var right_spawn: Marker2D = $RightSpawn

@onready var advance_phase_button: Button = get_node("DebugAdvancePhase")
@onready var make_slime_button: Button = get_node("MakeSlime")
@onready var attack_button: Button = get_node("DebugAttackButton")
@onready var cast_spell: Button = get_node("DebugSpellButton")
@onready var get_hurt: Button = get_node("DebugGetHurtButton")

@onready var player_target: Actor

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
	advance_phase_button.pressed.connect(end_phase)
	turn_handler.aftermath_phase_ended.connect(end_turn)
	
	make_slime_button.pressed.connect(_on_make_slime_button_pressed.bind("slime", "left"))
	
	attack_button.pressed.connect(_on_attack)
	cast_spell.pressed.connect(_on_cast_spell)
	get_hurt.pressed.connect(_on_hurt)
	
	combatant_manager.combatant_spawned.connect(_on_combatant_spawned)
	
	
	
func end_phase() -> void:
	turn_handler.advance_phase()
	battle_ui.update_phase_label(current_phase, current_beat)
	
func end_turn() -> void:
	turn_handler.advance_turn()
	battle_ui.update_turn_label(current_turn)
	
func create_new_combatant(actor_name: String, side: String) -> void:
	var spawn_point: Marker2D = left_spawn if side == "left" else right_spawn
	var new_combatant: Actor = combatant_manager.spawn_combatant(actor_name, side, spawn_point.global_position)
	battle_ui.link_actor_to_side(new_combatant, side)
	if not player_target:
		player_target = new_combatant
	combatant_manager.register_combatant(new_combatant, side)
	
func _on_combatant_spawned(actor: Actor, side: String) -> void:
	pass
	
func _on_make_slime_button_pressed(actor_name: String, side: String) -> void:
	create_new_combatant("slime", "left")


#Stat changers for debugging		
func _on_attack() -> void:
	if player_target and is_instance_valid(player_target):
		player_target.receive_hit(1)
	else:
		print("No target selected!")

func _on_cast_spell() -> void:
	pass

func _on_hurt() -> void:
	pass
