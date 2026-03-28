extends Node2D

class CombatantData:
	var actor: BaseActor
	var ui_slot: ActorUI
	var side: String
	var is_active: bool
	
	func _init(_actor: BaseActor, _ui: ActorUI, _side: String) -> void:
		actor = _actor
		ui_slot = _ui
		side = _side
		is_active = false
		
var combatants: Dictionary = {}


@onready var advance_phase_button: Button = get_node("DebugAdvancePhase")
@onready var make_slime_button: Button = get_node("MakeSlime")
@onready var attack_button: Button = get_node("DebugAttackButton")
@onready var cast_spell: Button = get_node("DebugSpellButton")
@onready var get_hurt: Button = get_node("DebugGetHurtButton")

@onready var turn_handler: TurnHandler = $TurnHandler
@onready var combat_manager: CombatHandler = $CombatHandler

var current_phase: String:
	get:
		return turn_handler.Phase.keys()[turn_handler.current_phase]
		
var current_beat: int:
	get:
		return turn_handler.current_beat

var current_turn: int:
	get:
		return turn_handler.current_turn
		
func _ready() -> void:
	turn_handler.aftermath_phase_ended.connect(end_turn)
	advance_phase_button.pressed.connect(end_phase)
	make_slime_button.pressed.connect(make_slime.bind("left"))
	attack_button.pressed.connect(_on_attack)
	cast_spell.pressed.connect(_on_cast_spell)
	get_hurt.pressed.connect(_on_hurt)

func make_slime(side: String) -> void:
	var new_slime: BaseActor = ActorFactory.spawn_actor("slime", self, Vector2(100, 250))
	var target_ui: ActorUI = $BattleUI/ActorLeftUI if side == "left" else $BattleUI/ActorRightUI
	var data: CombatantData = CombatantData.new(new_slime, target_ui, side)
	combatants[new_slime] = data
	
	new_slime.health_changed.connect(_on_actor_health_changed)
	new_slime.health_changed.connect(_on_actor_stamina_changed)
	new_slime.health_changed.connect(_on_actor_mana_changed)
	_on_actor_health_changed(new_slime)
	_on_actor_stamina_changed(new_slime)
	_on_actor_mana_changed(new_slime)
	
func end_phase() -> void:
	turn_handler.advance_phase()
	var label_text: String
	if current_phase == "BEAT":
		label_text = ("BEAT " + str(current_beat))
	else:
		label_text = current_phase
	$PhaseLabel.text = label_text
	
func end_turn() -> void:
	turn_handler.advance_turn()
	var label_text: String = str(current_turn)
	$PhaseLabel.text = label_text

func _on_actor_health_changed(sender: Node2D) -> void:
	var data: CombatantData = combatants[sender] as CombatantData
	data.ui_slot.update_health(sender.stat_controller.health.current)
	
func _on_actor_stamina_changed(sender: Node2D) -> void:
	var data: CombatantData = combatants[sender] as CombatantData
	data.ui_slot.update_stamina(sender.stat_controller.stamina.current)
	
func _on_actor_mana_changed(sender: Node2D) -> void:
	var data: CombatantData = combatants[sender] as CombatantData
	data.ui_slot.update_mana(sender.stat_controller.mana.current)
	
func _on_attack() -> void:
	if $slime:
		$slime.take_hit(1)

func _on_cast_spell() -> void:
	pass

func _on_hurt() -> void:
	pass
