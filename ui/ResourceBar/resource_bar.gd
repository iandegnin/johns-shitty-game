extends HBoxContainer
class_name ResourceBar

@export var pip_scene: PackedScene

func update_bar(current_value: int) -> void:
	if get_child_count() == 0:
		for i in current_value:
			var new_pip: Control = pip_scene.instantiate()
			add_child(new_pip)
	
	for i in get_child_count():
		var pip: ResourcePip = get_child(i) as ResourcePip
		if pip != null:
			pip.set_is_full(i < current_value)
