extends Node
class_name TurnTracker

enum Phase { START, BUFFER, BEAT, RECOVERY, AFTERMATH }

@onready var current_turn: int = 1
@onready var current_phase: Phase = Phase.START
@onready var current_beat: int = 1
