extends HBoxContainer

# Drag your ResourcePip.tscn file here in the Inspector
@export var pip_scene: PackedScene 

func update_bar(current: int, max_val: int) -> void:
	# 1. Sync the number of pips with max_val
	while get_child_count() < max_val:
		var new_pip: TextureRect = pip_scene.instantiate()
		add_child(new_pip)
	
	# 2. Update each pip's state
	for i in get_child_count():
		var pip: TextureRect = get_child(i)
		# Hide pips if max_val decreased
		pip.visible = i < max_val 
		# If the node is visible, tell it to be full or empty
		if pip.visible:
			pip.set_is_full(i < current)
