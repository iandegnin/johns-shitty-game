extends HBoxContainer
class_name ResourceBar

@export var pip_scene: PackedScene	

func update_bar(current_value: int) -> void:
	var pips: Array[Node] = get_children()
	for i in range(pips.size()):
		var should_be_filled: bool = i < current_value
		pips[i].set_filled(should_be_filled)
#Iterates over each pip assigned to an array via get_children()
#For each pip, swaps to blank texture if that pip's position if the 
#index is less than current_value
	
