extends Node
class_name CombatManager

func process_combat() -> void:
	var combatants: Array[Node] = get_all_living_combatants()
	print("Turn elapsed! Combatants present: ", combatants.size())

func get_all_living_combatants() -> Array[Node]:
	return get_tree().get_nodes_in_group("actors")

func execute_attack(attacker: Actor, target: Actor, damage_amount: int) -> void:
	var health: HealthComponent = target.get_node_or_null("HealthComponent")
	attacker.on_attack_landed(target, damage_amount)
	
	if health:
		health.take_damage(damage_amount)
	else:
		printerr(target.name, " has no HealthComponent!")
