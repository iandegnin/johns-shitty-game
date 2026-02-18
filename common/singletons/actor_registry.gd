extends Node

var units: Dictionary = {
	"slime": {
		"data": preload("res://entities/actors/slime/res_slime.tres"),
		"scene": preload("res://entities/actors/slime/slime.tscn")
	},
}

func get_entry(id: String) -> Dictionary:
	if units.has(id):
		return units[id]
	
	push_error("ActorRegistry: ID '%s' not found." % id)
	return {}
