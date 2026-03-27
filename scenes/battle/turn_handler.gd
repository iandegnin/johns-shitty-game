extends Node
class_name TurnHandler

enum Phase { START, BUFFER, BEAT, RECOVERY, AFTERMATH }

@onready var current_turn: int = 1
@onready var current_phase: Phase = Phase.START
@onready var current_beat: int = 1

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


	
	
	
	
