# turn_manager.gd
extends Node
class_name TurnHandler

enum Phase { START, BUFFER, BEAT, RECOVERY, AFTERMATH }
@onready var current_phase: Phase = Phase.START
@onready var current_beat: int = 1

signal phase_started(phase: Phase)

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
		Phase.AFTERMATH: current_phase = Phase.START
	
	phase_started.emit(current_phase)
