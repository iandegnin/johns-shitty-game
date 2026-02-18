extends Control
class_name HealthUI

@export var pip_scene: PackedScene

func update_display(current: int) -> void:
	var container: HBoxContainer = get_node_or_null("HBoxContainer") as HBoxContainer
	if not container or not pip_scene:
		return

	# 1. Add pips if health increased
	while container.get_child_count() < current:
		var new_pip: TextureRect = pip_scene.instantiate() as TextureRect
		container.add_child(new_pip)
	
	# 2. Delete pips if health decreased
	while container.get_child_count() > current:
		var extra_pip: Node = container.get_child(0)
		container.remove_child(extra_pip)
		extra_pip.queue_free()
