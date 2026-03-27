@tool
extends Effect
class_name DamageEffect

@export var amount: int

func execute(_user: Node, _targets: Array[Node]) -> void:
	for target: Node in _targets:
		var stats: StatComponent = target.get_node_or_null("Stats")
		if stats:
			stats.take_damage(amount)

func _init() -> void:
	resource_name = "DamageEffect"
