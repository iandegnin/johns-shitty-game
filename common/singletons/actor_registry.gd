extends Node

var units: Dictionary = {
	"slime": {
		"data": preload("res://entities/actors/slime/res_slime_def.tres"),
	},
}

func get_entry(id: String) -> Dictionary:
	if units.has(id):
		return units[id]
	
	push_error("ActorRegistry: ID '%s' not found." % id)
	return {}
