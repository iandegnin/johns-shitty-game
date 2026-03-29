extends HBoxContainer
class_name ResourceBar

@export var pip_scene: PackedScene
@export var max_resource: int = 3

func _ready() -> void:
	_initialize_bar()

func _initialize_bar() -> void:
	for child in get_children():
		child.queue_free()
	
	for i in max_resource:
		var pip: Node = pip_scene.instantiate()
		add_child(pip)

func update_bar(current_value: int) -> void:
	var displayed_value: int = clampi(current_value, 0, get_child_count())
	
	for i in get_child_count():
		var pip: Node = get_child(i) as ResourcePip
		if pip:
			pip.set_is_full(i < displayed_value)
