class_name CoreStats
extends Resource

@export_group("Initial Values")
@export var initial_health: int = 3
@export var initial_mana: int = 3
@export var initial_stamina: int = 3

func get_initial_value(type: StatTypes.CoreStatType) -> int:
	match type:
		StatTypes.CoreStatType.HEALTH:
			return initial_health
		StatTypes.CoreStatType.STAMINA:
			return initial_stamina
		StatTypes.CoreStatType.MANA:
			return initial_mana
		_:
			return 0
