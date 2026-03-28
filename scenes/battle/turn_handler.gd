extends Node
class_name TurnHandler

@onready var turn_tracker: TurnTracker = $TurnTracker

@onready var Phase: Dictionary = TurnTracker.Phase
@onready var current_phase: TurnTracker.Phase = turn_tracker.current_phase
@onready var current_turn: int = turn_tracker.current_turn
@onready var current_beat: int = turn_tracker.current_beat

signal aftermath_phase_ended()

func advance_turn() -> void:
	current_turn += 1

func advance_phase() -> void:
	match current_phase:
		
		Phase.START: current_phase = Phase.BUFFER
		Phase.BUFFER: current_phase = Phase.BEAT
		Phase.BEAT:
			if current_beat < 3:
				current_beat += 1
			else:
				current_beat = 1
				current_phase = Phase.RECOVERY
		Phase.RECOVERY: current_phase = Phase.AFTERMATH
		Phase.AFTERMATH: 
				current_phase = Phase.START
				aftermath_phase_ended.emit()
				#This means that, on turn change, turn_changed emits before phase_changed
				#Problem? Maybe in the future!
