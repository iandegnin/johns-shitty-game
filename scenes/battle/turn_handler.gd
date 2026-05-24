extends Node
class_name TurnHandler

enum Phase { START, BUFFER, BEAT, RECOVERY, AFTERMATH }

@onready var current_turn: int = 1
@onready var current_phase: Phase = Phase.START
@onready var current_beat: int = 1

signal phase_updated(phase_name: String, beat: int)
signal turn_updated(turn: int)

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
				advance_turn()
				current_phase = Phase.START
	phase_updated.emit(Phase.keys()[current_phase], current_beat)
	if current_phase == Phase.START:
		turn_updated.emit(current_turn)
