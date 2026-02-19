class_name ActorVisuals
extends Resource

@export_group("Texture Settings")
@export var texture: Texture2D
@export var offset: Vector2 = Vector2.ZERO
@export var modulate: Color = Color.WHITE

@export_group("Sprite Layout")
@export var h_frames: int = 1
@export var v_frames: int = 1
@export var default_frame: int = 0
