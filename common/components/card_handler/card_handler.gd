extends Node
class_name CardHandler

var deck: Array[CardDefinition] = []
var hand: Array[CardDefinition] = []
var buffer: Array[CardDefinition] = []

func commit_to_buffer(card_indices: Array[int]) -> void:
	for i in card_indices:
		buffer.append(hand[i])
	hand.clear()
