extends CanvasLayer
class_name BattleUI

func update_phase_label(current_phase: String , current_beat: int) -> void:
	var label_text: String
	if current_phase == "BEAT":
		label_text = ("BEAT " + str(current_beat))
	else:
		label_text = current_phase
	$PhaseLabel.text = label_text
	
	
func update_turn_label(current_turn: int) -> void:
	var label_text: String = str(current_turn)
	$TurnLabel.text = ("TURN " + label_text)
	
