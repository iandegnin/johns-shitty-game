extends MarginContainer
class_name ActorUI

# Assuming your second script is given the class_name ResourceBar
@export var health_bar: ResourceBar
@export var stamina_bar: ResourceBar
@export var mana_bar: ResourceBar

func update_health(health: int) -> void:
	health_bar.update_bar(health)

func update_stamina(stamina: int) -> void:
	stamina_bar.update_bar(stamina)

func update_mana(mana: int) -> void:
	mana_bar.update_bar(mana)
