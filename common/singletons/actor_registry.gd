extends Node

var units: Dictionary = {
	"slime": {
		"data_def": preload("res://entities/actor_data/slime/res_slime_def.tres"),
	},
}

func get_entry(id: String) -> Dictionary:
	if units.has(id):
		return units[id]
	
	push_error("ActorRegistry: ID '%s' not found." % id)
	return {}
