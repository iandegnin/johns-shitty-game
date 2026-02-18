extends Resource
class_name ActorResource

@export_group("Identity")
@export var actor_id: String = ""
@export var actor_name: String = ""

@export_group("Visuals")
@export var texture: Texture2D
@export var h_frames: int = 1
@export var v_frames: int = 1
@export var modulate: Color = Color.WHITE
@export var offset: Vector2 = Vector2.ZERO

@export_group("Stats")
@export var current_health: int
@export var max_stamina: int
@export var max_mana: int
