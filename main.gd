extends Node

@export var turn_manager: TurnManager
@export var combat_manager: CombatManager

func _ready() -> void:
	if not turn_manager or not combat_manager:
		push_error("Main: Managers are not assigned in Inspector!")
		return
		
	turn_manager.turn_elapsed.connect(_on_turn_elapsed)

func _on_turn_elapsed() -> void:
	combat_manager.process_combat()
