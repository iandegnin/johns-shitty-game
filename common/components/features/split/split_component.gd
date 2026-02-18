extends Node
class_name SplitComponent

# In a real scenario, these stats would come from your Resource
var split_chance: float = 0.5 

func _ready() -> void:
	# Connect to the Parent (Actor) signal
	var parent: Actor = get_parent() as Actor
	if parent.has_signal("hit_received"):
		parent.hit_received.connect(_on_actor_hit)

func _on_actor_hit() -> void:
	check_split()

func check_split() -> void:
	if randf() < split_chance:
		spawn_minis()

func spawn_minis() -> void:
	print("Slime split! Spawning two smaller slimes...")
	# Logic for ActorFactory to spawn new units goes here
