extends Resource
class_name CardDefinition

@export var card_name: String
@export var texture: Texture2D
@export_multiline var description: String

@export_group("Beats")
@export_range(1, 3) var activation_beat: int = 1 ## Which beat (1-3) this card triggers on

@export_group("Costs")
@export var energy_cost: int
@export var mana_cost: int

@export_group("Effects")
@export var effects: Array[Effect]

func play(user: Node, targets: Array[Node]) -> void:
	for effect in effects:
		if effect:
			effect.execute(user, targets)
