extends TextureRect
class_name ResourcePip

@export var full_texture: Texture2D
@export var empty_texture: Texture2D

func set_filled(is_filled: bool) -> void:
	texture = full_texture if is_filled else empty_texture
