extends Node2D

@onready var advance_phase_button: Button = get_node("DebugAdvancePhase")
@onready var make_slime_button: Button = get_node("MakeSlime")

@onready var turn_handler: TurnHandler = $TurnHandler
@onready var combat_manager: CombatManager = $CombatManager

var current_phase: String:
	get:
		return turn_handler.Phase.keys()[turn_handler.current_phase]
		
var current_beat: int:
	get:
		return turn_handler.current_beat
		
func _ready() -> void:
	advance_phase_button.pressed.connect(advance_phase)
	make_slime_button.pressed.connect(make_slime)

func make_slime() -> void:
	var new_slime: Node2D = ActorFactory.spawn_actor("slime", self, Vector2(500, 300))

func advance_phase() -> void:
	turn_handler.advance_phase()
	if current_phase == "BEAT":
		print("BEAT " +  str(current_beat))
	else:
		print(current_phase)
