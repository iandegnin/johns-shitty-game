extends Node
class_name CardHandlerComponent

var deck: Array[CardResource] = []
var hand: Array[CardResource] = []
var buffer: Array[CardResource] = []

# Move cards from Hand to Buffer stack (The Planning Phase)
func commit_to_buffer(card_indices: Array[int]) -> void:
	for i in card_indices:
		buffer.append(hand[i])
	hand.clear() # In your rules, hand is cleared upon commitment
