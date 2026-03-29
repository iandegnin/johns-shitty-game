extends Node2D

class CombatantData:
	var actor: BaseActor
	var actor_ui: ActorUI
	var side: String
	var is_active: bool
	
	func _init(_actor: BaseActor, _actor_ui: ActorUI, _side: String) -> void:
		actor = _actor
		actor_ui = _actor_ui
		side = _side
		is_active = false
		
var combatants: Dictionary = {}

@onready var turn_handler: TurnHandler = $TurnHandler
@onready var combat_manager: CombatHandler = $CombatHandler
@onready var battle_ui: BattleUI = $BattleUI

@onready var advance_phase_button: Button = get_node("DebugAdvancePhase")
@onready var make_slime_button: Button = get_node("MakeSlime")
@onready var attack_button: Button = get_node("DebugAttackButton")
@onready var cast_spell: Button = get_node("DebugSpellButton")
@onready var get_hurt: Button = get_node("DebugGetHurtButton")

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
	
	make_slime_button.pressed.connect(make_slime.bind("left"))
	
	attack_button.pressed.connect(_on_attack)
	cast_spell.pressed.connect(_on_cast_spell)
	get_hurt.pressed.connect(_on_hurt)
	
func end_phase() -> void:
	turn_handler.advance_phase()
	battle_ui.update_phase_label(current_phase, current_beat)
	
func end_turn() -> void:
	turn_handler.advance_turn()
	battle_ui.update_turn_label(current_turn)
	
func make_slime(side: String) -> void:
	var new_slime: BaseActor = ActorFactory.spawn_actor("slime", self, Vector2(100, 250))
	var target_ui: ActorUI = $BattleUI/ActorLeftUI if side == "left" else $BattleUI/ActorRightUI
	var data: CombatantData = CombatantData.new(new_slime, target_ui, side)
	combatants[new_slime] = data
	
	new_slime.health_changed.connect(_on_actor_health_changed)
	new_slime.stamina_changed.connect(_on_actor_stamina_changed)
	new_slime.mana_changed.connect(_on_actor_mana_changed)
	_on_actor_health_changed(new_slime)
	_on_actor_stamina_changed(new_slime)
	_on_actor_mana_changed(new_slime)
	
func _on_actor_health_changed(sender: Node2D) -> void:
	var data: CombatantData = combatants[sender] as CombatantData
	data.actor_ui.update_health(sender.stat_controller.health.current)
	
func _on_actor_stamina_changed(sender: Node2D) -> void:
	var data: CombatantData = combatants[sender] as CombatantData
	data.actor_ui.update_stamina(sender.stat_controller.stamina.current)
	
func _on_actor_mana_changed(sender: Node2D) -> void:
	var data: CombatantData = combatants[sender] as CombatantData
	data.actor_ui.update_mana(sender.stat_controller.mana.current)
	
#Stat changers for debugging	
	
func _on_attack() -> void:
	if $slime:
		$slime.take_hit(1)

func _on_cast_spell() -> void:
	pass

func _on_hurt() -> void:
	pass
