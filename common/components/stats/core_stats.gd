class_name CoreStats
extends Resource

enum CoreStatType {HEALTH, STAMINA, MANA}

@export_group("Initial Values")
@export var initial_health: int = 3
@export var initial_mana: int = 3
@export var initial_stamina: int = 3

func get_initial_value(type: CoreStatType) -> int:
	match type:
		CoreStatType.HEALTH:
			return initial_health
		CoreStatType.STAMINA:
			return initial_stamina
		CoreStatType.MANA:
			return initial_mana
		_:
			return 0
