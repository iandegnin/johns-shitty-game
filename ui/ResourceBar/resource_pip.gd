extends TextureRect

@export var full_texture: Texture2D
@export var empty_texture: Texture2D

func set_is_full(is_full: bool) -> void:
	texture = full_texture if is_full else empty_texture
