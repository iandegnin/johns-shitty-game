extends HBoxContainer
class_name ResourceBar

@export var pip_scene: PackedScene	
@onready var pips: Array[Node] = get_children()

func toggle_all_pips(is_filled: bool) -> void:
	for i in range(pips.size()):
		pips[i].set_filled(is_filled)

func update_bar(current_value: int) -> void:
	for i in range(pips.size()):
		var is_filled: bool = i < current_value
		pips[i].set_filled(is_filled)
#Iterates over each pip assigned to an array via get_children()
#For each pip, swaps to blank texture if that pip's position if the 
#index is less than current_value
	
